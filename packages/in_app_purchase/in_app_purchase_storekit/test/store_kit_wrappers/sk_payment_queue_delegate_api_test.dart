// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/in_app_purchase_apis.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../fakes/fake_storekit_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakeStoreKitPlatform = FakeStoreKitPlatform();

  setUpAll(() {
    setInAppPurchaseHostApis(api: fakeStoreKitPlatform);
  });

  test(
    'handlePaymentQueueDelegateCallbacks should call SKPaymentQueueDelegateWrapper.shouldContinueTransaction',
    () async {
      final queue = SKPaymentQueueWrapper();
      final testDelegate = TestPaymentQueueDelegate();
      await queue.setDelegate(testDelegate);

      final arguments = <String, dynamic>{
        'storefront': <String, String>{
          'countryCode': 'USA',
          'identifier': 'unique_identifier',
        },
        'transaction': <String, dynamic>{
          'payment': <String, dynamic>{
            'productIdentifier': 'product_identifier',
          },
        },
      };

      final Object? result = await queue.handlePaymentQueueDelegateCallbacks(
        MethodCall('shouldContinueTransaction', arguments),
      );

      expect(result, false);
      expect(testDelegate.log, <Matcher>{equals('shouldContinueTransaction')});
    },
  );

  test(
    'handlePaymentQueueDelegateCallbacks should call SKPaymentQueueDelegateWrapper.shouldShowPriceConsent',
    () async {
      final queue = SKPaymentQueueWrapper();
      final testDelegate = TestPaymentQueueDelegate();
      await queue.setDelegate(testDelegate);

      final result =
          (await queue.handlePaymentQueueDelegateCallbacks(
                const MethodCall('shouldShowPriceConsent'),
              ))!
              as bool;

      expect(result, false);
      expect(testDelegate.log, <Matcher>{equals('shouldShowPriceConsent')});
    },
  );

  test(
    'handleObserverCallbacks should call SKTransactionObserverWrapper.restoreCompletedTransactionsFailed',
    () async {
      final queue = SKPaymentQueueWrapper();
      final testObserver = TestTransactionObserverWrapper();
      queue.setTransactionObserver(testObserver);

      final arguments = <dynamic, dynamic>{
        'code': 100,
        'domain': 'domain',
        'userInfo': <String, dynamic>{'error': 'underlying_error'},
      };

      await queue.handleObserverCallbacks(
        MethodCall('restoreCompletedTransactionsFailed', arguments),
      );

      expect(testObserver.log, <Matcher>{
        equals('restoreCompletedTransactionsFailed'),
      });
    },
  );
}

class TestTransactionObserverWrapper extends SKTransactionObserverWrapper {
  final List<String> log = <String>[];

  @override
  void updatedTransactions({
    required List<SKPaymentTransactionWrapper> transactions,
  }) {
    log.add('updatedTransactions');
  }

  @override
  void removedTransactions({
    required List<SKPaymentTransactionWrapper> transactions,
  }) {
    log.add('removedTransactions');
  }

  @override
  void restoreCompletedTransactionsFailed({required SKError error}) {
    log.add('restoreCompletedTransactionsFailed');
  }

  @override
  void paymentQueueRestoreCompletedTransactionsFinished() {
    log.add('paymentQueueRestoreCompletedTransactionsFinished');
  }

  @override
  bool shouldAddStorePayment({
    required SKPaymentWrapper payment,
    required SKProductWrapper product,
  }) {
    log.add('shouldAddStorePayment');
    return false;
  }
}

class TestPaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  final List<String> log = <String>[];

  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    log.add('shouldContinueTransaction');
    return false;
  }

  @override
  bool shouldShowPriceConsent() {
    log.add('shouldShowPriceConsent');
    return false;
  }
}
