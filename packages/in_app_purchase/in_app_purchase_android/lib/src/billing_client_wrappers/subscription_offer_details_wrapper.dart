// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'billing_client_wrapper.dart';
import 'product_details_wrapper.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'subscription_offer_details_wrapper.g.dart';

/// Dart wrapper around [`com.android.billingclient.api.ProductDetails.SubscriptionOfferDetails`](https://developer.android.com/reference/com/android/billingclient/api/ProductDetails.SubscriptionOfferDetails).
///
/// Represents the available purchase plans to buy a subscription product.
@JsonSerializable()
@immutable
class SubscriptionOfferDetailsWrapper {
  /// Creates a [SubscriptionOfferDetailsWrapper].
  const SubscriptionOfferDetailsWrapper({
    required this.basePlanId,
    this.offerId,
    required this.offerTags,
    required this.offerIdToken,
    required this.pricingPhases,
  });

  /// Factory for creating a [SubscriptionOfferDetailsWrapper] from a [Map]
  /// with the offer details.
  @Deprecated('JSON serialization is not intended for public use, and will '
      'be removed in a future version.')
  factory SubscriptionOfferDetailsWrapper.fromJson(Map<String, dynamic> map) =>
      _$SubscriptionOfferDetailsWrapperFromJson(map);

  /// The base plan id associated with the subscription product.
  @JsonKey(defaultValue: '')
  final String basePlanId;

  /// The offer id associated with the subscription product.
  ///
  /// This field is only set for a discounted offer. Returns null for a regular
  /// base plan.
  @JsonKey(defaultValue: null)
  final String? offerId;

  /// The offer tags associated with this Subscription Offer.
  @JsonKey(defaultValue: <String>[])
  final List<String> offerTags;

  /// The offer token required to pass in [BillingClient.launchBillingFlow] to
  /// purchase the subscription product with these [pricingPhases].
  @JsonKey(defaultValue: '')
  final String offerIdToken;

  /// The pricing phases for the subscription product.
  @JsonKey(defaultValue: <PricingPhaseWrapper>[])
  final List<PricingPhaseWrapper> pricingPhases;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SubscriptionOfferDetailsWrapper &&
        other.basePlanId == basePlanId &&
        other.offerId == offerId &&
        listEquals(other.offerTags, offerTags) &&
        other.offerIdToken == offerIdToken &&
        listEquals(other.pricingPhases, pricingPhases);
  }

  @override
  int get hashCode {
    return Object.hash(
      basePlanId.hashCode,
      offerId.hashCode,
      offerTags.hashCode,
      offerIdToken.hashCode,
      pricingPhases.hashCode,
    );
  }
}

/// Represents a pricing phase, describing how a user pays at a point in time.
@JsonSerializable()
@RecurrenceModeConverter()
@immutable
class PricingPhaseWrapper {
  /// Creates a new [PricingPhaseWrapper] from the supplied info.
  const PricingPhaseWrapper({
    required this.billingCycleCount,
    required this.billingPeriod,
    required this.formattedPrice,
    required this.priceAmountMicros,
    required this.priceCurrencyCode,
    required this.recurrenceMode,
  });

  /// Factory for creating a [PricingPhaseWrapper] from a [Map] with the phase details.
  @Deprecated('JSON serialization is not intended for public use, and will '
      'be removed in a future version.')
  factory PricingPhaseWrapper.fromJson(Map<String, dynamic> map) =>
      _$PricingPhaseWrapperFromJson(map);

  /// Represents a pricing phase, describing how a user pays at a point in time.
  @JsonKey(defaultValue: 0)
  final int billingCycleCount;

  /// Billing period for which the given price applies, specified in ISO 8601
  /// format.
  @JsonKey(defaultValue: '')
  final String billingPeriod;

  /// Returns formatted price for the payment cycle, including its currency
  /// sign.
  @JsonKey(defaultValue: '')
  final String formattedPrice;

  /// Returns the price for the payment cycle in micro-units, where 1,000,000
  /// micro-units equal one unit of the currency.
  @JsonKey(defaultValue: 0)
  final int priceAmountMicros;

  /// Returns ISO 4217 currency code for price.
  @JsonKey(defaultValue: '')
  final String priceCurrencyCode;

  /// Returns [RecurrenceMode] for the pricing phase.
  @JsonKey(defaultValue: RecurrenceMode.nonRecurring)
  final RecurrenceMode recurrenceMode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is PricingPhaseWrapper &&
        other.billingCycleCount == billingCycleCount &&
        other.billingPeriod == billingPeriod &&
        other.formattedPrice == formattedPrice &&
        other.priceAmountMicros == priceAmountMicros &&
        other.priceCurrencyCode == priceCurrencyCode &&
        other.recurrenceMode == recurrenceMode;
  }

  @override
  int get hashCode => Object.hash(
        billingCycleCount,
        billingPeriod,
        formattedPrice,
        priceAmountMicros,
        priceCurrencyCode,
        recurrenceMode,
      );
}
