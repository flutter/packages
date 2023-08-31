// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/channel.dart';

import '../stub_in_app_purchase_platform.dart';
import 'purchase_wrapper_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final StubInAppPurchasePlatform stubPlatform = StubInAppPurchasePlatform();
  late BillingClientManager manager;
  late Completer<void> connectedCompleter;

  const String startConnectionCall =
      'BillingClient#startConnection(BillingClientStateListener)';
  const String endConnectionCall = 'BillingClient#endConnection()';
  const String onBillingServiceDisconnectedCallback =
      'BillingClientStateListener#onBillingServiceDisconnected()';

  setUpAll(() => _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
      .defaultBinaryMessenger
      .setMockMethodCallHandler(channel, stubPlatform.fakeMethodCallHandler));

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    connectedCompleter = Completer<void>.sync();
    stubPlatform.addResponse(
      name: startConnectionCall,
      value: buildBillingResultMap(
        const BillingResultWrapper(responseCode: BillingResponse.ok),
      ),
      additionalStepBeforeReturn: (dynamic _) => connectedCompleter.future,
    );
    stubPlatform.addResponse(name: endConnectionCall);
    manager = BillingClientManager();
  });

  tearDown(() => stubPlatform.reset());

  group('BillingClientWrapper', () {
    test('connects on initialization', () {
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(1));
    });

    test('waits for connection before executing the operations', () async {
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
      connectedCompleter.complete();
      // Ensures all asynchronous connected code finishes.
      await manager.runWithClientNonRetryable((_) async {});

      await manager.client.callHandler(
        const MethodCall(onBillingServiceDisconnectedCallback,
            <String, dynamic>{'handle': 0}),
      );
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(2));
    });

    test(
      're-connects when operation returns BillingResponse.serviceDisconnected',
      () async {
        connectedCompleter.complete();
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
        expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(2));
        expect(timesCalled, equals(2));
        expect(result.responseCode, equals(BillingResponse.ok));
      },
    );

    test('does not re-connect when disposed', () {
      connectedCompleter.complete();
      manager.dispose();
      expect(stubPlatform.countPreviousCalls(startConnectionCall), equals(1));
      expect(stubPlatform.countPreviousCalls(endConnectionCall), equals(1));
    });
  });
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
