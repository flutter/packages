// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  objcHeaderOut: 'darwin/Classes/messages.g.h',
  objcSourceOut: 'darwin/Classes/messages.g.m',
  objcOptions: ObjcOptions(
    prefix: 'FIA',
  ),
  copyrightHeader: 'pigeons/copyright.txt',
))
class SKPaymentTransactionMessage {
  SKPaymentTransactionMessage({
    required this.payment,
    required this.transactionState,
    this.originalTransaction,
    this.transactionTimeStamp,
    this.transactionIdentifier,
    this.error,
  });

  final SKPaymentMessage payment;
  final SKPaymentTransactionStateMessage transactionState;
  final SKPaymentTransactionMessage? originalTransaction;
  final double? transactionTimeStamp;
  final String? transactionIdentifier;
  final SKErrorMessage? error;
}

enum SKPaymentTransactionStateMessage {
  /// Indicates the transaction is being processed in App Store.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state. Never complete a transaction that
  /// is still in a purchasing state.
  purchasing,

  /// The user's payment has been succesfully processed.
  ///
  /// You should provide the user the content that they purchased.
  purchased,

  /// The transaction failed.
  ///
  /// Check the [PaymentTransactionWrapper.error] property from
  /// [PaymentTransactionWrapper] for details.
  failed,

  /// This transaction is restoring content previously purchased by the user.
  ///
  /// The previous transaction information can be obtained in
  /// [PaymentTransactionWrapper.originalTransaction] from
  /// [PaymentTransactionWrapper].
  restored,

  /// The transaction is in the queue but pending external action. Wait for
  /// another callback to get the final state.
  ///
  /// You should update your UI to indicate that you are waiting for the
  /// transaction to update to another state.
  deferred,

  /// Indicates the transaction is in an unspecified state.
  unspecified,
}

class SKPaymentMessage {
  /// Creates a new [SKPaymentWrapper] with the provided information.
  const SKPaymentMessage({
    required this.productIdentifier,
    this.applicationUsername,
    this.requestData,
    this.quantity = 1,
    this.simulatesAskToBuyInSandbox = false,
    this.paymentDiscount,
  });

  final String productIdentifier;
  final String? applicationUsername;
  final String? requestData;
  final int quantity;
  final bool simulatesAskToBuyInSandbox;
  final SKPaymentDiscountMessage? paymentDiscount;
}

class SKErrorMessage {
  const SKErrorMessage(
      {required this.code, required this.domain, required this.userInfo});

  final int code;
  final String domain;
  final Map<String, Object>? userInfo;
}

class SKPaymentDiscountMessage {
  const SKPaymentDiscountMessage({
    required this.identifier,
    required this.keyIdentifier,
    required this.nonce,
    required this.signature,
    required this.timestamp,
  });

  final String identifier;
  final String keyIdentifier;
  final String nonce;
  final String signature;
  final int timestamp;
}

class SKStorefrontMessage {
  const SKStorefrontMessage({
    required this.countryCode,
    required this.identifier,
  });

  final String countryCode;
  final String identifier;
}

class SKProductsResponseMessage {
  const SKProductsResponseMessage(
      {required this.products, required this.invalidProductIdentifiers});
  final List<SKProductMessage>? products;
  final List<String>? invalidProductIdentifiers;
}

class SKProductMessage {
  const SKProductMessage(
      {required this.productIdentifier,
      required this.localizedTitle,
      required this.priceLocale,
      required this.price,
      this.localizedDescription,
      this.subscriptionGroupIdentifier,
      this.subscriptionPeriod,
      this.introductoryPrice,
      this.discounts});

  final String productIdentifier;
  final String localizedTitle;
  // This field should be nullable to handle occasional nulls in the StoreKit
  // object despite the the StoreKit header showing that it is nonnullable
  // https://github.com/flutter/flutter/issues/154047
  final String? localizedDescription;
  final SKPriceLocaleMessage priceLocale;
  final String? subscriptionGroupIdentifier;
  final String price;
  final SKProductSubscriptionPeriodMessage? subscriptionPeriod;
  final SKProductDiscountMessage? introductoryPrice;
  final List<SKProductDiscountMessage>? discounts;
}

class SKPriceLocaleMessage {
  SKPriceLocaleMessage({
    required this.currencySymbol,
    required this.currencyCode,
    required this.countryCode,
  });

  ///The currency symbol for the locale, e.g. $ for US locale.
  final String currencySymbol;

  ///The currency code for the locale, e.g. USD for US locale.
  final String currencyCode;

  ///The country code for the locale, e.g. US for US locale.
  final String countryCode;
}

class SKProductDiscountMessage {
  const SKProductDiscountMessage(
      {required this.price,
      required this.priceLocale,
      required this.numberOfPeriods,
      required this.paymentMode,
      required this.subscriptionPeriod,
      required this.identifier,
      required this.type});

  final String price;
  final SKPriceLocaleMessage priceLocale;
  final int numberOfPeriods;
  final SKProductDiscountPaymentModeMessage paymentMode;
  final SKProductSubscriptionPeriodMessage subscriptionPeriod;
  final String? identifier;
  final SKProductDiscountTypeMessage type;
}

enum SKProductDiscountTypeMessage {
  /// A constant indicating the discount type is an introductory offer.
  introductory,

  /// A constant indicating the discount type is a promotional offer.
  subscription,
}

enum SKProductDiscountPaymentModeMessage {
  /// Allows user to pay the discounted price at each payment period.
  payAsYouGo,

  /// Allows user to pay the discounted price upfront and receive the product for the rest of time that was paid for.
  payUpFront,

  /// User pays nothing during the discounted period.
  freeTrial,

  /// Unspecified mode.
  unspecified,
}

class SKProductSubscriptionPeriodMessage {
  SKProductSubscriptionPeriodMessage(
      {required this.numberOfUnits, required this.unit});

  final int numberOfUnits;
  final SKSubscriptionPeriodUnitMessage unit;
}

enum SKSubscriptionPeriodUnitMessage {
  day,
  week,
  month,
  year,
}

@HostApi(dartHostTestHandler: 'TestInAppPurchaseApi')
abstract class InAppPurchaseAPI {
  /// Returns if the current device is able to make payments
  bool canMakePayments();

  List<SKPaymentTransactionMessage> transactions();

  SKStorefrontMessage storefront();

  void addPayment(Map<String, Object?> paymentMap);

  @async
  SKProductsResponseMessage startProductRequest(
      List<String> productIdentifiers);

  void finishTransaction(Map<String, Object?> finishMap);

  void restoreTransactions(String? applicationUserName);

  void presentCodeRedemptionSheet();

  String? retrieveReceiptData();

  @async
  void refreshReceipt({Map<String, Object?>? receiptProperties});

  void startObservingPaymentQueue();

  void stopObservingPaymentQueue();

  void registerPaymentQueueDelegate();

  void removePaymentQueueDelegate();

  void showPriceConsentIfNeeded();

  bool supportsStoreKit2();
}
