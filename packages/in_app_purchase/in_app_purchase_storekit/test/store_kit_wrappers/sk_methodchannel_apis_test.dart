// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/src/in_app_purchase_apis.dart';
import 'package:in_app_purchase_storekit/src/messages.g.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'sk_test_stub_objects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakeStoreKitPlatform = FakeStoreKitPlatform();

  setUpAll(() {
    setInAppPurchaseHostApis(api: fakeStoreKitPlatform);
  });

  setUp(() {});

  tearDown(() {
    fakeStoreKitPlatform.testReturnNull = false;
    fakeStoreKitPlatform.queueIsActive = null;
    fakeStoreKitPlatform.getReceiptFailTest = false;
  });

  group('sk_request_maker', () {
    test('get products method channel', () async {
      final SkProductResponseWrapper productResponseWrapper =
          await SKRequestMaker().startProductRequest(<String>['xxx']);
      expect(productResponseWrapper.products, isNotEmpty);
      expect(
        productResponseWrapper.products.first.priceLocale.currencySymbol,
        r'$',
      );

      expect(
        productResponseWrapper.products.first.priceLocale.currencySymbol,
        isNot('A'),
      );
      expect(
        productResponseWrapper.products.first.priceLocale.currencyCode,
        'USD',
      );
      expect(
        productResponseWrapper.products.first.priceLocale.countryCode,
        'US',
      );
      expect(productResponseWrapper.invalidProductIdentifiers, isNotEmpty);

      expect(fakeStoreKitPlatform.startProductRequestParam, <String>['xxx']);
    });

    test('get products method channel should throw exception', () async {
      fakeStoreKitPlatform.getProductRequestFailTest = true;
      expect(
        SKRequestMaker().startProductRequest(<String>['xxx']),
        throwsException,
      );
      fakeStoreKitPlatform.getProductRequestFailTest = false;
    });

    test('refreshed receipt', () async {
      final int receiptCountBefore = fakeStoreKitPlatform.refreshReceiptCount;
      await SKRequestMaker().startRefreshReceiptRequest(
        receiptProperties: <String, dynamic>{'isExpired': true},
      );
      expect(fakeStoreKitPlatform.refreshReceiptCount, receiptCountBefore + 1);
      expect(fakeStoreKitPlatform.refreshReceiptParam, <String, dynamic>{
        'isExpired': true,
      });
    });

    test('should get null receipt if any exceptions are raised', () async {
      fakeStoreKitPlatform.getReceiptFailTest = true;
      expect(
        () async => SKReceiptManager.retrieveReceiptData(),
        throwsA(const TypeMatcher<Exception>()),
      );
    });
  });

  group('sk_receipt_manager', () {
    test(
      'should get receipt (faking it by returning a `receipt data` string)',
      () async {
        final String receiptData = await SKReceiptManager.retrieveReceiptData();
        expect(receiptData, 'receipt data');
      },
    );
  });

  group('sk_payment_queue', () {
    test('canMakePayment should return true', () async {
      expect(await SKPaymentQueueWrapper.canMakePayments(), true);
    });

    test('storefront returns valid SKStoreFrontWrapper object', () async {
      final queue = SKPaymentQueueWrapper();
      expect(
        await queue.storefront(),
        SKStorefrontWrapper.fromJson(const <String, dynamic>{
          'countryCode': 'USA',
          'identifier': 'unique_identifier',
        }),
      );
    });

    test('transactions should return a valid list of transactions', () async {
      expect(await SKPaymentQueueWrapper().transactions(), isNotEmpty);
    });

    test(
      'throws if observer is not set for payment queue before adding payment',
      () async {
        expect(
          SKPaymentQueueWrapper().addPayment(dummyPayment),
          throwsAssertionError,
        );
      },
    );

    test('should add payment to the payment queue', () async {
      final queue = SKPaymentQueueWrapper();
      final observer = TestPaymentTransactionObserver();
      queue.setTransactionObserver(observer);
      await queue.addPayment(dummyPayment);
      expect(fakeStoreKitPlatform.payments.first, equals(dummyPayment));
    });

    test('should finish transaction', () async {
      final queue = SKPaymentQueueWrapper();
      final observer = TestPaymentTransactionObserver();
      queue.setTransactionObserver(observer);
      await queue.finishTransaction(dummyTransaction);
      expect(
        fakeStoreKitPlatform.transactionsFinished.first,
        equals(dummyTransaction.toFinishMap()),
      );
    });

    test('should restore transaction', () async {
      final queue = SKPaymentQueueWrapper();
      final observer = TestPaymentTransactionObserver();
      queue.setTransactionObserver(observer);
      await queue.restoreTransactions(applicationUserName: 'aUserID');
      expect(
        fakeStoreKitPlatform.applicationNameHasTransactionRestored,
        'aUserID',
      );
    });

    test('startObservingTransactionQueue should call methodChannel', () async {
      expect(fakeStoreKitPlatform.queueIsActive, isNot(true));
      await SKPaymentQueueWrapper().startObservingTransactionQueue();
      expect(fakeStoreKitPlatform.queueIsActive, true);
    });

    test('stopObservingTransactionQueue should call methodChannel', () async {
      expect(fakeStoreKitPlatform.queueIsActive, isNot(false));
      await SKPaymentQueueWrapper().stopObservingTransactionQueue();
      expect(fakeStoreKitPlatform.queueIsActive, false);
    });

    test('setDelegate should call methodChannel', () async {
      expect(fakeStoreKitPlatform.isPaymentQueueDelegateRegistered, false);
      await SKPaymentQueueWrapper().setDelegate(TestPaymentQueueDelegate());
      expect(fakeStoreKitPlatform.isPaymentQueueDelegateRegistered, true);
      await SKPaymentQueueWrapper().setDelegate(null);
      expect(fakeStoreKitPlatform.isPaymentQueueDelegateRegistered, false);
    });

    test('showPriceConsentIfNeeded should call methodChannel', () async {
      expect(fakeStoreKitPlatform.showPriceConsent, false);
      await SKPaymentQueueWrapper().showPriceConsentIfNeeded();
      expect(fakeStoreKitPlatform.showPriceConsent, true);
    });
  });

  group('Code Redemption Sheet', () {
    test('presentCodeRedemptionSheet should not throw', () async {
      expect(fakeStoreKitPlatform.presentCodeRedemption, false);
      await SKPaymentQueueWrapper().presentCodeRedemptionSheet();
      expect(fakeStoreKitPlatform.presentCodeRedemption, true);
      fakeStoreKitPlatform.presentCodeRedemption = false;
    });
  });
}

class FakeStoreKitPlatform implements InAppPurchaseAPI {
  // get product request
  List<dynamic> startProductRequestParam = <dynamic>[];
  bool getProductRequestFailTest = false;
  bool testReturnNull = false;

  // get receipt request
  bool getReceiptFailTest = false;

  // refresh receipt request
  int refreshReceiptCount = 0;
  late Map<String, dynamic> refreshReceiptParam;

  // payment queue
  List<SKPaymentWrapper> payments = <SKPaymentWrapper>[];
  List<Map<String, String>> transactionsFinished = <Map<String, String>>[];
  String applicationNameHasTransactionRestored = '';

  // present Code Redemption
  bool presentCodeRedemption = false;

  // show price consent sheet
  bool showPriceConsent = false;

  // indicate if the payment queue delegate is registered
  bool isPaymentQueueDelegateRegistered = false;

  // Listen to purchase updates
  bool? queueIsActive;

  @override
  Future<void> addPayment(Map<String?, Object?> paymentMap) async {
    payments.add(
      SKPaymentWrapper.fromJson(Map<String, dynamic>.from(paymentMap)),
    );
  }

  @override
  Future<bool> canMakePayments() async {
    return true;
  }

  @override
  Future<SKStorefrontMessage> storefront() async {
    return SKStorefrontMessage(
      countryCode: 'USA',
      identifier: 'unique_identifier',
    );
  }

  @override
  Future<List<SKPaymentTransactionMessage>> transactions() async =>
      <SKPaymentTransactionMessage>[dummyTransactionMessage];

  @override
  Future<void> finishTransaction(Map<String?, Object?> finishMap) async {
    transactionsFinished.add(Map<String, String>.from(finishMap));
  }

  @override
  Future<void> presentCodeRedemptionSheet() async {
    presentCodeRedemption = true;
  }

  @override
  Future<void> restoreTransactions(String? applicationUserName) async {
    applicationNameHasTransactionRestored = applicationUserName!;
  }

  @override
  Future<SKProductsResponseMessage> startProductRequest(
    List<String?> productIdentifiers,
  ) async {
    startProductRequestParam = productIdentifiers;
    if (getProductRequestFailTest) {
      return Future<SKProductsResponseMessage>.value(
        SKProductsResponseMessage(),
      );
    }
    return dummyProductResponseMessage;
  }

  @override
  Future<void> registerPaymentQueueDelegate() async {
    isPaymentQueueDelegateRegistered = true;
  }

  @override
  Future<void> removePaymentQueueDelegate() async {
    isPaymentQueueDelegateRegistered = false;
  }

  @override
  Future<void> startObservingPaymentQueue() async {
    queueIsActive = true;
  }

  @override
  Future<void> stopObservingPaymentQueue() async {
    queueIsActive = false;
  }

  @override
  Future<String> retrieveReceiptData() async {
    if (getReceiptFailTest) {
      throw Exception('some arbitrary error');
    }
    return 'receipt data';
  }

  @override
  Future<void> refreshReceipt({Map<String?, dynamic>? receiptProperties}) {
    refreshReceiptCount++;
    refreshReceiptParam = Map.castFrom<dynamic, dynamic, String, dynamic>(
      receiptProperties!,
    );
    return Future<void>.sync(() {});
  }

  @override
  Future<void> showPriceConsentIfNeeded() async {
    showPriceConsent = true;
  }

  @override
  Future<bool> supportsStoreKit2() async {
    return true;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}

class TestPaymentQueueDelegate extends SKPaymentQueueDelegateWrapper {}

class TestPaymentTransactionObserver extends SKTransactionObserverWrapper {
  @override
  void updatedTransactions({
    required List<SKPaymentTransactionWrapper> transactions,
  }) {}

  @override
  void removedTransactions({
    required List<SKPaymentTransactionWrapper> transactions,
  }) {}

  @override
  void restoreCompletedTransactionsFailed({required SKError error}) {}

  @override
  void paymentQueueRestoreCompletedTransactionsFinished() {}

  @override
  bool shouldAddStorePayment({
    required SKPaymentWrapper payment,
    required SKProductWrapper product,
  }) {
    return true;
  }
}
