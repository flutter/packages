// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../billing_client_wrappers.dart';
import 'billing_client_wrappers/billing_config_wrapper.dart';
import 'messages.g.dart';

/// Converts a [BillingChoiceMode] to the Pigeon equivalent.
PlatformBillingChoiceMode platformBillingChoiceMode(BillingChoiceMode mode) {
  return switch (mode) {
    BillingChoiceMode.playBillingOnly =>
      PlatformBillingChoiceMode.playBillingOnly,
    BillingChoiceMode.alternativeBillingOnly =>
      PlatformBillingChoiceMode.alternativeBillingOnly,
    BillingChoiceMode.userChoiceBilling =>
      PlatformBillingChoiceMode.userChoiceBilling,
  };
}

/// Creates a [BillingResultWrapper] from the Pigeon equivalent.
BillingResultWrapper resultWrapperFromPlatform(PlatformBillingResult result) {
  return BillingResultWrapper(
      responseCode:
          const BillingResponseConverter().fromJson(result.responseCode),
      debugMessage: result.debugMessage);
}

/// Creates a [ProductDetailsResponseWrapper] from the Pigeon equivalent.
ProductDetailsResponseWrapper productDetailsResponseWrapperFromPlatform(
    PlatformProductDetailsResponse response) {
  return ProductDetailsResponseWrapper(
      billingResult: resultWrapperFromPlatform(response.billingResult),
      productDetailsList: response.productDetails
          // See TODOs in messages.dart for why casting away nullability is safe.
          .map((PlatformProductDetails? p) => p!)
          .map(productDetailsWrapperFromPlatform)
          .toList());
}

/// Creates a [ProductDetailsWrapper] from the Pigeon equivalent.
ProductDetailsWrapper productDetailsWrapperFromPlatform(
    PlatformProductDetails product) {
  return ProductDetailsWrapper(
    description: product.description,
    name: product.name,
    productId: product.productId,
    productType: productTypeFromPlatform(product.productType),
    title: product.title,
    oneTimePurchaseOfferDetails: oneTimePurchaseOfferDetailsWrapperFromPlatform(
        product.oneTimePurchaseOfferDetails),
    subscriptionOfferDetails: product.subscriptionOfferDetails
        // See comment in messages.dart for why casting away nullability is safe.
        ?.map((PlatformSubscriptionOfferDetails? o) => o!)
        .map(subscriptionOfferDetailsWrapperFromPlatform)
        .toList(),
  );
}

/// Creates a [OneTimePurchaseOfferDetailsWrapper] from the Pigeon equivalent.
OneTimePurchaseOfferDetailsWrapper?
    oneTimePurchaseOfferDetailsWrapperFromPlatform(
        PlatformOneTimePurchaseOfferDetails? details) {
  if (details == null) {
    return null;
  }
  return OneTimePurchaseOfferDetailsWrapper(
    formattedPrice: details.formattedPrice,
    priceAmountMicros: details.priceAmountMicros,
    priceCurrencyCode: details.priceCurrencyCode,
  );
}

/// Creates a [PurchaseHistoryResult] from the Pigeon equivalent.
PurchasesHistoryResult purchaseHistoryResultFromPlatform(
    PlatformPurchaseHistoryResponse response) {
  return PurchasesHistoryResult(
    billingResult: resultWrapperFromPlatform(response.billingResult),
    purchaseHistoryRecordList: response.purchases
        // See comment in messages.dart for why casting away nullability is safe.
        .map((PlatformPurchaseHistoryRecord? r) => r!)
        .map(purchaseHistoryRecordWrapperFromPlatform)
        .toList(),
  );
}

/// Creates a [PurchaseHistoryRecordWrapper] from the Pigeon equivalent.
PurchaseHistoryRecordWrapper purchaseHistoryRecordWrapperFromPlatform(
    PlatformPurchaseHistoryRecord record) {
  return PurchaseHistoryRecordWrapper(
    purchaseTime: record.purchaseTime,
    purchaseToken: record.purchaseToken,
    signature: record.signature,
    // See comment in messages.dart for why casting away nullability is safe.
    products: record.products.map((String? s) => s!).toList(),
    originalJson: record.originalJson,
    developerPayload: record.developerPayload,
  );
}

/// Creates a [PurchasesResultWrapper] from the Pigeon equivalent.
PurchasesResultWrapper purchasesResultWrapperFromPlatform(
    PlatformPurchasesResponse response,
    {bool forceOkResponseCode = false}) {
  return PurchasesResultWrapper(
    billingResult: resultWrapperFromPlatform(response.billingResult),
    purchasesList: response.purchases
        // See TODOs in messages.dart for why casting away nullability is safe.
        .map((PlatformPurchase? p) => p!)
        .map(purchaseWrapperFromPlatform)
        .toList(),
    responseCode: forceOkResponseCode
        ? BillingResponse.ok
        : const BillingResponseConverter()
            .fromJson(response.billingResult.responseCode),
  );
}

/// Creates an [AlternativeBillingOnlyReportingDetailsWrapper] from the Pigeon
/// equivalent.
AlternativeBillingOnlyReportingDetailsWrapper
    alternativeBillingOnlyReportingDetailsWrapperFromPlatform(
        PlatformAlternativeBillingOnlyReportingDetailsResponse response) {
  return AlternativeBillingOnlyReportingDetailsWrapper(
    responseCode: const BillingResponseConverter()
        .fromJson(response.billingResult.responseCode),
    debugMessage: response.billingResult.debugMessage,
    externalTransactionToken: response.externalTransactionToken,
  );
}

/// Creates a [BillingConfigWrapper] from the Pigeon equivalent.
BillingConfigWrapper billingConfigWrapperFromPlatform(
    PlatformBillingConfigResponse response) {
  return BillingConfigWrapper(
    responseCode: const BillingResponseConverter()
        .fromJson(response.billingResult.responseCode),
    debugMessage: response.billingResult.debugMessage,
    countryCode: response.countryCode,
  );
}

/// Creates a Pigeon [PlatformProduct] from a [ProductWrapper].
PlatformQueryProduct platformQueryProductFromWrapper(ProductWrapper product) {
  return PlatformQueryProduct(
    productId: product.productId,
    productType: platformProductTypeFromWrapper(product.productType),
  );
}

/// Converts a [ProductType] to its Pigeon equivalent.
PlatformProductType platformProductTypeFromWrapper(ProductType type) {
  return switch (type) {
    ProductType.inapp => PlatformProductType.inapp,
    ProductType.subs => PlatformProductType.subs,
  };
}

/// Creates a [PricingPhaseWrapper] from its Pigeon equivalent.
PricingPhaseWrapper pricingPhaseWrapperFromPlatform(
    PlatformPricingPhase phase) {
  return PricingPhaseWrapper(
    billingCycleCount: phase.billingCycleCount,
    billingPeriod: phase.billingPeriod,
    formattedPrice: phase.formattedPrice,
    priceAmountMicros: phase.priceAmountMicros,
    priceCurrencyCode: phase.priceCurrencyCode,
    recurrenceMode: recurrenceModeFromPlatform(phase.recurrenceMode),
  );
}

/// Converts a Pigeon [PlatformProductType] to its public API equivalent.
ProductType productTypeFromPlatform(PlatformProductType type) {
  return switch (type) {
    PlatformProductType.inapp => ProductType.inapp,
    PlatformProductType.subs => ProductType.subs,
  };
}

/// Creates a [PurchaseWrapper] from the Pigeon equivalent.
PurchaseWrapper purchaseWrapperFromPlatform(PlatformPurchase purchase) {
  return PurchaseWrapper(
    orderId: purchase.orderId ?? '',
    packageName: purchase.packageName,
    purchaseTime: purchase.purchaseTime,
    purchaseToken: purchase.purchaseToken,
    signature: purchase.signature,
    // See comment in messages.dart for why casting away nullability is safe.
    products: purchase.products.map((String? s) => s!).toList(),
    isAutoRenewing: purchase.isAutoRenewing,
    originalJson: purchase.originalJson,
    isAcknowledged: purchase.isAcknowledged,
    purchaseState: purchaseStateWrapperFromPlatform(purchase.purchaseState),
    developerPayload: purchase.developerPayload,
    obfuscatedAccountId: purchase.accountIdentifiers?.obfuscatedAccountId,
    obfuscatedProfileId: purchase.accountIdentifiers?.obfuscatedProfileId,
  );
}

/// Creates a [PurchaseStateWrapper] from the Pigeon equivalent.
PurchaseStateWrapper purchaseStateWrapperFromPlatform(
    PlatformPurchaseState state) {
  return switch (state) {
    PlatformPurchaseState.unspecified => PurchaseStateWrapper.unspecified_state,
    PlatformPurchaseState.purchased => PurchaseStateWrapper.purchased,
    PlatformPurchaseState.pending => PurchaseStateWrapper.pending,
  };
}

/// Creates a [RecurrenceMode] from the Pigeon equivalent.
RecurrenceMode recurrenceModeFromPlatform(PlatformRecurrenceMode mode) {
  return switch (mode) {
    PlatformRecurrenceMode.finiteRecurring => RecurrenceMode.finiteRecurring,
    PlatformRecurrenceMode.infiniteRecurring =>
      RecurrenceMode.infiniteRecurring,
    PlatformRecurrenceMode.nonRecurring => RecurrenceMode.nonRecurring,
  };
}

/// Creates a [SubscriptionOfferDetailsWrapper] from the Pigeon equivalent.
SubscriptionOfferDetailsWrapper subscriptionOfferDetailsWrapperFromPlatform(
    PlatformSubscriptionOfferDetails offer) {
  return SubscriptionOfferDetailsWrapper(
    basePlanId: offer.basePlanId,
    offerId: offer.offerId,
    // See comment in messages.dart for why casting away nullability is safe.
    offerTags: offer.offerTags.map((String? s) => s!).toList(),
    offerIdToken: offer.offerToken,
    pricingPhases: offer.pricingPhases
        // See comment in messages.dart for why casting away nullability is safe.
        .map((PlatformPricingPhase? p) => p!)
        .map(pricingPhaseWrapperFromPlatform)
        .toList(),
  );
}

/// Creates a [UserChoiceDetailsWrapper] from the Pigeon equivalent.
UserChoiceDetailsWrapper userChoiceDetailsFromPlatform(
    PlatformUserChoiceDetails details) {
  return UserChoiceDetailsWrapper(
    originalExternalTransactionId: details.originalExternalTransactionId ?? '',
    externalTransactionToken: details.externalTransactionToken,
    products: details.products
        // See comment in messages.dart for why casting away nullability is safe.
        .map((PlatformUserChoiceProduct? p) => p!)
        .map(userChoiceDetailsProductFromPlatform)
        .toList(),
  );
}

/// Creates a [UserChoiceDetailsProductWrapper] from the Pigeon equivalent.
UserChoiceDetailsProductWrapper userChoiceDetailsProductFromPlatform(
    PlatformUserChoiceProduct product) {
  return UserChoiceDetailsProductWrapper(
    id: product.id,
    offerToken: product.offerToken ?? '',
    productType: productTypeFromPlatform(product.type),
  );
}
