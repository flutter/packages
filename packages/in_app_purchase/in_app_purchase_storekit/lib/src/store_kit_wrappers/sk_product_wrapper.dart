// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../messages.g.dart';
import 'enum_converters.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'sk_product_wrapper.g.dart';

/// Dart wrapper around StoreKit's [SKProductsResponse](https://developer.apple.com/documentation/storekit/skproductsresponse?language=objc).
///
/// Represents the response object returned by [SKRequestMaker.startProductRequest].
/// Contains information about a list of products and a list of invalid product identifiers.
@JsonSerializable()
@immutable
class SkProductResponseWrapper {
  /// Creates an [SkProductResponseWrapper] with the given product details.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SkProductResponseWrapper(
      {required this.products, required this.invalidProductIdentifiers});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKRequestMaker.startProductRequest].
  factory SkProductResponseWrapper.fromJson(Map<String, dynamic> map) {
    return _$SkProductResponseWrapperFromJson(map);
  }

  /// Stores all matching successfully found products.
  ///
  /// One product in this list matches one valid product identifier passed to the [SKRequestMaker.startProductRequest].
  /// Will be empty if the [SKRequestMaker.startProductRequest] method does not pass any correct product identifier.
  @JsonKey(defaultValue: <SKProductWrapper>[])
  final List<SKProductWrapper> products;

  /// Stores product identifiers in the `productIdentifiers` from [SKRequestMaker.startProductRequest] that are not recognized by the App Store.
  ///
  /// The App Store will not recognize a product identifier unless certain criteria are met. A detailed list of the criteria can be
  /// found here https://developer.apple.com/documentation/storekit/skproductsresponse/1505985-invalidproductidentifiers?language=objc.
  /// Will be empty if all the product identifiers are valid.
  @JsonKey(defaultValue: <String>[])
  final List<String> invalidProductIdentifiers;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SkProductResponseWrapper &&
        const DeepCollectionEquality().equals(other.products, products) &&
        const DeepCollectionEquality()
            .equals(other.invalidProductIdentifiers, invalidProductIdentifiers);
  }

  @override
  int get hashCode => Object.hash(products, invalidProductIdentifiers);

  /// Convert from [SkProductResponseMessage] to [SkProductResponseWrapper]
  static SkProductResponseWrapper convertFromPigeon(
      SKProductsResponseMessage msg) {
    return SkProductResponseWrapper(
      products: msg.products!
          .map((SKProductMessage e) => SKProductWrapper.convertFromPigeon(e))
          .toList(),
      invalidProductIdentifiers: msg.invalidProductIdentifiers ?? <String>[],
    );
  }

  /// Convert from [SkProductResponseWrapper] to [SkProductResponseWrapper]
  @visibleForTesting
  static SKProductsResponseMessage convertToPigeon(
      SkProductResponseWrapper wrapper) {
    return SKProductsResponseMessage(
        products: wrapper.products
            .map((SKProductWrapper e) => SKProductWrapper.convertToPigeon(e))
            .toList(),
        invalidProductIdentifiers: wrapper.invalidProductIdentifiers);
  }
}

/// Dart wrapper around StoreKit's [SKProductPeriodUnit](https://developer.apple.com/documentation/storekit/skproductperiodunit?language=objc).
///
/// Used as a property in the [SKProductSubscriptionPeriodWrapper]. Minimum is a day and maximum is a year.
// The values of the enum options are matching the [SKProductPeriodUnit]'s values. Should there be an update or addition
// in the [SKProductPeriodUnit], this need to be updated to match.
enum SKSubscriptionPeriodUnit {
  /// An interval lasting one day.
  @JsonValue(0)
  day,

  /// An interval lasting one month.
  @JsonValue(1)

  /// An interval lasting one week.
  week,
  @JsonValue(2)

  /// An interval lasting one month.
  month,

  /// An interval lasting one year.
  @JsonValue(3)
  year;

  /// Convert from [SKSubscriptionPeriodUnitMessage] to [SKSubscriptionPeriodUnit]
  static SKSubscriptionPeriodUnit convertFromPigeon(
      SKSubscriptionPeriodUnitMessage msg) {
    switch (msg) {
      case SKSubscriptionPeriodUnitMessage.day:
        return SKSubscriptionPeriodUnit.day;
      case SKSubscriptionPeriodUnitMessage.week:
        return SKSubscriptionPeriodUnit.week;
      case SKSubscriptionPeriodUnitMessage.month:
        return SKSubscriptionPeriodUnit.month;
      case SKSubscriptionPeriodUnitMessage.year:
        return SKSubscriptionPeriodUnit.year;
    }
  }

  /// Convert from [SKSubscriptionPeriodUnit] to [SKSubscriptionPeriodUnitMessage]
  @visibleForTesting
  static SKSubscriptionPeriodUnitMessage convertToPigeon(
      SKSubscriptionPeriodUnit msg) {
    switch (msg) {
      case SKSubscriptionPeriodUnit.day:
        return SKSubscriptionPeriodUnitMessage.day;
      case SKSubscriptionPeriodUnit.week:
        return SKSubscriptionPeriodUnitMessage.week;
      case SKSubscriptionPeriodUnit.month:
        return SKSubscriptionPeriodUnitMessage.month;
      case SKSubscriptionPeriodUnit.year:
        return SKSubscriptionPeriodUnitMessage.year;
    }
  }
}

/// Dart wrapper around StoreKit's [SKProductSubscriptionPeriod](https://developer.apple.com/documentation/storekit/skproductsubscriptionperiod?language=objc).
///
/// A period is defined by a [numberOfUnits] and a [unit], e.g for a 3 months period [numberOfUnits] is 3 and [unit] is a month.
/// It is used as a property in [SKProductDiscountWrapper] and [SKProductWrapper].
@JsonSerializable()
@immutable
class SKProductSubscriptionPeriodWrapper {
  /// Creates an [SKProductSubscriptionPeriodWrapper] for a `numberOfUnits`x`unit` period.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SKProductSubscriptionPeriodWrapper(
      {required this.numberOfUnits, required this.unit});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKProductDiscountWrapper.fromJson] or [SKProductWrapper.fromJson].
  factory SKProductSubscriptionPeriodWrapper.fromJson(
      Map<String, dynamic>? map) {
    if (map == null) {
      return SKProductSubscriptionPeriodWrapper(
          numberOfUnits: 0, unit: SKSubscriptionPeriodUnit.day);
    }
    return _$SKProductSubscriptionPeriodWrapperFromJson(map);
  }

  /// The number of [unit] units in this period.
  ///
  /// Must be greater than 0 if the object is valid.
  @JsonKey(defaultValue: 0)
  final int numberOfUnits;

  /// The time unit used to specify the length of this period.
  @SKSubscriptionPeriodUnitConverter()
  final SKSubscriptionPeriodUnit unit;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKProductSubscriptionPeriodWrapper &&
        other.numberOfUnits == numberOfUnits &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(numberOfUnits, unit);

  /// Convert from [SKProductSubscriptionPeriodMessage] to [SKProductSubscriptionPeriodWrapper]
  static SKProductSubscriptionPeriodWrapper convertFromPigeon(
      SKProductSubscriptionPeriodMessage msg) {
    return SKProductSubscriptionPeriodWrapper(
        numberOfUnits: msg.numberOfUnits,
        unit: SKSubscriptionPeriodUnit.convertFromPigeon(msg.unit));
  }

  /// Convert from [SKProductSubscriptionPeriodWrapper] to [SKProductSubscriptionPeriodMessage]
  @visibleForTesting
  static SKProductSubscriptionPeriodMessage convertToPigeon(
      SKProductSubscriptionPeriodWrapper wrapper) {
    return SKProductSubscriptionPeriodMessage(
        numberOfUnits: wrapper.numberOfUnits,
        unit: SKSubscriptionPeriodUnit.convertToPigeon(wrapper.unit));
  }
}

/// Dart wrapper around StoreKit's [SKProductDiscountPaymentMode](https://developer.apple.com/documentation/storekit/skproductdiscountpaymentmode?language=objc).
///
/// This is used as a property in the [SKProductDiscountWrapper].
// The values of the enum options are matching the [SKProductDiscountPaymentMode]'s values. Should there be an update or addition
// in the [SKProductDiscountPaymentMode], this need to be updated to match.
enum SKProductDiscountPaymentMode {
  /// Allows user to pay the discounted price at each payment period.
  @JsonValue(0)
  payAsYouGo,

  /// Allows user to pay the discounted price upfront and receive the product for the rest of time that was paid for.
  @JsonValue(1)
  payUpFront,

  /// User pays nothing during the discounted period.
  @JsonValue(2)
  freeTrail,

  /// Unspecified mode.
  @JsonValue(-1)
  unspecified;

  /// Convert from [SKProductDiscountPaymentModeMessage] to [SKProductDiscountPaymentModeWrapper]
  static SKProductDiscountPaymentMode convertFromPigeon(
      SKProductDiscountPaymentModeMessage msg) {
    switch (msg) {
      case SKProductDiscountPaymentModeMessage.payAsYouGo:
        return SKProductDiscountPaymentMode.payAsYouGo;
      case SKProductDiscountPaymentModeMessage.payUpFront:
        return SKProductDiscountPaymentMode.payUpFront;
      case SKProductDiscountPaymentModeMessage.freeTrial:
        return SKProductDiscountPaymentMode.freeTrail;
      case SKProductDiscountPaymentModeMessage.unspecified:
        return SKProductDiscountPaymentMode.unspecified;
    }
  }

  /// Convert from [SKProductDiscountPaymentModeMessage] to [SKProductDiscountPaymentMode]
  @visibleForTesting
  static SKProductDiscountPaymentModeMessage convertToPigeon(
      SKProductDiscountPaymentMode wrapper) {
    switch (wrapper) {
      case SKProductDiscountPaymentMode.payAsYouGo:
        return SKProductDiscountPaymentModeMessage.payAsYouGo;
      case SKProductDiscountPaymentMode.payUpFront:
        return SKProductDiscountPaymentModeMessage.payUpFront;
      case SKProductDiscountPaymentMode.freeTrail:
        return SKProductDiscountPaymentModeMessage.freeTrial;
      case SKProductDiscountPaymentMode.unspecified:
        return SKProductDiscountPaymentModeMessage.unspecified;
    }
  }
}

/// Dart wrapper around StoreKit's [SKProductDiscountType]
/// (https://developer.apple.com/documentation/storekit/skproductdiscounttype?language=objc)
///
/// This is used as a property in the [SKProductDiscountWrapper].
/// The values of the enum options are matching the [SKProductDiscountType]'s
/// values.
///
/// Values representing the types of discount offers an app can present.
enum SKProductDiscountType {
  /// A constant indicating the discount type is an introductory offer.
  @JsonValue(0)
  introductory,

  /// A constant indicating the discount type is a promotional offer.
  @JsonValue(1)
  subscription;

  /// Convert from [SKProductDiscountTypeMessage] to [SKProductDiscountType]
  static SKProductDiscountType convertFromPigeon(
      SKProductDiscountTypeMessage msg) {
    switch (msg) {
      case SKProductDiscountTypeMessage.introductory:
        return SKProductDiscountType.introductory;
      case SKProductDiscountTypeMessage.subscription:
        return SKProductDiscountType.subscription;
    }
  }

  /// Convert from [SKProductDiscountType] to [SKProductDiscountTypeMessage]
  @visibleForTesting
  static SKProductDiscountTypeMessage convertToPigeon(
      SKProductDiscountType wrapper) {
    switch (wrapper) {
      case SKProductDiscountType.introductory:
        return SKProductDiscountTypeMessage.introductory;
      case SKProductDiscountType.subscription:
        return SKProductDiscountTypeMessage.subscription;
    }
  }
}

/// Dart wrapper around StoreKit's [SKProductDiscount](https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc).
///
/// It is used as a property in [SKProductWrapper].
@JsonSerializable()
@immutable
class SKProductDiscountWrapper {
  /// Creates an [SKProductDiscountWrapper] with the given discount details.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SKProductDiscountWrapper(
      {required this.price,
      required this.priceLocale,
      required this.numberOfPeriods,
      required this.paymentMode,
      required this.subscriptionPeriod,
      required this.identifier,
      required this.type});

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKProductWrapper.fromJson].
  factory SKProductDiscountWrapper.fromJson(Map<String, dynamic> map) {
    return _$SKProductDiscountWrapperFromJson(map);
  }

  /// The discounted price, in the currency that is defined in [priceLocale].
  @JsonKey(defaultValue: '')
  final String price;

  /// Includes locale information about the price, e.g. `$` as the currency symbol for US locale.
  final SKPriceLocaleWrapper priceLocale;

  /// The object represent the discount period length.
  ///
  /// The value must be >= 0 if the object is valid.
  @JsonKey(defaultValue: 0)
  final int numberOfPeriods;

  /// The object indicates how the discount price is charged.
  @SKProductDiscountPaymentModeConverter()
  final SKProductDiscountPaymentMode paymentMode;

  /// The object represents the duration of single subscription period for the discount.
  ///
  /// The [subscriptionPeriod] of the discount is independent of the product's [subscriptionPeriod],
  /// and their units and duration do not have to be matched.
  final SKProductSubscriptionPeriodWrapper subscriptionPeriod;

  /// A string used to uniquely identify a discount offer for a product.
  ///
  /// You set up offers and their identifiers in App Store Connect.
  @JsonKey(defaultValue: null)
  final String? identifier;

  /// Values representing the types of discount offers an app can present.
  @SKProductDiscountTypeConverter()
  final SKProductDiscountType type;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKProductDiscountWrapper &&
        other.price == price &&
        other.priceLocale == priceLocale &&
        other.numberOfPeriods == numberOfPeriods &&
        other.paymentMode == paymentMode &&
        other.subscriptionPeriod == subscriptionPeriod &&
        other.identifier == identifier &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(price, priceLocale, numberOfPeriods,
      paymentMode, subscriptionPeriod, identifier, type);

  /// Convert from [SKProductDiscountMessage] to [SKProductDiscountWrapper]
  static SKProductDiscountWrapper convertFromPigeon(
      SKProductDiscountMessage msg) {
    return SKProductDiscountWrapper(
        price: msg.price,
        priceLocale: SKPriceLocaleWrapper.convertFromPigeon(msg.priceLocale),
        numberOfPeriods: msg.numberOfPeriods,
        paymentMode:
            SKProductDiscountPaymentMode.convertFromPigeon(msg.paymentMode),
        subscriptionPeriod:
            SKProductSubscriptionPeriodWrapper.convertFromPigeon(
                msg.subscriptionPeriod),
        identifier: msg.identifier,
        type: SKProductDiscountType.convertFromPigeon(msg.type));
  }

  /// Convert from [SKProductDiscountWrapper] to [SKProductDiscountMessage]
  @visibleForTesting
  static SKProductDiscountMessage convertToPigeon(
      SKProductDiscountWrapper wrapper) {
    return SKProductDiscountMessage(
        price: wrapper.price,
        priceLocale: SKPriceLocaleWrapper.convertToPigeon(wrapper.priceLocale),
        numberOfPeriods: wrapper.numberOfPeriods,
        paymentMode:
            SKProductDiscountPaymentMode.convertToPigeon(wrapper.paymentMode),
        subscriptionPeriod: SKProductSubscriptionPeriodWrapper.convertToPigeon(
            wrapper.subscriptionPeriod),
        identifier: wrapper.identifier,
        type: SKProductDiscountType.convertToPigeon(wrapper.type));
  }
}

/// Dart wrapper around StoreKit's [SKProduct](https://developer.apple.com/documentation/storekit/skproduct?language=objc).
///
/// A list of [SKProductWrapper] is returned in the [SKRequestMaker.startProductRequest] method, and
/// should be stored for use when making a payment.
@JsonSerializable()
@immutable
class SKProductWrapper {
  /// Creates an [SKProductWrapper] with the given product details.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SKProductWrapper({
    required this.productIdentifier,
    required this.localizedTitle,
    required this.localizedDescription,
    required this.priceLocale,
    this.subscriptionGroupIdentifier,
    required this.price,
    this.subscriptionPeriod,
    this.introductoryPrice,
    this.discounts = const <SKProductDiscountWrapper>[],
  });

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SkProductResponseWrapper.fromJson].
  factory SKProductWrapper.fromJson(Map<String, dynamic> map) {
    return _$SKProductWrapperFromJson(map);
  }

  /// The unique identifier of the product.
  @JsonKey(defaultValue: '')
  final String productIdentifier;

  /// The localizedTitle of the product.
  ///
  /// It is localized based on the current locale.
  @JsonKey(defaultValue: '')
  final String localizedTitle;

  /// The localized description of the product.
  ///
  /// It is localized based on the current locale.
  @JsonKey(defaultValue: '')
  final String localizedDescription;

  /// Includes locale information about the price, e.g. `$` as the currency symbol for US locale.
  final SKPriceLocaleWrapper priceLocale;

  /// The subscription group identifier.
  ///
  /// If the product is not a subscription, the value is `null`.
  ///
  /// A subscription group is a collection of subscription products.
  /// Check [SubscriptionGroup](https://developer.apple.com/app-store/subscriptions/) for more details about subscription group.
  final String? subscriptionGroupIdentifier;

  /// The price of the product, in the currency that is defined in [priceLocale].
  @JsonKey(defaultValue: '')
  final String price;

  /// The object represents the subscription period of the product.
  ///
  /// Can be [null] is the product is not a subscription.
  final SKProductSubscriptionPeriodWrapper? subscriptionPeriod;

  /// The object represents the duration of single subscription period.
  ///
  /// This is only available if you set up the introductory price in the App Store Connect, otherwise the value is `null`.
  /// Programmer is also responsible to determine if the user is eligible to receive it. See https://developer.apple.com/documentation/storekit/in-app_purchase/offering_introductory_pricing_in_your_app?language=objc
  /// for more details.
  /// The [subscriptionPeriod] of the discount is independent of the product's [subscriptionPeriod],
  /// and their units and duration do not have to be matched.
  final SKProductDiscountWrapper? introductoryPrice;

  /// An array of subscription offers available for the auto-renewable subscription (available on iOS 12.2 and higher).
  ///
  /// This property lists all promotional offers set up in App Store Connect. If
  /// no promotional offers have been set up, this field returns an empty list.
  /// Each [subscriptionPeriod] of individual discounts are independent of the
  /// product's [subscriptionPeriod] and their units and duration do not have to
  /// be matched.
  @JsonKey(defaultValue: <SKProductDiscountWrapper>[])
  final List<SKProductDiscountWrapper> discounts;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKProductWrapper &&
        other.productIdentifier == productIdentifier &&
        other.localizedTitle == localizedTitle &&
        other.localizedDescription == localizedDescription &&
        other.priceLocale == priceLocale &&
        other.subscriptionGroupIdentifier == subscriptionGroupIdentifier &&
        other.price == price &&
        other.subscriptionPeriod == subscriptionPeriod &&
        other.introductoryPrice == introductoryPrice &&
        const DeepCollectionEquality().equals(other.discounts, discounts);
  }

  @override
  int get hashCode => Object.hash(
      productIdentifier,
      localizedTitle,
      localizedDescription,
      priceLocale,
      subscriptionGroupIdentifier,
      price,
      subscriptionPeriod,
      introductoryPrice,
      discounts);

  /// Convert from [SKProductMessage] to [SKProductWrapper]
  static SKProductWrapper convertFromPigeon(SKProductMessage msg) {
    return SKProductWrapper(
        productIdentifier: msg.productIdentifier,
        localizedTitle: msg.localizedTitle,
        localizedDescription: msg.localizedDescription ?? '',
        priceLocale: SKPriceLocaleWrapper.convertFromPigeon(msg.priceLocale),
        price: msg.price,
        subscriptionGroupIdentifier: msg.subscriptionGroupIdentifier,
        subscriptionPeriod: msg.subscriptionPeriod != null
            ? SKProductSubscriptionPeriodWrapper.convertFromPigeon(
                msg.subscriptionPeriod!)
            : null,
        introductoryPrice: msg.introductoryPrice != null
            ? SKProductDiscountWrapper.convertFromPigeon(msg.introductoryPrice!)
            : null,
        discounts: msg.discounts != null
            ? msg.discounts!
                .map((SKProductDiscountMessage e) =>
                    SKProductDiscountWrapper.convertFromPigeon(e))
                .toList()
            : <SKProductDiscountWrapper>[]);
  }

  /// Convert from [SKProductWrapper] to [SKProductMessage]
  static SKProductMessage convertToPigeon(SKProductWrapper wrapper) {
    return SKProductMessage(
        productIdentifier: wrapper.productIdentifier,
        localizedTitle: wrapper.localizedTitle,
        localizedDescription: wrapper.localizedDescription,
        priceLocale: SKPriceLocaleWrapper.convertToPigeon(wrapper.priceLocale),
        price: wrapper.price,
        subscriptionGroupIdentifier: wrapper.subscriptionGroupIdentifier,
        subscriptionPeriod: wrapper.subscriptionPeriod != null
            ? SKProductSubscriptionPeriodWrapper.convertToPigeon(
                wrapper.subscriptionPeriod!)
            : null,
        introductoryPrice: wrapper.introductoryPrice != null
            ? SKProductDiscountWrapper.convertToPigeon(
                wrapper.introductoryPrice!)
            : null,
        discounts: wrapper.discounts
            .map((SKProductDiscountWrapper e) =>
                SKProductDiscountWrapper.convertToPigeon(e))
            .toList());
  }
}

/// Object that indicates the locale of the price
///
/// It is a thin wrapper of [NSLocale](https://developer.apple.com/documentation/foundation/nslocale?language=objc).
// TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this expanded.
//                 Matching android to only get the currencySymbol for now.
//                 https://github.com/flutter/flutter/issues/26610
@JsonSerializable()
@immutable
class SKPriceLocaleWrapper {
  /// Creates a new price locale for `currencySymbol` and `currencyCode`.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SKPriceLocaleWrapper({
    required this.currencySymbol,
    required this.currencyCode,
    required this.countryCode,
  });

  /// Constructing an instance from a map from the Objective-C layer.
  ///
  /// This method should only be used with `map` values returned by [SKProductWrapper.fromJson] and [SKProductDiscountWrapper.fromJson].
  factory SKPriceLocaleWrapper.fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return SKPriceLocaleWrapper(
          currencyCode: '', currencySymbol: '', countryCode: '');
    }
    return _$SKPriceLocaleWrapperFromJson(map);
  }

  ///The currency symbol for the locale, e.g. $ for US locale.
  @JsonKey(defaultValue: '')
  final String currencySymbol;

  ///The currency code for the locale, e.g. USD for US locale.
  @JsonKey(defaultValue: '')
  final String currencyCode;

  ///The country code for the locale, e.g. US for US locale.
  @JsonKey(defaultValue: '')
  final String countryCode;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKPriceLocaleWrapper &&
        other.currencySymbol == currencySymbol &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => Object.hash(currencySymbol, currencyCode);

  /// Convert from [SKPriceLocaleMessage] to [SKPriceLocaleWrapper]
  static SKPriceLocaleWrapper convertFromPigeon(SKPriceLocaleMessage msg) {
    return SKPriceLocaleWrapper(
        currencySymbol: msg.currencySymbol,
        currencyCode: msg.currencyCode,
        countryCode: msg.countryCode);
  }

  /// Convert from [SKPriceLocaleWrapper] to [SKPriceLocaleMessage]
  @visibleForTesting
  static SKPriceLocaleMessage convertToPigeon(SKPriceLocaleWrapper msg) {
    return SKPriceLocaleMessage(
        currencySymbol: msg.currencySymbol,
        currencyCode: msg.currencyCode,
        countryCode: msg.countryCode);
  }
}
