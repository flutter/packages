// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'one_time_purchase_offer_details_wrapper.g.dart';

/// Dart wrapper around [`com.android.billingclient.api.ProductDetails.OneTimePurchaseOfferDetails`](https://developer.android.com/reference/com/android/billingclient/api/ProductDetails.OneTimePurchaseOfferDetails).
///
/// Represents the offer details to buy a one-time purchase product.
@JsonSerializable()
@immutable
class OneTimePurchaseOfferDetailsWrapper {
  /// Creates a [OneTimePurchaseOfferDetailsWrapper].
  @visibleForTesting
  const OneTimePurchaseOfferDetailsWrapper({
    required this.formattedPrice,
    required this.priceAmountMicros,
    required this.priceCurrencyCode,
  });

  /// Factory for creating a [OneTimePurchaseOfferDetailsWrapper] from a [Map]
  /// with the offer details.
  factory OneTimePurchaseOfferDetailsWrapper.fromJson(
          Map<String, dynamic> map) =>
      _$OneTimePurchaseOfferDetailsWrapperFromJson(map);

  /// Formatted price for the payment, including its currency sign.
  ///
  /// For tax exclusive countries, the price doesn't include tax.
  @JsonKey(defaultValue: '')
  final String formattedPrice;

  /// The price for the payment in micro-units, where 1,000,000 micro-units
  /// equal one unit of the currency.
  ///
  /// For example, if price is "€7.99", price_amount_micros is "7990000". This
  /// value represents the localized, rounded price for a particular currency.
  @JsonKey(defaultValue: 0)
  final int priceAmountMicros;

  /// The ISO 4217 currency code for price.
  ///
  /// For example, if price is specified in British pounds sterling, currency
  /// code is "GBP".
  @JsonKey(defaultValue: '')
  final String priceCurrencyCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is OneTimePurchaseOfferDetailsWrapper &&
        other.formattedPrice == formattedPrice &&
        other.priceAmountMicros == priceAmountMicros &&
        other.priceCurrencyCode == priceCurrencyCode;
  }

  @override
  int get hashCode {
    return Object.hash(
      formattedPrice.hashCode,
      priceAmountMicros.hashCode,
      priceCurrencyCode.hashCode,
    );
  }
}
