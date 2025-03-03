// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'billing_client_wrapper.dart';
import 'product_details_wrapper.dart';

/// Dart wrapper around [`com.android.billingclient.api.ProductDetails.SubscriptionOfferDetails`](https://developer.android.com/reference/com/android/billingclient/api/ProductDetails.SubscriptionOfferDetails).
///
/// Represents the available purchase plans to buy a subscription product.
@immutable
class SubscriptionOfferDetailsWrapper {
  /// Creates a [SubscriptionOfferDetailsWrapper].
  const SubscriptionOfferDetailsWrapper({
    required this.basePlanId,
    this.offerId,
    required this.offerTags,
    required this.offerIdToken,
    required this.pricingPhases,
    this.installmentPlanDetails,
  });

  /// The base plan id associated with the subscription product.
  final String basePlanId;

  /// The offer id associated with the subscription product.
  ///
  /// This field is only set for a discounted offer. Returns null for a regular
  /// base plan.
  final String? offerId;

  /// The offer tags associated with this Subscription Offer.
  final List<String> offerTags;

  /// The offer token required to pass in [BillingClient.launchBillingFlow] to
  /// purchase the subscription product with these [pricingPhases].
  final String offerIdToken;

  /// The pricing phases for the subscription product.
  final List<PricingPhaseWrapper> pricingPhases;

  /// Represents additional details of an installment subscription plan.
  final InstallmentPlanDetailsWrapper? installmentPlanDetails;

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
        listEquals(other.pricingPhases, pricingPhases) &&
        installmentPlanDetails == other.installmentPlanDetails;
  }

  @override
  int get hashCode {
    return Object.hash(
      basePlanId.hashCode,
      offerId.hashCode,
      offerTags.hashCode,
      offerIdToken.hashCode,
      pricingPhases.hashCode,
      installmentPlanDetails.hashCode,
    );
  }
}

/// Represents a pricing phase, describing how a user pays at a point in time.
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

  /// Represents a pricing phase, describing how a user pays at a point in time.
  final int billingCycleCount;

  /// Billing period for which the given price applies, specified in ISO 8601
  /// format.
  final String billingPeriod;

  /// Returns formatted price for the payment cycle, including its currency
  /// sign.
  final String formattedPrice;

  /// Returns the price for the payment cycle in micro-units, where 1,000,000
  /// micro-units equal one unit of the currency.
  final int priceAmountMicros;

  /// Returns ISO 4217 currency code for price.
  final String priceCurrencyCode;

  /// Returns [RecurrenceMode] for the pricing phase.
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

/// Represents additional details of an installment subscription plan.
///
/// This wraps [`com.android.billingclient.api.ProductDetails.InstallmentPlanDetails`](https://developer.android.com/reference/com/android/billingclient/api/ProductDetails.InstallmentPlanDetails).
@immutable
class InstallmentPlanDetailsWrapper {
  /// Creates a [InstallmentPlanDetailsWrapper].
  const InstallmentPlanDetailsWrapper({
    required this.commitmentPaymentsCount,
    required this.subsequentCommitmentPaymentsCount,
  });

  /// Committed payments count after a user signs up for this subscription plan.
  ///
  /// For example, for a monthly subscription plan with commitmentPaymentsCount
  /// as 12, users will be charged monthly for 12 month after initial signup.
  /// User cancellation won't take effect until all 12 committed payments are finished.
  final int commitmentPaymentsCount;

  /// Subsequent committed payments count after this subscription plan renews.
  ///
  /// For example, for a monthly subscription plan with subsequentCommitmentPaymentsCount
  /// as 12, when the subscription plan renews, users will be committed to another fresh
  /// 12 monthly payments.
  ///
  /// Note: Returns 0 if the installment plan doesn't have any subsequent committment,
  /// which means this subscription plan will fall back to a normal non-installment
  /// monthly plan when the plan renews.
  final int subsequentCommitmentPaymentsCount;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is InstallmentPlanDetailsWrapper &&
        other.commitmentPaymentsCount == commitmentPaymentsCount &&
        other.subsequentCommitmentPaymentsCount ==
            subsequentCommitmentPaymentsCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      commitmentPaymentsCount.hashCode,
      subsequentCommitmentPaymentsCount.hashCode,
    );
  }
}
