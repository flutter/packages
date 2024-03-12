// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:mockito/mockito.dart';

import 'billing_client_wrapper_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInAppPurchaseApi mockApi;
  late BillingClientManager manager;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    mockApi = MockInAppPurchaseApi();
    when(mockApi.startConnection(any, any)).thenAnswer(
        (_) async => PlatformBillingResult(responseCode: 0, debugMessage: ''));
    manager = BillingClientManager(
        billingClientFactory: (PurchasesUpdatedListener listener,
                UserSelectedAlternativeBillingListener?
                    alternativeBillingListener) =>
            BillingClient(listener, alternativeBillingListener, api: mockApi));
  });

  group('BillingClientWrapper', () {
    test('connects on initialization', () {
      verify(mockApi.startConnection(any, any)).called(1);
    });

    test('waits for connection before executing the operations', () async {
      final Completer<void> connectedCompleter = Completer<void>();
      when(mockApi.startConnection(any, any)).thenAnswer((_) async {
        connectedCompleter.complete();
        return PlatformBillingResult(responseCode: 0, debugMessage: '');
      });

      final Completer<void> calledCompleter1 = Completer<void>();
      final Completer<void> calledCompleter2 = Completer<void>();
      unawaited(manager.runWithClient((BillingClient _) async {
        calledCompleter1.complete();
        return const BillingResultWrapper(responseCode: BillingResponse.ok);
      }));
      unawaited(manager.runWithClientNonRetryable(
        (BillingClient _) async => calledCompleter2.complete(),
      ));
      expect(calledCompleter1.isCompleted, equals(false));
      expect(calledCompleter1.isCompleted, equals(false));
      connectedCompleter.complete();
      await expectLater(calledCompleter1.future, completes);
      await expectLater(calledCompleter2.future, completes);
    });

    test('re-connects when client sends onBillingServiceDisconnected',
        () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      verify(mockApi.startConnection(any, any)).called(2);
    });

    test('re-connects when host calls reconnectWithBillingChoiceMode',
        () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      await manager.reconnectWithBillingChoiceMode(
          BillingChoiceMode.alternativeBillingOnly);
      // Verify that connection was ended.
      verify(mockApi.endConnection()).called(1);

      clearInteractions(mockApi);

      /// Fake the disconnect that we would expect from a endConnectionCall.
      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      // Verify that after connection ended reconnect was called.
      final VerificationResult result =
          verify(mockApi.startConnection(any, captureAny));
      expect(result.captured.single,
          PlatformBillingChoiceMode.alternativeBillingOnly);
    });

    test(
      're-connects when operation returns BillingResponse.serviceDisconnected',
      () async {
        clearInteractions(mockApi);

        int timesCalled = 0;
        final BillingResultWrapper result = await manager.runWithClient(
          (BillingClient _) async {
            timesCalled++;
            return BillingResultWrapper(
              responseCode: timesCalled == 1
                  ? BillingResponse.serviceDisconnected
                  : BillingResponse.ok,
            );
          },
        );
        verify(mockApi.startConnection(any, any)).called(1);
        expect(timesCalled, equals(2));
        expect(result.responseCode, equals(BillingResponse.ok));
      },
    );

    test('does not re-connect when disposed', () {
      clearInteractions(mockApi);
      manager.dispose();
      verifyNever(mockApi.startConnection(any, any));
      verify(mockApi.endConnection()).called(1);
    });

    test(
        'Emits UserChoiceDetailsWrapper when onUserChoiceAlternativeBilling is called',
        () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      const UserChoiceDetailsWrapper expected = UserChoiceDetailsWrapper(
        originalExternalTransactionId: 'TransactionId',
        externalTransactionToken: 'TransactionToken',
        products: <UserChoiceDetailsProductWrapper>[
          UserChoiceDetailsProductWrapper(
              id: 'id1',
              offerToken: 'offerToken1',
              productType: ProductType.inapp),
          UserChoiceDetailsProductWrapper(
              id: 'id2',
              offerToken: 'offerToken2',
              productType: ProductType.inapp),
        ],
      );
      final Future<UserChoiceDetailsWrapper> detailsFuture =
          manager.userChoiceDetailsStream.first;
      manager.onUserChoiceAlternativeBilling(expected);
      expect(await detailsFuture, expected);
    });
  });
}
