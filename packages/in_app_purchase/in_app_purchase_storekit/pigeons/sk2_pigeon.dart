// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/sk2_pigeon.g.dart',
  dartTestOut: 'test/sk2_test_api.g.dart',
  swiftOut: 'darwin/Classes/StoreKit2/sk2_pigeon.g.swift',
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

enum SK2SubscriptionOfferTypeMessage { introductory, promotional }

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
  /// This should be List<SK2SubscriptionOfferMessage> but pigeon doesnt support
  /// null-safe generics. https://github.com/flutter/flutter/issues/97848
  final List<SK2SubscriptionOfferMessage?> promotionalOffers;

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

@HostApi(dartHostTestHandler: 'TestInAppPurchase2Api')
abstract class InAppPurchase2API {
  // https://developer.apple.com/documentation/storekit/appstore/3822277-canmakepayments
  // SK1 canMakePayments
  bool canMakePayments();

  // https://developer.apple.com/documentation/storekit/product/3851116-products
  // SK1 startProductRequest
  @async
  List<SK2ProductMessage> products(List<String> identifiers);
}
