// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/src/messages.g.dart';
import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart';
import 'package:in_app_purchase_storekit/src/store_kit_2_wrappers/sk2_product_wrapper.dart';
import 'package:in_app_purchase_storekit/src/store_kit_2_wrappers/sk2_transaction_wrapper.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../store_kit_wrappers/sk_test_stub_objects.dart';

class FakeStoreKitPlatform implements InAppPurchaseAPI {
  // pre-configured store information
  String? receiptData;
  late Set<String> validProductIDs;
  late Map<String, SKProductWrapper> validProducts;
  late List<SKPaymentTransactionWrapper> transactionList;
  late List<SKPaymentTransactionWrapper> finishedTransactions;
  late bool testRestoredTransactionsNull;
  late bool testTransactionFail;
  late int testTransactionCancel;
  PlatformException? queryProductException;
  PlatformException? restoreException;
  SKError? testRestoredError;
  bool queueIsActive = false;
  Map<String, dynamic> discountReceived = <String, dynamic>{};
  bool isPaymentQueueDelegateRegistered = false;
  String _countryCode = 'USA';
  String _countryIdentifier = 'LL';
  bool shouldStoreKit2BeEnabled = true;

  void reset() {
    transactionList = <SKPaymentTransactionWrapper>[];
    receiptData = 'dummy base64data';
    validProductIDs = <String>{'123', '456', '789'};
    validProducts = <String, SKProductWrapper>{};
    for (final String validID in validProductIDs) {
      final Map<String, dynamic> productWrapperMap = buildProductMap(
        dummyProductWrapper,
      );
      productWrapperMap['productIdentifier'] = validID;
      if (validID == '456') {
        productWrapperMap['priceLocale'] = buildLocaleMap(noSymbolLocale);
      }
      if (validID == '789') {
        productWrapperMap['localizedDescription'] = null;
      }
      validProducts[validID] = SKProductWrapper.fromJson(productWrapperMap);
      shouldStoreKit2BeEnabled = true;
    }

    finishedTransactions = <SKPaymentTransactionWrapper>[];
    testRestoredTransactionsNull = false;
    testTransactionFail = false;
    testTransactionCancel = -1;
    queryProductException = null;
    restoreException = null;
    testRestoredError = null;
    queueIsActive = false;
    discountReceived = <String, dynamic>{};
    isPaymentQueueDelegateRegistered = false;
    _countryCode = 'USA';
    _countryIdentifier = 'LL';
  }

  SKPaymentTransactionWrapper createPendingTransaction(
    String id, {
    int quantity = 1,
  }) {
    return SKPaymentTransactionWrapper(
      transactionIdentifier: '',
      payment: SKPaymentWrapper(productIdentifier: id, quantity: quantity),
      transactionState: SKPaymentTransactionStateWrapper.purchasing,
      transactionTimeStamp: 123123.121,
    );
  }

  SKPaymentTransactionWrapper createPurchasedTransaction(
    String productId,
    String transactionId, {
    int quantity = 1,
  }) {
    return SKPaymentTransactionWrapper(
      payment: SKPaymentWrapper(
        productIdentifier: productId,
        quantity: quantity,
      ),
      transactionState: SKPaymentTransactionStateWrapper.purchased,
      transactionTimeStamp: 123123.121,
      transactionIdentifier: transactionId,
    );
  }

  SKPaymentTransactionWrapper createFailedTransaction(
    String productId, {
    int quantity = 1,
  }) {
    return SKPaymentTransactionWrapper(
      transactionIdentifier: '',
      payment: SKPaymentWrapper(
        productIdentifier: productId,
        quantity: quantity,
      ),
      transactionState: SKPaymentTransactionStateWrapper.failed,
      transactionTimeStamp: 123123.121,
      error: const SKError(
        code: 0,
        domain: 'ios_domain',
        userInfo: <String, Object>{'message': 'an error message'},
      ),
    );
  }

  SKPaymentTransactionWrapper createCanceledTransaction(
    String productId,
    int errorCode, {
    int quantity = 1,
  }) {
    return SKPaymentTransactionWrapper(
      transactionIdentifier: '',
      payment: SKPaymentWrapper(
        productIdentifier: productId,
        quantity: quantity,
      ),
      transactionState: SKPaymentTransactionStateWrapper.failed,
      transactionTimeStamp: 123123.121,
      error: SKError(
        code: errorCode,
        domain: 'ios_domain',
        userInfo: const <String, Object>{'message': 'an error message'},
      ),
    );
  }

  SKPaymentTransactionWrapper createRestoredTransaction(
    String productId,
    String transactionId, {
    int quantity = 1,
  }) {
    return SKPaymentTransactionWrapper(
      payment: SKPaymentWrapper(
        productIdentifier: productId,
        quantity: quantity,
      ),
      transactionState: SKPaymentTransactionStateWrapper.restored,
      transactionTimeStamp: 123123.121,
      transactionIdentifier: transactionId,
    );
  }

  @override
  Future<bool> canMakePayments() async {
    return true;
  }

  @override
  Future<void> addPayment(Map<String?, Object?> paymentMap) async {
    final id = paymentMap['productIdentifier']! as String;
    final quantity = paymentMap['quantity']! as int;

    // Keep the received paymentDiscount parameter when testing payment with discount.
    if (paymentMap['applicationUsername']! == 'userWithDiscount') {
      final discountArgument =
          paymentMap['paymentDiscount'] as Map<Object?, Object?>?;
      if (discountArgument != null) {
        discountReceived = discountArgument.cast<String, Object?>();
      } else {
        discountReceived = <String, Object?>{};
      }
    }

    final SKPaymentTransactionWrapper transaction = createPendingTransaction(
      id,
      quantity: quantity,
    );
    transactionList.add(transaction);
    InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
      transactions: <SKPaymentTransactionWrapper>[transaction],
    );
    if (testTransactionFail) {
      final SKPaymentTransactionWrapper transactionFailed =
          createFailedTransaction(id, quantity: quantity);
      InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
        transactions: <SKPaymentTransactionWrapper>[transactionFailed],
      );
    } else if (testTransactionCancel > 0) {
      final SKPaymentTransactionWrapper transactionCanceled =
          createCanceledTransaction(
            id,
            testTransactionCancel,
            quantity: quantity,
          );
      InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
        transactions: <SKPaymentTransactionWrapper>[transactionCanceled],
      );
    } else {
      final SKPaymentTransactionWrapper transactionFinished =
          createPurchasedTransaction(
            id,
            transaction.transactionIdentifier ?? '',
            quantity: quantity,
          );
      InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
        transactions: <SKPaymentTransactionWrapper>[transactionFinished],
      );
    }
  }

  void setStoreFrontInfo({
    required String countryCode,
    required String identifier,
  }) {
    _countryCode = countryCode;
    _countryIdentifier = identifier;
  }

  @override
  Future<SKStorefrontMessage> storefront() async {
    return SKStorefrontMessage(
      countryCode: _countryCode,
      identifier: _countryIdentifier,
    );
  }

  @override
  Future<List<SKPaymentTransactionMessage>> transactions() async {
    throw UnimplementedError();
  }

  @override
  Future<void> finishTransaction(Map<String?, Object?> finishMap) async {
    finishedTransactions.add(
      createPurchasedTransaction(
        finishMap['productIdentifier']! as String,
        finishMap['transactionIdentifier']! as String,
        quantity: transactionList.first.payment.quantity,
      ),
    );
  }

  @override
  Future<void> presentCodeRedemptionSheet() async {}

  @override
  Future<void> restoreTransactions(String? applicationUserName) async {
    if (restoreException != null) {
      throw restoreException!;
    }
    if (testRestoredError != null) {
      InAppPurchaseStoreKitPlatform.observer.restoreCompletedTransactionsFailed(
        error: testRestoredError!,
      );
      return;
    }
    if (!testRestoredTransactionsNull) {
      InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
        transactions: transactionList,
      );
    }
    InAppPurchaseStoreKitPlatform.observer
        .paymentQueueRestoreCompletedTransactionsFinished();
  }

  @override
  Future<SKProductsResponseMessage> startProductRequest(
    List<String?> productIdentifiers,
  ) {
    if (queryProductException != null) {
      throw queryProductException!;
    }
    final productIDS = productIdentifiers;
    final invalidFound = <String>[];
    final products = <SKProductWrapper>[];
    for (final productID in productIDS) {
      if (!validProductIDs.contains(productID)) {
        invalidFound.add(productID!);
      } else {
        products.add(validProducts[productID]!);
      }
    }
    final response = SkProductResponseWrapper(
      products: products,
      invalidProductIdentifiers: invalidFound,
    );

    return Future<SKProductsResponseMessage>.value(
      SkProductResponseWrapper.convertToPigeon(response),
    );
  }

  @override
  Future<void> refreshReceipt({Map<String?, dynamic>? receiptProperties}) {
    receiptData = 'refreshed receipt data';
    return Future<void>.sync(() {});
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
  Future<String> retrieveReceiptData() async {
    if (receiptData != null) {
      return receiptData!;
    } else {
      throw PlatformException(code: 'no_receipt_data');
    }
  }

  @override
  Future<void> showPriceConsentIfNeeded() async {}

  @override
  Future<void> startObservingPaymentQueue() async {
    queueIsActive = true;
  }

  @override
  Future<void> stopObservingPaymentQueue() async {
    queueIsActive = false;
  }

  @override
  Future<bool> supportsStoreKit2() async {
    return shouldStoreKit2BeEnabled;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}

class FakeStoreKit2Platform implements InAppPurchase2API {
  late Set<String> validProductIDs;
  late Map<String, SK2Product> validProducts;
  late List<SK2TransactionMessage> transactionList = <SK2TransactionMessage>[];
  late bool testTransactionFail;
  late int testTransactionCancel;
  late List<SK2Transaction> finishedTransactions;

  PlatformException? queryProductException;
  bool isListenerRegistered = false;
  SK2ProductPurchaseOptionsMessage? lastPurchaseOptions;
  Map<String, Set<String>> eligibleWinBackOffers = <String, Set<String>>{};
  Map<String, bool> eligibleIntroductoryOffers = <String, bool>{};

  void reset() {
    validProductIDs = <String>{'123', '456'};
    validProducts = <String, SK2Product>{};
    for (final String validID in validProductIDs) {
      final product = SK2Product(
        id: validID,
        displayName: 'test_product',
        displayPrice: '0.99',
        description: 'description',
        price: 0.99,
        type: SK2ProductType.consumable,
        priceLocale: SK2PriceLocale(currencyCode: 'USD', currencySymbol: r'$'),
      );
      validProducts[validID] = product;
    }
    eligibleWinBackOffers = <String, Set<String>>{};
    eligibleIntroductoryOffers = <String, bool>{};
  }

  SK2TransactionMessage createRestoredTransaction(
    String productId,
    String transactionId, {
    int quantity = 1,
  }) {
    return SK2TransactionMessage(
      id: 123,
      originalId: 321,
      productId: '',
      purchaseDate: '',
      appAccountToken: '',
      restoring: true,
    );
  }

  @override
  Future<bool> canMakePayments() async {
    return true;
  }

  @override
  Future<List<SK2ProductMessage>> products(List<String?> identifiers) async {
    if (queryProductException != null) {
      throw queryProductException!;
    }
    final productIDS = identifiers;
    final products = <SK2Product>[];
    for (final productID in productIDS) {
      if (validProductIDs.contains(productID)) {
        products.add(validProducts[productID]!);
      }
    }
    final result = <SK2ProductMessage>[];
    for (final p in products) {
      result.add(p.convertToPigeon());
    }

    return Future<List<SK2ProductMessage>>.value(result);
  }

  @override
  Future<SK2ProductPurchaseResultMessage> purchase(
    String id, {
    SK2ProductPurchaseOptionsMessage? options,
  }) {
    lastPurchaseOptions = options;
    final SK2TransactionMessage transaction = createPendingTransaction(id);

    InAppPurchaseStoreKitPlatform.sk2TransactionObserver.onTransactionsUpdated(
      <SK2TransactionMessage>[transaction],
    );
    return Future<SK2ProductPurchaseResultMessage>.value(
      SK2ProductPurchaseResultMessage.success,
    );
  }

  @override
  Future<void> finish(int id) {
    return Future<void>.value();
  }

  @override
  Future<List<SK2TransactionMessage>> transactions() {
    return Future<List<SK2TransactionMessage>>.value(<SK2TransactionMessage>[
      SK2TransactionMessage(
        id: 123,
        originalId: 123,
        productId: 'product_id',
        purchaseDate: '12-12',
      ),
    ]);
  }

  @override
  Future<void> startListeningToTransactions() async {
    isListenerRegistered = true;
  }

  @override
  Future<void> stopListeningToTransactions() async {
    isListenerRegistered = false;
  }

  @override
  Future<void> restorePurchases() async {
    InAppPurchaseStoreKitPlatform.sk2TransactionObserver.onTransactionsUpdated(
      transactionList,
    );
  }

  @override
  Future<String> countryCode() async {
    return 'ABC';
  }

  @override
  Future<void> sync() async {}

  @override
  Future<bool> isWinBackOfferEligible(String productId, String offerId) async {
    if (!validProductIDs.contains(productId)) {
      throw PlatformException(
        code: 'storekit2_failed_to_fetch_product',
        message: 'StoreKit failed to fetch product',
        details: 'Product ID: $productId',
      );
    }

    if (validProducts[productId]?.type != SK2ProductType.autoRenewable) {
      throw PlatformException(
        code: 'storekit2_not_subscription',
        message: 'Product is not a subscription',
        details: 'Product ID: $productId',
      );
    }

    return eligibleWinBackOffers[productId]?.contains(offerId) ?? false;
  }

  @override
  Future<bool> isIntroductoryOfferEligible(String productId) async {
    if (!validProductIDs.contains(productId)) {
      throw PlatformException(
        code: 'storekit2_failed_to_fetch_product',
        message: 'StoreKit failed to fetch product',
        details: 'Product ID: $productId',
      );
    }

    if (validProducts[productId]?.type != SK2ProductType.autoRenewable) {
      throw PlatformException(
        code: 'storekit2_not_subscription',
        message: 'Product is not a subscription',
        details: 'Product ID: $productId',
      );
    }

    return eligibleIntroductoryOffers[productId] ?? false;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}

SK2TransactionMessage createPendingTransaction(String id, {int quantity = 1}) {
  return SK2TransactionMessage(
    id: 1,
    originalId: 2,
    productId: id,
    purchaseDate: 'purchaseDate',
    appAccountToken: 'appAccountToken',
    receiptData: 'receiptData',
    jsonRepresentation: 'jsonRepresentation',
  );
}
