// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/src/messages.g.dart';
import 'package:in_app_purchase_android/src/pigeon_converters.dart';

/// Creates the [PlatformBillingResult] to return from a mock to get
/// [targetResult].
///
/// Since [PlatformBillingResult] returns a non-nullable debug string, the
/// target must have a non-null string as well.
PlatformBillingResult convertToPigeonResult(BillingResultWrapper targetResult) {
  return PlatformBillingResult(
    responseCode: billingResponseFromWrapper(targetResult.responseCode),
    debugMessage: targetResult.debugMessage!,
  );
}

/// Creates a [PlatformPurchase] from the corresponding [PurchaseWrapper].
PlatformPurchase convertToPigeonPurchase(PurchaseWrapper purchase) {
  return PlatformPurchase(
      orderId: purchase.orderId,
      packageName: purchase.packageName,
      purchaseTime: purchase.purchaseTime,
      purchaseToken: purchase.purchaseToken,
      signature: purchase.signature,
      products: purchase.products,
      isAutoRenewing: purchase.isAutoRenewing,
      originalJson: purchase.originalJson,
      developerPayload: purchase.developerPayload ?? '',
      isAcknowledged: purchase.isAcknowledged,
      purchaseState: _convertToPigeonPurchaseState(purchase.purchaseState),
      // For some reason quantity is not in PurchaseWrapper.
      quantity: 99,
      accountIdentifiers: purchase.obfuscatedAccountId != null ||
              purchase.obfuscatedProfileId != null
          ? PlatformAccountIdentifiers(
              obfuscatedAccountId: purchase.obfuscatedAccountId,
              obfuscatedProfileId: purchase.obfuscatedProfileId,
            )
          : null);
}

/// Creates a [PlatformProductDetails] from the corresponding [ProductDetailsWrapper].
PlatformProductDetails convertToPigeonProductDetails(
    ProductDetailsWrapper details) {
  return PlatformProductDetails(
      description: details.description,
      name: details.name,
      productId: details.productId,
      productType: platformProductTypeFromWrapper(details.productType),
      title: details.title,
      oneTimePurchaseOfferDetails: _convertToPigeonOneTimePurchaseOfferDetails(
          details.oneTimePurchaseOfferDetails),
      subscriptionOfferDetails: details.subscriptionOfferDetails
          ?.map(convertToPigeonSubscriptionOfferDetails)
          .toList());
}

PlatformSubscriptionOfferDetails convertToPigeonSubscriptionOfferDetails(
    SubscriptionOfferDetailsWrapper details) {
  return PlatformSubscriptionOfferDetails(
      basePlanId: details.basePlanId,
      offerId: details.offerId,
      offerToken: details.offerIdToken,
      offerTags: details.offerTags,
      pricingPhases:
          details.pricingPhases.map(convertToPigeonPricingPhase).toList());
}

PlatformPricingPhase convertToPigeonPricingPhase(PricingPhaseWrapper phase) {
  return PlatformPricingPhase(
      billingCycleCount: phase.billingCycleCount,
      recurrenceMode: _convertToPigeonRecurrenceMode(phase.recurrenceMode),
      priceAmountMicros: phase.priceAmountMicros,
      billingPeriod: phase.billingPeriod,
      formattedPrice: phase.formattedPrice,
      priceCurrencyCode: phase.priceCurrencyCode);
}

PlatformOneTimePurchaseOfferDetails?
    _convertToPigeonOneTimePurchaseOfferDetails(
        OneTimePurchaseOfferDetailsWrapper? offer) {
  if (offer == null) {
    return null;
  }
  return PlatformOneTimePurchaseOfferDetails(
      priceAmountMicros: offer.priceAmountMicros,
      formattedPrice: offer.formattedPrice,
      priceCurrencyCode: offer.priceCurrencyCode);
}

/// Creates a [PlatformPurchaseState] from the Dart wrapper equivalent.
PlatformPurchaseState _convertToPigeonPurchaseState(
    PurchaseStateWrapper state) {
  return switch (state) {
    PurchaseStateWrapper.unspecified_state => PlatformPurchaseState.unspecified,
    PurchaseStateWrapper.purchased => PlatformPurchaseState.purchased,
    PurchaseStateWrapper.pending => PlatformPurchaseState.pending,
  };
}

PlatformRecurrenceMode _convertToPigeonRecurrenceMode(RecurrenceMode mode) {
  return switch (mode) {
    RecurrenceMode.finiteRecurring => PlatformRecurrenceMode.finiteRecurring,
    RecurrenceMode.infiniteRecurring =>
      PlatformRecurrenceMode.infiniteRecurring,
    RecurrenceMode.nonRecurring => PlatformRecurrenceMode.nonRecurring,
  };
}
