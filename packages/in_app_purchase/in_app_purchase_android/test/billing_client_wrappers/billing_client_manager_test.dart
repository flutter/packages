// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/billing_client_wrappers/pending_purchases_params_wrapper.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:mockito/mockito.dart';

import 'billing_client_wrapper_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInAppPurchaseApi mockApi;
  late BillingClientManager manager;

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    mockApi = MockInAppPurchaseApi();
    when(mockApi.startConnection(any, any, any)).thenAnswer(
      (_) async =>
          PlatformBillingResult(responseCode: PlatformBillingResponse.ok, debugMessage: ''),
    );
    manager = BillingClientManager(
      billingClientFactory:
          (
            PurchasesUpdatedListener listener,
            UserSelectedAlternativeBillingListener? alternativeBillingListener,
          ) => BillingClient(listener, alternativeBillingListener, api: mockApi),
    );
    // _connect defers the connection by one macrotask, so pump the event
    // queue so the tests below start from an already-connected manager.
    await pumpEventQueue();
  });

  group('BillingClientWrapper', () {
    test('connects on initialization', () {
      verify(mockApi.startConnection(any, any, any)).called(1);
    });

    test('waits for connection before executing the operations', () async {
      final connectedCompleter = Completer<void>();
      when(mockApi.startConnection(any, any, any)).thenAnswer((_) async {
        connectedCompleter.complete();
        return PlatformBillingResult(responseCode: PlatformBillingResponse.ok, debugMessage: '');
      });

      final calledCompleter1 = Completer<void>();
      final calledCompleter2 = Completer<void>();
      unawaited(
        manager.runWithClient((BillingClient _) async {
          calledCompleter1.complete();
          return const BillingResultWrapper(responseCode: BillingResponse.ok);
        }),
      );
      unawaited(
        manager.runWithClientNonRetryable((BillingClient _) async => calledCompleter2.complete()),
      );
      expect(calledCompleter1.isCompleted, equals(false));
      expect(calledCompleter1.isCompleted, equals(false));
      connectedCompleter.complete();
      await expectLater(calledCompleter1.future, completes);
      await expectLater(calledCompleter2.future, completes);
    });

    test('re-connects when client sends onBillingServiceDisconnected', () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      // The reconnect is deferred one macrotask; pump so it fires before
      // verifying.
      await pumpEventQueue();
      verify(mockApi.startConnection(any, any, any)).called(2);
    });

    test('reconnect is deferred off the disconnect callback (does not call '
        'startConnection synchronously)', () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});
      clearInteractions(mockApi);

      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      // Regression test for https://github.com/flutter/flutter/issues/144954:
      // the outbound startConnection platform message must NOT be sent
      // synchronously on the inbound onBillingServiceDisconnected upcall —
      // a pending Java exception at that moment aborts the process
      // (uncatchable SIGABRT in FlutterViewHandlePlatformMessage).
      verifyNever(mockApi.startConnection(any, any, any));

      await pumpEventQueue();
      verify(mockApi.startConnection(any, any, any)).called(1);
    });

    test('re-connects when host calls reconnectWithBillingChoiceMode', () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      await manager.reconnectWithBillingChoiceMode(BillingChoiceMode.alternativeBillingOnly);
      // Verify that connection was ended.
      verify(mockApi.endConnection()).called(1);

      clearInteractions(mockApi);

      /// Fake the disconnect that we would expect from a endConnectionCall.
      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      // The reconnect is deferred one macrotask; pump so it fires before
      // verifying.
      await pumpEventQueue();
      // Verify that after connection ended reconnect was called.
      final VerificationResult result = verify(mockApi.startConnection(any, captureAny, any));
      expect(result.captured.single, PlatformBillingChoiceMode.alternativeBillingOnly);
    });

    test('re-connects when host calls reconnectWithPendingPurchasesParams', () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      await manager.reconnectWithPendingPurchasesParams(
        const PendingPurchasesParamsWrapper(enablePrepaidPlans: true),
      );
      // Verify that connection was ended.
      verify(mockApi.endConnection()).called(1);

      clearInteractions(mockApi);

      /// Fake the disconnect that we would expect from a endConnectionCall.
      manager.client.hostCallbackHandler.onBillingServiceDisconnected(0);
      // The reconnect is deferred one macrotask; pump so it fires before
      // verifying.
      await pumpEventQueue();
      // Verify that after connection ended reconnect was called.
      final VerificationResult result = verify(mockApi.startConnection(any, any, captureAny));
      expect(
        result.captured.single,
        isA<PlatformPendingPurchasesParams>().having(
          (PlatformPendingPurchasesParams params) => params.enablePrepaidPlans,
          'enablePrepaidPlans',
          true,
        ),
      );
    });

    test('re-connects when operation returns BillingResponse.serviceDisconnected', () async {
      clearInteractions(mockApi);

      var timesCalled = 0;
      final BillingResultWrapper result = await manager.runWithClient((BillingClient _) async {
        timesCalled++;
        return BillingResultWrapper(
          responseCode: timesCalled == 1 ? BillingResponse.serviceDisconnected : BillingResponse.ok,
        );
      });
      verify(mockApi.startConnection(any, any, any)).called(1);
      expect(timesCalled, equals(2));
      expect(result.responseCode, equals(BillingResponse.ok));
    });

    test('does not re-connect when disposed', () {
      clearInteractions(mockApi);
      manager.dispose();
      verifyNever(mockApi.startConnection(any, any, any));
      verify(mockApi.endConnection()).called(1);
    });

    test('Emits UserChoiceDetailsWrapper when onUserChoiceAlternativeBilling is called', () async {
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      const expected = UserChoiceDetailsWrapper(
        originalExternalTransactionId: 'TransactionId',
        externalTransactionToken: 'TransactionToken',
        products: <UserChoiceDetailsProductWrapper>[
          UserChoiceDetailsProductWrapper(
            id: 'id1',
            offerToken: 'offerToken1',
            productType: ProductType.inapp,
          ),
          UserChoiceDetailsProductWrapper(
            id: 'id2',
            offerToken: 'offerToken2',
            productType: ProductType.inapp,
          ),
        ],
      );
      final Future<UserChoiceDetailsWrapper> detailsFuture = manager.userChoiceDetailsStream.first;
      manager.onUserChoiceAlternativeBilling(expected);
      expect(await detailsFuture, expected);
    });
  });
}
