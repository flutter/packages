// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import '../billing_client_wrappers.dart';
import 'billing_client_wrappers/billing_config_wrapper.dart';
import 'billing_client_wrappers/pending_purchases_params_wrapper.dart';
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
      responseCode: billingResponseFromPlatform(result.responseCode),
      debugMessage: result.debugMessage);
}

/// Creates a [ProductDetailsResponseWrapper] from the Pigeon equivalent.
ProductDetailsResponseWrapper productDetailsResponseWrapperFromPlatform(
    PlatformProductDetailsResponse response) {
  return ProductDetailsResponseWrapper(
      billingResult: resultWrapperFromPlatform(response.billingResult),
      productDetailsList: response.productDetails
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
        ?.map(subscriptionOfferDetailsWrapperFromPlatform)
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
    products: record.products,
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
    purchasesList: response.purchases.map(purchaseWrapperFromPlatform).toList(),
    responseCode: forceOkResponseCode
        ? BillingResponse.ok
        : billingResponseFromPlatform(response.billingResult.responseCode),
  );
}

/// Creates an [AlternativeBillingOnlyReportingDetailsWrapper] from the Pigeon
/// equivalent.
AlternativeBillingOnlyReportingDetailsWrapper
    alternativeBillingOnlyReportingDetailsWrapperFromPlatform(
        PlatformAlternativeBillingOnlyReportingDetailsResponse response) {
  return AlternativeBillingOnlyReportingDetailsWrapper(
    responseCode: billingResponseFromPlatform(
      response.billingResult.responseCode,
    ),
    debugMessage: response.billingResult.debugMessage,
    externalTransactionToken: response.externalTransactionToken,
  );
}

/// Creates a [BillingConfigWrapper] from the Pigeon equivalent.
BillingConfigWrapper billingConfigWrapperFromPlatform(
    PlatformBillingConfigResponse response) {
  return BillingConfigWrapper(
    responseCode: billingResponseFromPlatform(
      response.billingResult.responseCode,
    ),
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
    products: purchase.products,
    isAutoRenewing: purchase.isAutoRenewing,
    originalJson: purchase.originalJson,
    isAcknowledged: purchase.isAcknowledged,
    purchaseState: purchaseStateWrapperFromPlatform(purchase.purchaseState),
    developerPayload: purchase.developerPayload,
    obfuscatedAccountId: purchase.accountIdentifiers?.obfuscatedAccountId,
    obfuscatedProfileId: purchase.accountIdentifiers?.obfuscatedProfileId,
    pendingPurchaseUpdate:
        pendingPurchaseUpdateFromPlatform(purchase.pendingPurchaseUpdate),
  );
}

/// Creates a [PendingPurchaseUpdateWrapper] from the Pigeon equivalent.
PendingPurchaseUpdateWrapper? pendingPurchaseUpdateFromPlatform(
    PlatformPendingPurchaseUpdate? pendingPurchaseUpdate) {
  if (pendingPurchaseUpdate == null) {
    return null;
  }

  return PendingPurchaseUpdateWrapper(
      purchaseToken: pendingPurchaseUpdate.purchaseToken,
      products: pendingPurchaseUpdate.products);
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

/// Converts [PurchaseStateWrapper] to [PurchaseStatus].
PurchaseStatus purchaseStatusFromWrapper(PurchaseStateWrapper purchaseState) {
  return switch (purchaseState) {
    PurchaseStateWrapper.unspecified_state => PurchaseStatus.error,
    PurchaseStateWrapper.purchased => PurchaseStatus.purchased,
    PurchaseStateWrapper.pending => PurchaseStatus.pending,
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
    offerTags: offer.offerTags,
    offerIdToken: offer.offerToken,
    pricingPhases:
        offer.pricingPhases.map(pricingPhaseWrapperFromPlatform).toList(),
    installmentPlanDetails:
        installmentPlanDetailsFromPlatform(offer.installmentPlanDetails),
  );
}

/// Creates a [UserChoiceDetailsWrapper] from the Pigeon equivalent.
UserChoiceDetailsWrapper userChoiceDetailsFromPlatform(
    PlatformUserChoiceDetails details) {
  return UserChoiceDetailsWrapper(
    originalExternalTransactionId: details.originalExternalTransactionId ?? '',
    externalTransactionToken: details.externalTransactionToken,
    products:
        details.products.map(userChoiceDetailsProductFromPlatform).toList(),
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

/// Creates a [InstallmentPlanDetailsWrapper] from the Pigeon equivalent.
InstallmentPlanDetailsWrapper? installmentPlanDetailsFromPlatform(
    PlatformInstallmentPlanDetails? details) {
  if (details == null) {
    return null;
  }

  return InstallmentPlanDetailsWrapper(
    commitmentPaymentsCount: details.commitmentPaymentsCount,
    subsequentCommitmentPaymentsCount:
        details.subsequentCommitmentPaymentsCount,
  );
}

/// Converts a [PendingPurchasesParamsWrapper] to its Pigeon equivalent.
PlatformPendingPurchasesParams pendingPurchasesParamsFromWrapper(
    PendingPurchasesParamsWrapper params) {
  return PlatformPendingPurchasesParams(
    enablePrepaidPlans: params.enablePrepaidPlans,
  );
}

/// Converts [PlatformBillingResponse] to its public API enum equivalent.
BillingResponse billingResponseFromPlatform(
    PlatformBillingResponse responseCode) {
  return switch (responseCode) {
    PlatformBillingResponse.serviceTimeout => BillingResponse.serviceTimeout,
    PlatformBillingResponse.featureNotSupported =>
      BillingResponse.featureNotSupported,
    PlatformBillingResponse.serviceDisconnected =>
      BillingResponse.serviceDisconnected,
    PlatformBillingResponse.ok => BillingResponse.ok,
    PlatformBillingResponse.userCanceled => BillingResponse.userCanceled,
    PlatformBillingResponse.serviceUnavailable =>
      BillingResponse.serviceUnavailable,
    PlatformBillingResponse.billingUnavailable =>
      BillingResponse.billingUnavailable,
    PlatformBillingResponse.itemUnavailable => BillingResponse.itemUnavailable,
    PlatformBillingResponse.developerError => BillingResponse.developerError,
    PlatformBillingResponse.error => BillingResponse.error,
    PlatformBillingResponse.itemAlreadyOwned =>
      BillingResponse.itemAlreadyOwned,
    PlatformBillingResponse.itemNotOwned => BillingResponse.itemNotOwned,
    PlatformBillingResponse.networkError => BillingResponse.networkError,
  };
}

/// Converts a [BillingResponse] to its Pigeon equivalent.
PlatformBillingResponse billingResponseFromWrapper(
    BillingResponse responseCode) {
  return switch (responseCode) {
    BillingResponse.serviceTimeout => PlatformBillingResponse.serviceTimeout,
    BillingResponse.featureNotSupported =>
      PlatformBillingResponse.featureNotSupported,
    BillingResponse.serviceDisconnected =>
      PlatformBillingResponse.serviceDisconnected,
    BillingResponse.ok => PlatformBillingResponse.ok,
    BillingResponse.userCanceled => PlatformBillingResponse.userCanceled,
    BillingResponse.serviceUnavailable =>
      PlatformBillingResponse.serviceUnavailable,
    BillingResponse.billingUnavailable =>
      PlatformBillingResponse.billingUnavailable,
    BillingResponse.itemUnavailable => PlatformBillingResponse.itemUnavailable,
    BillingResponse.developerError => PlatformBillingResponse.developerError,
    BillingResponse.error => PlatformBillingResponse.error,
    BillingResponse.itemAlreadyOwned =>
      PlatformBillingResponse.itemAlreadyOwned,
    BillingResponse.itemNotOwned => PlatformBillingResponse.itemNotOwned,
    BillingResponse.networkError => PlatformBillingResponse.networkError,
  };
}

/// Converts [ReplacementMode] enum to its Pigeon equivalent.
PlatformReplacementMode replacementModeFromWrapper(
    ReplacementMode replacementMode) {
  return switch (replacementMode) {
    ReplacementMode.unknownReplacementMode =>
      PlatformReplacementMode.unknownReplacementMode,
    ReplacementMode.withTimeProration =>
      PlatformReplacementMode.withTimeProration,
    ReplacementMode.chargeProratedPrice =>
      PlatformReplacementMode.chargeProratedPrice,
    ReplacementMode.withoutProration =>
      PlatformReplacementMode.withoutProration,
    ReplacementMode.deferred => PlatformReplacementMode.deferred,
    ReplacementMode.chargeFullPrice => PlatformReplacementMode.chargeFullPrice,
  };
}

/// Converts [BillingClientFeature] enum to its Pigeon equivalent.
PlatformBillingClientFeature billingClientFeatureFromWrapper(
    BillingClientFeature feature) {
  return switch (feature) {
    BillingClientFeature.alternativeBillingOnly =>
      PlatformBillingClientFeature.alternativeBillingOnly,
    BillingClientFeature.priceChangeConfirmation =>
      PlatformBillingClientFeature.priceChangeConfirmation,
    BillingClientFeature.productDetails =>
      PlatformBillingClientFeature.productDetails,
    BillingClientFeature.subscriptions =>
      PlatformBillingClientFeature.subscriptions,
    BillingClientFeature.subscriptionsUpdate =>
      PlatformBillingClientFeature.subscriptionsUpdate,
    BillingClientFeature.billingConfig =>
      PlatformBillingClientFeature.billingConfig,
    BillingClientFeature.externalOffer =>
      PlatformBillingClientFeature.externalOffer,
    BillingClientFeature.inAppMessaging =>
      PlatformBillingClientFeature.inAppMessaging,
  };
}
