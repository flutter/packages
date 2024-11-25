// Copyright 2013 The Flutter Authors. All rights reserved.
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

import '../sk2_test_api.g.dart';
import '../store_kit_wrappers/sk_test_stub_objects.dart';
import '../test_api.g.dart';

class FakeStoreKitPlatform implements TestInAppPurchaseApi {
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

  void reset() {
    transactionList = <SKPaymentTransactionWrapper>[];
    receiptData = 'dummy base64data';
    validProductIDs = <String>{'123', '456', '789'};
    validProducts = <String, SKProductWrapper>{};
    for (final String validID in validProductIDs) {
      final Map<String, dynamic> productWrapperMap =
          buildProductMap(dummyProductWrapper);
      productWrapperMap['productIdentifier'] = validID;
      if (validID == '456') {
        productWrapperMap['priceLocale'] = buildLocaleMap(noSymbolLocale);
      }
      if (validID == '789') {
        productWrapperMap['localizedDescription'] = null;
      }
      validProducts[validID] = SKProductWrapper.fromJson(productWrapperMap);
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

  SKPaymentTransactionWrapper createPendingTransaction(String id,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
      transactionIdentifier: '',
      payment: SKPaymentWrapper(productIdentifier: id, quantity: quantity),
      transactionState: SKPaymentTransactionStateWrapper.purchasing,
      transactionTimeStamp: 123123.121,
    );
  }

  SKPaymentTransactionWrapper createPurchasedTransaction(
      String productId, String transactionId,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.purchased,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: transactionId);
  }

  SKPaymentTransactionWrapper createFailedTransaction(String productId,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        transactionIdentifier: '',
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionTimeStamp: 123123.121,
        error: const SKError(
            code: 0,
            domain: 'ios_domain',
            userInfo: <String, Object>{'message': 'an error message'}));
  }

  SKPaymentTransactionWrapper createCanceledTransaction(
      String productId, int errorCode,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        transactionIdentifier: '',
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.failed,
        transactionTimeStamp: 123123.121,
        error: SKError(
            code: errorCode,
            domain: 'ios_domain',
            userInfo: const <String, Object>{'message': 'an error message'}));
  }

  SKPaymentTransactionWrapper createRestoredTransaction(
      String productId, String transactionId,
      {int quantity = 1}) {
    return SKPaymentTransactionWrapper(
        payment:
            SKPaymentWrapper(productIdentifier: productId, quantity: quantity),
        transactionState: SKPaymentTransactionStateWrapper.restored,
        transactionTimeStamp: 123123.121,
        transactionIdentifier: transactionId);
  }

  @override
  bool canMakePayments() {
    return true;
  }

  @override
  void addPayment(Map<String?, Object?> paymentMap) {
    final String id = paymentMap['productIdentifier']! as String;
    final int quantity = paymentMap['quantity']! as int;

    // Keep the received paymentDiscount parameter when testing payment with discount.
    if (paymentMap['applicationUsername']! == 'userWithDiscount') {
      final Map<Object?, Object?>? discountArgument =
          paymentMap['paymentDiscount'] as Map<Object?, Object?>?;
      if (discountArgument != null) {
        discountReceived = discountArgument.cast<String, Object?>();
      } else {
        discountReceived = <String, Object?>{};
      }
    }

    final SKPaymentTransactionWrapper transaction =
        createPendingTransaction(id, quantity: quantity);
    transactionList.add(transaction);
    InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
        transactions: <SKPaymentTransactionWrapper>[transaction]);
    if (testTransactionFail) {
      final SKPaymentTransactionWrapper transactionFailed =
          createFailedTransaction(id, quantity: quantity);
      InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
          transactions: <SKPaymentTransactionWrapper>[transactionFailed]);
    } else if (testTransactionCancel > 0) {
      final SKPaymentTransactionWrapper transactionCanceled =
          createCanceledTransaction(id, testTransactionCancel,
              quantity: quantity);
      InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
          transactions: <SKPaymentTransactionWrapper>[transactionCanceled]);
    } else {
      final SKPaymentTransactionWrapper transactionFinished =
          createPurchasedTransaction(
              id, transaction.transactionIdentifier ?? '',
              quantity: quantity);
      InAppPurchaseStoreKitPlatform.observer.updatedTransactions(
          transactions: <SKPaymentTransactionWrapper>[transactionFinished]);
    }
  }

  void setStoreFrontInfo(
      {required String countryCode, required String identifier}) {
    _countryCode = countryCode;
    _countryIdentifier = identifier;
  }

  @override
  SKStorefrontMessage storefront() {
    return SKStorefrontMessage(
        countryCode: _countryCode, identifier: _countryIdentifier);
  }

  @override
  List<SKPaymentTransactionMessage> transactions() {
    throw UnimplementedError();
  }

  @override
  void finishTransaction(Map<String?, Object?> finishMap) {
    finishedTransactions.add(createPurchasedTransaction(
        finishMap['productIdentifier']! as String,
        finishMap['transactionIdentifier']! as String,
        quantity: transactionList.first.payment.quantity));
  }

  @override
  void presentCodeRedemptionSheet() {}

  @override
  void restoreTransactions(String? applicationUserName) {
    if (restoreException != null) {
      throw restoreException!;
    }
    if (testRestoredError != null) {
      InAppPurchaseStoreKitPlatform.observer
          .restoreCompletedTransactionsFailed(error: testRestoredError!);
      return;
    }
    if (!testRestoredTransactionsNull) {
      InAppPurchaseStoreKitPlatform.observer
          .updatedTransactions(transactions: transactionList);
    }
    InAppPurchaseStoreKitPlatform.observer
        .paymentQueueRestoreCompletedTransactionsFinished();
  }

  @override
  Future<SKProductsResponseMessage> startProductRequest(
      List<String?> productIdentifiers) {
    if (queryProductException != null) {
      throw queryProductException!;
    }
    final List<String?> productIDS = productIdentifiers;
    final List<String> invalidFound = <String>[];
    final List<SKProductWrapper> products = <SKProductWrapper>[];
    for (final String? productID in productIDS) {
      if (!validProductIDs.contains(productID)) {
        invalidFound.add(productID!);
      } else {
        products.add(validProducts[productID]!);
      }
    }
    final SkProductResponseWrapper response = SkProductResponseWrapper(
        products: products, invalidProductIdentifiers: invalidFound);

    return Future<SKProductsResponseMessage>.value(
        SkProductResponseWrapper.convertToPigeon(response));
  }

  @override
  Future<void> refreshReceipt({Map<String?, dynamic>? receiptProperties}) {
    receiptData = 'refreshed receipt data';
    return Future<void>.sync(() {});
  }

  @override
  void registerPaymentQueueDelegate() {
    isPaymentQueueDelegateRegistered = true;
  }

  @override
  void removePaymentQueueDelegate() {
    isPaymentQueueDelegateRegistered = false;
  }

  @override
  String retrieveReceiptData() {
    if (receiptData != null) {
      return receiptData!;
    } else {
      throw PlatformException(code: 'no_receipt_data');
    }
  }

  @override
  void showPriceConsentIfNeeded() {}

  @override
  void startObservingPaymentQueue() {
    queueIsActive = true;
  }

  @override
  void stopObservingPaymentQueue() {
    queueIsActive = false;
  }

  @override
  bool supportsStoreKit2() {
    return true;
  }
}

class FakeStoreKit2Platform implements TestInAppPurchase2Api {
  late Set<String> validProductIDs;
  late Map<String, SK2Product> validProducts;
  late List<SK2TransactionMessage> transactionList = <SK2TransactionMessage>[];
  late bool testTransactionFail;
  late int testTransactionCancel;
  late List<SK2Transaction> finishedTransactions;

  PlatformException? queryProductException;
  bool isListenerRegistered = false;

  void reset() {
    validProductIDs = <String>{'123', '456'};
    validProducts = <String, SK2Product>{};
    for (final String validID in validProductIDs) {
      final SK2Product product = SK2Product(
          id: validID,
          displayName: 'test_product',
          displayPrice: '0.99',
          description: 'description',
          price: 0.99,
          type: SK2ProductType.consumable,
          priceLocale:
              SK2PriceLocale(currencyCode: 'USD', currencySymbol: r'$'));
      validProducts[validID] = product;
    }
  }

  SK2TransactionMessage createRestoredTransaction(
      String productId, String transactionId,
      {int quantity = 1}) {
    return SK2TransactionMessage(
        id: 123,
        originalId: 321,
        productId: '',
        purchaseDate: '',
        appAccountToken: '',
        restoring: true);
  }

  @override
  bool canMakePayments() {
    return true;
  }

  @override
  Future<List<SK2ProductMessage>> products(List<String?> identifiers) {
    if (queryProductException != null) {
      throw queryProductException!;
    }
    final List<String?> productIDS = identifiers;
    final List<SK2Product> products = <SK2Product>[];
    for (final String? productID in productIDS) {
      if (validProductIDs.contains(productID)) {
        products.add(validProducts[productID]!);
      }
    }
    final List<SK2ProductMessage> result = <SK2ProductMessage>[];
    for (final SK2Product p in products) {
      result.add(p.convertToPigeon());
    }

    return Future<List<SK2ProductMessage>>.value(result);
  }

  @override
  Future<SK2ProductPurchaseResultMessage> purchase(String id,
      {SK2ProductPurchaseOptionsMessage? options}) {
    final SK2TransactionMessage transaction = createPendingTransaction(id);

    InAppPurchaseStoreKitPlatform.sk2TransactionObserver
        .onTransactionsUpdated(<SK2TransactionMessage>[transaction]);
    return Future<SK2ProductPurchaseResultMessage>.value(
        SK2ProductPurchaseResultMessage.success);
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
          purchaseDate: '12-12')
    ]);
  }

  @override
  void startListeningToTransactions() {
    isListenerRegistered = true;
  }

  @override
  void stopListeningToTransactions() {
    isListenerRegistered = false;
  }

  @override
  Future<void> restorePurchases() async {
    InAppPurchaseStoreKitPlatform.sk2TransactionObserver
        .onTransactionsUpdated(transactionList);
  }
}

SK2TransactionMessage createPendingTransaction(String id, {int quantity = 1}) {
  return SK2TransactionMessage(
      id: 1,
      originalId: 2,
      productId: id,
      purchaseDate: 'purchaseDate',
      appAccountToken: 'appAccountToken');
}
