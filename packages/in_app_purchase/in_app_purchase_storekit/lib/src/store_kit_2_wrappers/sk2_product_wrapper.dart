// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import '../messages2.g.dart';

InAppPurchase2API _hostApi = InAppPurchase2API();

/// https://developer.apple.com/documentation/storekit/product/producttype
/// The types of in-app purchases.
enum SK2ProductType {
  /// A consumable in-app purchase.
  consumable,

  /// A non-consumable in-app purchase.
  nonConsumable,

  /// A non-renewing subscription.
  nonRenewable,

  /// An auto-renewable subscription.
  autoRenewable;
}

extension on SK2ProductTypeMessage {
  /// Convert the equivalent pigeon class of [SK2ProductTypeMessage] into an instance of [SK2ProductType]
  SK2ProductType convertFromPigeon() {
    switch (this) {
      case SK2ProductTypeMessage.autoRenewable:
        return SK2ProductType.autoRenewable;
      case SK2ProductTypeMessage.consumable:
        return SK2ProductType.consumable;
      case SK2ProductTypeMessage.nonConsumable:
        return SK2ProductType.nonConsumable;
      case SK2ProductTypeMessage.nonRenewable:
        return SK2ProductType.nonRenewable;
    }
  }
}

enum SK2SubscriptionOfferType { introductory, promotional }

extension on SK2SubscriptionOfferTypeMessage {
  SK2SubscriptionOfferType convertFromPigeon() {
    switch (this) {
      case SK2SubscriptionOfferTypeMessage.introductory:
        return SK2SubscriptionOfferType.introductory;
      case SK2SubscriptionOfferTypeMessage.promotional:
        return SK2SubscriptionOfferType.promotional;
    }
  }
}

class SK2SubscriptionOffer {
  const SK2SubscriptionOffer({
    this.id,
    required this.price,
    required this.type,
    required this.period,
    required this.periodCount,
    required this.paymentMode,
  });
  final String? id;
  final double price;
  final SK2SubscriptionOfferType type;
  final SK2SubscriptionPeriod period;
  final int periodCount;
  final SK2SubscriptionOfferPaymentMode paymentMode;
}

extension on SK2SubscriptionOfferMessage {
  SK2SubscriptionOffer convertFromPigeon() {
    return SK2SubscriptionOffer(
        id: id,
        price: price,
        type: type.convertFromPigeon(),
        period: period.convertFromPigeon(),
        periodCount: periodCount,
        paymentMode: paymentMode.convertFromPigeon());
  }
}

/// https://developer.apple.com/documentation/storekit/product/subscriptioninfo
/// Information about an auto-renewable subscription, such as its status, period, subscription group, and subscription offer details.
class SK2SubscriptionInfo {
  /// Constructor
  const SK2SubscriptionInfo({
    required this.subscriptionGroupID,
    required this.promotionalOffers,
    required this.subscriptionPeriod,
  });

  /// An array of all the promotional offers configured for this subscription.
  final List<SK2SubscriptionOffer> promotionalOffers;

  /// The group identifier for this subscription.
  final String subscriptionGroupID;

  /// The duration that this subscription lasts before auto-renewing.
  final SK2SubscriptionPeriod subscriptionPeriod;
}

extension on SK2SubscriptionInfoMessage {
  SK2SubscriptionInfo convertFromPigeon() {
    return SK2SubscriptionInfo(
        subscriptionGroupID: subscriptionGroupID,
        // Note that promotionalOffers should NOT be nullable, but is only declared
        // so because of pigeon weirdness. There should be NO NULLS.
        promotionalOffers: promotionalOffers
            .whereType<SK2SubscriptionOfferMessage>()
            .map((SK2SubscriptionOfferMessage offer) =>
                offer.convertFromPigeon())
            .toList(),
        subscriptionPeriod: subscriptionPeriod.convertFromPigeon());
  }
}

/// https://developer.apple.com/documentation/storekit/product/subscriptionperiod?changes=latest_minor
/// Values that represent the duration of time between subscription renewals.
class SK2SubscriptionPeriod {
  const SK2SubscriptionPeriod({required this.value, required this.unit});

  /// The number of units that the period represents.
  final int value;

  /// The unit of time that this period represents.
  final SK2SubscriptionPeriodUnit unit;
}

extension on SK2SubscriptionPeriodMessage {
  SK2SubscriptionPeriod convertFromPigeon() {
    return SK2SubscriptionPeriod(value: value, unit: unit.convertFromPigeon());
  }
}

/// https://developer.apple.com/documentation/storekit/product/subscriptionperiod/3749576-unit
/// The increment of time for the subscription period.
enum SK2SubscriptionPeriodUnit {
  /// A subscription period unit of a day.
  day,

  /// A subscription period unit of a week.
  week,

  /// A subscription period unit of a month.
  month,

  /// A subscription period unit of a year.
  year
}

extension on SK2SubscriptionPeriodUnitMessage {
  SK2SubscriptionPeriodUnit convertFromPigeon() {
    switch (this) {
      case SK2SubscriptionPeriodUnitMessage.day:
        return SK2SubscriptionPeriodUnit.day;
      case SK2SubscriptionPeriodUnitMessage.week:
        return SK2SubscriptionPeriodUnit.week;
      case SK2SubscriptionPeriodUnitMessage.month:
        return SK2SubscriptionPeriodUnit.month;
      case SK2SubscriptionPeriodUnitMessage.year:
        return SK2SubscriptionPeriodUnit.year;
    }
  }
}

/// https://developer.apple.com/documentation/storekit/product/subscriptionoffer/paymentmode
/// The payment modes for subscription offers that apply to a transaction.
enum SK2SubscriptionOfferPaymentMode {
  /// A payment mode of a product discount that applies over a single billing period or multiple billing periods.
  payAsYouGo,

  /// A payment mode of a product discount that applies the discount up front.
  payUpFront,

  /// A payment mode of a product discount that indicates a free trial offer.
  freeTrial;
}

extension on SK2SubscriptionOfferPaymentModeMessage {
  SK2SubscriptionOfferPaymentMode convertFromPigeon() {
    switch (this) {
      case SK2SubscriptionOfferPaymentModeMessage.payAsYouGo:
        return SK2SubscriptionOfferPaymentMode.payAsYouGo;
      case SK2SubscriptionOfferPaymentModeMessage.payUpFront:
        return SK2SubscriptionOfferPaymentMode.payUpFront;
      case SK2SubscriptionOfferPaymentModeMessage.freeTrial:
        return SK2SubscriptionOfferPaymentMode.freeTrial;
    }
  }
}

class SK2PriceLocale {
  SK2PriceLocale({
    required this.currencyCode,
    required this.currencySymbol
});
final String currencyCode;
  final String currencySymbol;
}

extension on SK2PriceLocaleMessage {
  SK2PriceLocale convertFromPigeon() {
    return SK2PriceLocale(
        currencyCode: currencyCode,
        currencySymbol: currencySymbol);
  }
}

/// Dart wrapper around StoreKit2's [Product](https://developer.apple.com/documentation/storekit/product).
///
/// The Product type represents the in-app purchases that you configure in
/// App Store Connect and make available for purchase within your app.
class SK2Product {
  /// Creates a new [SKStorefrontWrapper] with the provided information.
  SK2Product({
    required this.id,
    required this.displayName,
    required this.displayPrice,
    required this.description,
    required this.price,
    required this.type,
    required this.priceLocale,
    this.subscription,
  });

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
  final SK2ProductType type;

  /// The subscription information for an auto-renewable subscription.
  final SK2SubscriptionInfo? subscription;

  /// The locale and currency information for this product.
  final SK2PriceLocale priceLocale;

  /// https://developer.apple.com/documentation/storekit/product/3851116-products
  /// Given a list of identifiers, return a list of products
  /// If any of the identifiers are invalid or can't be found, they are excluded
  /// from the returned list.
  static Future<List<SK2Product>> products(List<String> identifiers) async {
    final List<SK2ProductMessage?> productsMsg =
        await _hostApi.products(identifiers);
    if (productsMsg.isEmpty && identifiers.isNotEmpty) {
      throw PlatformException(
        code: 'storekit_no_response',
        message: 'StoreKit: Failed to get response from platform.',
      );
    }

    return productsMsg
        .whereType<SK2ProductMessage>()
        .map((SK2ProductMessage product) => product.convertFromPigeon())
        .toList();
  }
}

extension on SK2ProductMessage {
  SK2Product convertFromPigeon() {
    return SK2Product(
        id: id,
        displayName: displayName,
        displayPrice: displayPrice,
        price: price,
        description: description,
        type: type.convertFromPigeon(),
        subscription: subscription?.convertFromPigeon(),
        priceLocale: priceLocale.convertFromPigeon());
  }
}
