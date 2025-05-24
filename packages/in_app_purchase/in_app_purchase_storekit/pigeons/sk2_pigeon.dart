// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/sk2_pigeon.g.dart',
  dartTestOut: 'test/sk2_test_api.g.dart',
  swiftOut:
      'darwin/in_app_purchase_storekit/Sources/in_app_purchase_storekit/StoreKit2/sk2_pigeon.g.swift',
  copyrightHeader: 'pigeons/copyright.txt',
))
enum SK2ProductTypeMessage {
  /// A consumable in-app purchase.
  consumable,

  /// A non-consumable in-app purchase.
  nonConsumable,

  /// A non-renewing subscription.
  nonRenewable,

  /// An auto-renewable subscription.
  autoRenewable
}

enum SK2SubscriptionOfferTypeMessage {
  introductory,
  promotional,
  winBack,
}

enum SK2SubscriptionOfferPaymentModeMessage {
  payAsYouGo,
  payUpFront,
  freeTrial,
}

class SK2SubscriptionOfferMessage {
  const SK2SubscriptionOfferMessage({
    this.id,
    required this.price,
    required this.type,
    required this.period,
    required this.periodCount,
    required this.paymentMode,
  });
  final String? id;
  final double price;
  final SK2SubscriptionOfferTypeMessage type;
  final SK2SubscriptionPeriodMessage period;
  final int periodCount;
  final SK2SubscriptionOfferPaymentModeMessage paymentMode;
}

enum SK2SubscriptionPeriodUnitMessage { day, week, month, year }

class SK2SubscriptionPeriodMessage {
  const SK2SubscriptionPeriodMessage({required this.value, required this.unit});

  /// The number of units that the period represents.
  final int value;

  /// The unit of time that this period represents.
  final SK2SubscriptionPeriodUnitMessage unit;
}

class SK2SubscriptionInfoMessage {
  const SK2SubscriptionInfoMessage({
    required this.subscriptionGroupID,
    required this.promotionalOffers,
    required this.subscriptionPeriod,
  });

  /// An array of all the promotional offers configured for this subscription.
  final List<SK2SubscriptionOfferMessage> promotionalOffers;

  /// The group identifier for this subscription.
  final String subscriptionGroupID;

  /// The duration that this subscription lasts before auto-renewing.
  final SK2SubscriptionPeriodMessage subscriptionPeriod;
}

/// A Pigeon message class representing a Product
/// https://developer.apple.com/documentation/storekit/product
class SK2ProductMessage {
  const SK2ProductMessage(
      {required this.id,
      required this.displayName,
      required this.displayPrice,
      required this.description,
      required this.price,
      required this.type,
      this.subscription,
      required this.priceLocale});

  /// The unique product identifier.
  final String id;

  /// The localized display name of the product, if it exists.
  final String displayName;

  /// The localized description of the product.
  final String description;

  /// The localized string representation of the product price, suitable for display.
  final double price;

  /// The localized price of the product as a string.
  final String displayPrice;

  /// The types of in-app purchases.
  final SK2ProductTypeMessage type;

  /// The subscription information for an auto-renewable subscription.
  final SK2SubscriptionInfoMessage? subscription;

  /// The currency and locale information for this product
  final SK2PriceLocaleMessage priceLocale;
}

class SK2PriceLocaleMessage {
  SK2PriceLocaleMessage({
    required this.currencyCode,
    required this.currencySymbol,
  });

  final String currencyCode;
  final String currencySymbol;
}

/// A Pigeon message class representing a Signature
/// https://developer.apple.com/documentation/storekit/product/subscriptionoffer/signature
class SK2SubscriptionOfferSignatureMessage {
  SK2SubscriptionOfferSignatureMessage({
    required this.keyID,
    required this.nonce,
    required this.timestamp,
    required this.signature,
  });

  final String keyID;
  final String nonce;
  final int timestamp;
  final String signature;
}

class SK2SubscriptionOfferPurchaseMessage {
  SK2SubscriptionOfferPurchaseMessage({
    required this.promotionalOfferId,
    required this.promotionalOfferSignature,
  });

  final String promotionalOfferId;
  final SK2SubscriptionOfferSignatureMessage promotionalOfferSignature;
}

class SK2ProductPurchaseOptionsMessage {
  SK2ProductPurchaseOptionsMessage({
    this.appAccountToken,
    this.quantity = 1,
    this.promotionalOffer,
    this.winBackOfferId,
  });

  final String? appAccountToken;
  final int? quantity;
  final SK2SubscriptionOfferPurchaseMessage? promotionalOffer;
  final String? winBackOfferId;
}

class SK2TransactionMessage {
  SK2TransactionMessage(
      {required this.id,
      required this.originalId,
      required this.productId,
      required this.purchaseDate,
      this.expirationDate,
      this.purchasedQuantity = 1,
      this.appAccountToken,
      this.error,
      this.receiptData,
      this.jsonRepresentation,
      this.restoring = false});
  final int id;
  final int originalId;
  final String productId;
  final String purchaseDate;
  final String? expirationDate;
  final int purchasedQuantity;
  final String? appAccountToken;
  final bool restoring;
  final String? receiptData;
  final SK2ErrorMessage? error;
  final String? jsonRepresentation;
}

class SK2ErrorMessage {
  const SK2ErrorMessage(
      {required this.code, required this.domain, required this.userInfo});

  final int code;
  final String domain;
  final Map<String, Object>? userInfo;
}

enum SK2ProductPurchaseResultMessage { success, userCancelled, pending }

@HostApi(dartHostTestHandler: 'TestInAppPurchase2Api')
abstract class InAppPurchase2API {
  // https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments
  bool canMakePayments();

  // https://developer.apple.com/documentation/storekit/product/3851116-products
  @async
  List<SK2ProductMessage> products(List<String> identifiers);

  // https://developer.apple.com/documentation/storekit/product/3791971-purchase
  @async
  SK2ProductPurchaseResultMessage purchase(String id,
      {SK2ProductPurchaseOptionsMessage? options});

  @async
  bool isWinBackOfferEligible(String productId, String offerId);

  @async
  List<SK2TransactionMessage> transactions();

  @async
  void finish(int id);

  void startListeningToTransactions();

  void stopListeningToTransactions();

  @async
  void restorePurchases();

  @async
  String countryCode();

  @async
  void sync();
}

@FlutterApi()
abstract class InAppPurchase2CallbackAPI {
  void onTransactionsUpdated(List<SK2TransactionMessage> newTransactions);
}
