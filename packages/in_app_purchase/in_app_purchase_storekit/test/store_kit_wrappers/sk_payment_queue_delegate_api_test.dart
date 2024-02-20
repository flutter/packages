// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/channel.dart';
import 'package:in_app_purchase_storekit/src/messages.g.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../fakes/fake_storekit_platform.dart';
import '../test_api.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakeStoreKitPlatform fakeStoreKitPlatform = FakeStoreKitPlatform();
  

  setUpAll(() {
    TestInAppPurchaseApi.setup(fakeStoreKitPlatform);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            SystemChannels.platform, fakeStoreKitPlatform.onMethodCall);
  });

  test(
      'handlePaymentQueueDelegateCallbacks should call SKPaymentQueueDelegateWrapper.shouldContinueTransaction',
      () async {
    final SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
    final TestPaymentQueueDelegate testDelegate = TestPaymentQueueDelegate();
    await queue.setDelegate(testDelegate);

    final Map<String, dynamic> arguments = <String, dynamic>{
      'storefront': <String, String>{
        'countryCode': 'USA',
        'identifier': 'unique_identifier',
      },
      'transaction': <String, dynamic>{
        'payment': <String, dynamic>{
          'productIdentifier': 'product_identifier',
        }
      },
    };

    final Object? result = await queue.handlePaymentQueueDelegateCallbacks(
      MethodCall('shouldContinueTransaction', arguments),
    );

    expect(result, false);
    expect(
      testDelegate.log,
      <Matcher>{
        equals('shouldContinueTransaction'),
      },
    );
  });

  test(
      'handlePaymentQueueDelegateCallbacks should call SKPaymentQueueDelegateWrapper.shouldShowPriceConsent',
      () async {
    final SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
    final TestPaymentQueueDelegate testDelegate = TestPaymentQueueDelegate();
    await queue.setDelegate(testDelegate);

    final bool result = (await queue.handlePaymentQueueDelegateCallbacks(
      const MethodCall('shouldShowPriceConsent'),
    ))! as bool;

    expect(result, false);
    expect(
      testDelegate.log,
      <Matcher>{
        equals('shouldShowPriceConsent'),
      },
    );
  });

  test(
      'handleObserverCallbacks should call SKTransactionObserverWrapper.restoreCompletedTransactionsFailed',
      () async {
    final SKPaymentQueueWrapper queue = SKPaymentQueueWrapper();
    final TestTransactionObserverWrapper testObserver =
        TestTransactionObserverWrapper();
    queue.setTransactionObserver(testObserver);

    final Map<dynamic, dynamic> arguments = <dynamic, dynamic>{
      'code': 100,
      'domain': 'domain',
      'userInfo': <String, dynamic>{'error': 'underlying_error'},
    };

    await queue.handleObserverCallbacks(
      MethodCall('restoreCompletedTransactionsFailed', arguments),
    );

    expect(
      testObserver.log,
      <Matcher>{
        equals('restoreCompletedTransactionsFailed'),
      },
    );
  });
}

class TestTransactionObserverWrapper extends SKTransactionObserverWrapper {
  final List<String> log = <String>[];

  @override
  void updatedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions}) {
    log.add('updatedTransactions');
  }

  @override
  void removedTransactions(
      {required List<SKPaymentTransactionWrapper> transactions}) {
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
  bool shouldAddStorePayment(
      {required SKPaymentWrapper payment, required SKProductWrapper product}) {
    log.add('shouldAddStorePayment');
    return false;
  }
}

class TestPaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {
  final List<String> log = <String>[];

  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    log.add('shouldContinueTransaction');
    return false;
  }

  @override
  bool shouldShowPriceConsent() {
    log.add('shouldShowPriceConsent');
    return false;
  }
}

// class FakeStoreKitPlatform implements TestInAppPurchaseApi {
//   FakeStoreKitPlatform() {
//     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//         .setMockMethodCallHandler(channel, onMethodCall);
//   }
//
//   // indicate if the payment queue delegate is registered
//   bool isPaymentQueueDelegateRegistered = false;
//
//   Future<dynamic> onMethodCall(MethodCall call) {
//     switch (call.method) {
//       case '-[SKPaymentQueue registerDelegate]':
//         isPaymentQueueDelegateRegistered = true;
//         return Future<void>.sync(() {});
//       case '-[SKPaymentQueue removeDelegate]':
//         isPaymentQueueDelegateRegistered = false;
//         return Future<void>.sync(() {});
//     }
//     return Future<dynamic>.error('method not mocked');
//   }
//
//   @override
//   void addPayment(Map<String?, Object?> paymentMap) {
//     // TODO: implement addPayment
//   }
//
//   @override
//   bool canMakePayments() {
//     // TODO: implement canMakePayments
//     throw UnimplementedError();
//   }
//
//   @override
//   void finishTransaction(Map<String?, String?> finishMap) {
//     // TODO: implement finishTransaction
//   }
//
//   @override
//   void presentCodeRedemptionSheet() {
//     // TODO: implement presentCodeRedemptionSheet
//   }
//
//   @override
//   Future<void> refreshReceipt({Map<String?, Object?>? receiptProperties}) {
//     // TODO: implement refreshReceipt
//     throw UnimplementedError();
//   }
//
//   @override
//   void registerPaymentQueueDelegate() {
//     // TODO: implement registerPaymentQueueDelegate
//   }
//
//   @override
//   void removePaymentQueueDelegate() {
//     // TODO: implement removePaymentQueueDelegate
//   }
//
//   @override
//   void restoreTransactions(String? applicationUserName) {
//     // TODO: implement restoreTransactions
//   }
//
//   @override
//   String retrieveReceiptData() {
//     // TODO: implement retrieveReceiptData
//     throw UnimplementedError();
//   }
//
//   @override
//   void showPriceConsentIfNeeded() {
//     // TODO: implement showPriceConsentIfNeeded
//   }
//
//   @override
//   void startObservingPaymentQueue() {
//     // TODO: implement startObservingPaymentQueue
//   }
//
//   @override
//   Future<SKProductsResponseMessage> startProductRequest(List<String?> productIdentifiers) {
//     // TODO: implement startProductRequest
//     throw UnimplementedError();
//   }
//
//   @override
//   void stopObservingPaymentQueue() {
//     // TODO: implement stopObservingPaymentQueue
//   }
//
//   @override
//   SKStorefrontMessage storefront() {
//     // TODO: implement storefront
//     throw UnimplementedError();
//   }
//
//   @override
//   List<SKPaymentTransactionMessage?> transactions() {
//     // TODO: implement transactions
//     throw UnimplementedError();
//   }
// }
