// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.inapppurchase

import com.android.billingclient.api.AlternativeBillingOnlyReportingDetails
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingConfig
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.ProductDetails.InstallmentPlanDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.Purchase.PendingPurchaseUpdate
import com.android.billingclient.api.PurchaseHistoryRecord
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.UserChoiceDetails

fun fromProductDetail(detail: ProductDetails): PlatformProductDetails {
  return PlatformProductDetails(
      description = detail.description,
      name = detail.name,
      productId = detail.productId,
      productType = toPlatformProductType(detail.productType),
      title = detail.title,
      oneTimePurchaseOfferDetails =
          fromOneTimePurchaseOfferDetails(detail.oneTimePurchaseOfferDetails),
      subscriptionOfferDetails = fromSubscriptionOfferDetailsList(detail.subscriptionOfferDetails))
}

fun toProductList(
    platformProducts: List<PlatformQueryProduct>
): List<QueryProductDetailsParams.Product> {
  return platformProducts.map { toProduct(it) }
}

fun toProduct(platformProduct: PlatformQueryProduct): QueryProductDetailsParams.Product {
  return QueryProductDetailsParams.Product.newBuilder()
      .setProductId(platformProduct.productId)
      .setProductType(toProductTypeString(platformProduct.productType))
      .build()
}

fun toProductTypeString(type: PlatformProductType): String {
  return when (type) {
    PlatformProductType.INAPP -> BillingClient.ProductType.INAPP
    PlatformProductType.SUBS -> BillingClient.ProductType.SUBS
  }
}

fun toPlatformProductType(typeString: String): PlatformProductType {
  return when (typeString) {
    BillingClient.ProductType.INAPP -> PlatformProductType.INAPP
    BillingClient.ProductType.SUBS -> PlatformProductType.SUBS
    else -> PlatformProductType.INAPP
  }
}

fun fromProductDetailsList(
    productDetailsList: List<ProductDetails>?
): List<PlatformProductDetails> {
  return productDetailsList?.map { fromProductDetail(it) } ?: emptyList()
}

fun fromOneTimePurchaseOfferDetails(
    oneTimePurchaseOfferDetails: ProductDetails.OneTimePurchaseOfferDetails?
): PlatformOneTimePurchaseOfferDetails? {
  if (oneTimePurchaseOfferDetails == null) {
    return null
  }

  return PlatformOneTimePurchaseOfferDetails(
      priceAmountMicros = oneTimePurchaseOfferDetails.priceAmountMicros,
      formattedPrice = oneTimePurchaseOfferDetails.formattedPrice,
      priceCurrencyCode = oneTimePurchaseOfferDetails.priceCurrencyCode)
}

fun fromSubscriptionOfferDetailsList(
    subscriptionOfferDetailsList: List<ProductDetails.SubscriptionOfferDetails>?
): List<PlatformSubscriptionOfferDetails>? {
  return subscriptionOfferDetailsList?.map { fromSubscriptionOfferDetails(it) }
}

fun fromSubscriptionOfferDetails(
    subscriptionOfferDetails: ProductDetails.SubscriptionOfferDetails
): PlatformSubscriptionOfferDetails {
  return PlatformSubscriptionOfferDetails(
      basePlanId = subscriptionOfferDetails.basePlanId,
      offerId = subscriptionOfferDetails.offerId,
      offerToken = subscriptionOfferDetails.offerToken,
      offerTags = subscriptionOfferDetails.offerTags,
      pricingPhases = fromPricingPhases(subscriptionOfferDetails.pricingPhases),
      installmentPlanDetails =
          fromInstallmentPlanDetails(subscriptionOfferDetails.installmentPlanDetails))
}

fun fromPricingPhases(pricingPhases: ProductDetails.PricingPhases): List<PlatformPricingPhase> {
  return pricingPhases.pricingPhaseList.map { fromPricingPhase(it) }
}

fun fromPricingPhase(pricingPhase: ProductDetails.PricingPhase): PlatformPricingPhase {
  return PlatformPricingPhase(
      billingCycleCount = pricingPhase.billingCycleCount.toLong(),
      recurrenceMode = toPlatformRecurrenceMode(pricingPhase.recurrenceMode),
      priceAmountMicros = pricingPhase.priceAmountMicros,
      billingPeriod = pricingPhase.billingPeriod,
      formattedPrice = pricingPhase.formattedPrice,
      priceCurrencyCode = pricingPhase.priceCurrencyCode)
}

fun fromInstallmentPlanDetails(
    installmentPlanDetails: InstallmentPlanDetails?
): PlatformInstallmentPlanDetails? {
  if (installmentPlanDetails == null) {
    return null
  }

  return PlatformInstallmentPlanDetails(
      commitmentPaymentsCount =
          installmentPlanDetails.installmentPlanCommitmentPaymentsCount.toLong(),
      subsequentCommitmentPaymentsCount =
          installmentPlanDetails.subsequentInstallmentPlanCommitmentPaymentsCount.toLong())
}

fun toPlatformRecurrenceMode(mode: Int): PlatformRecurrenceMode =
    when (mode) {
      ProductDetails.RecurrenceMode.FINITE_RECURRING -> PlatformRecurrenceMode.FINITE_RECURRING
      ProductDetails.RecurrenceMode.INFINITE_RECURRING -> PlatformRecurrenceMode.INFINITE_RECURRING
      ProductDetails.RecurrenceMode.NON_RECURRING -> PlatformRecurrenceMode.NON_RECURRING
      else -> PlatformRecurrenceMode.NON_RECURRING
    }

fun toPlatformPurchaseState(state: Int): PlatformPurchaseState =
    when (state) {
      Purchase.PurchaseState.PURCHASED -> PlatformPurchaseState.PURCHASED
      Purchase.PurchaseState.PENDING -> PlatformPurchaseState.PENDING
      Purchase.PurchaseState.UNSPECIFIED_STATE -> PlatformPurchaseState.UNSPECIFIED
      else -> PlatformPurchaseState.UNSPECIFIED
    }

fun fromPurchase(purchase: Purchase): PlatformPurchase {
  var accountIdentifiers: PlatformAccountIdentifiers? = null
  val billingAccountIdentifiers = purchase.accountIdentifiers
  if (billingAccountIdentifiers != null) {
    accountIdentifiers =
        PlatformAccountIdentifiers(
            obfuscatedAccountId = billingAccountIdentifiers.obfuscatedAccountId,
            obfuscatedProfileId = billingAccountIdentifiers.obfuscatedProfileId)
  }

  var pendingPurchaseUpdate: PlatformPendingPurchaseUpdate? = null
  val billingPendingPurchaseUpdate = purchase.pendingPurchaseUpdate
  if (billingPendingPurchaseUpdate != null) {
    pendingPurchaseUpdate = fromPendingPurchaseUpdate(billingPendingPurchaseUpdate)
  }

  return PlatformPurchase(
      orderId = purchase.orderId,
      packageName = purchase.packageName,
      purchaseTime = purchase.purchaseTime,
      purchaseToken = purchase.purchaseToken,
      signature = purchase.signature,
      products = purchase.products,
      isAutoRenewing = purchase.isAutoRenewing,
      originalJson = purchase.originalJson,
      developerPayload = purchase.developerPayload,
      isAcknowledged = purchase.isAcknowledged,
      quantity = purchase.quantity.toLong(),
      purchaseState = toPlatformPurchaseState(purchase.purchaseState),
      accountIdentifiers = accountIdentifiers,
      pendingPurchaseUpdate = pendingPurchaseUpdate)
}

fun fromPendingPurchaseUpdate(
    pendingPurchaseUpdate: PendingPurchaseUpdate?
): PlatformPendingPurchaseUpdate? {
  if (pendingPurchaseUpdate == null) {
    return null
  }

  return PlatformPendingPurchaseUpdate(
      pendingPurchaseUpdate.products, pendingPurchaseUpdate.purchaseToken)
}

fun fromPurchaseHistoryRecord(
    purchaseHistoryRecord: PurchaseHistoryRecord
): PlatformPurchaseHistoryRecord {
  return PlatformPurchaseHistoryRecord(
      quantity = purchaseHistoryRecord.quantity.toLong(),
      purchaseTime = purchaseHistoryRecord.purchaseTime,
      developerPayload = purchaseHistoryRecord.developerPayload,
      originalJson = purchaseHistoryRecord.originalJson,
      purchaseToken = purchaseHistoryRecord.purchaseToken,
      signature = purchaseHistoryRecord.signature,
      products = purchaseHistoryRecord.products)
}

fun fromPurchasesList(purchases: List<Purchase>?): List<PlatformPurchase> {
  return purchases?.map { fromPurchase(it) } ?: emptyList()
}

fun fromPurchaseHistoryRecordList(
    purchaseHistoryRecords: List<PurchaseHistoryRecord>?
): List<PlatformPurchaseHistoryRecord> {
  return purchaseHistoryRecords?.map { fromPurchaseHistoryRecord(it) } ?: emptyList()
}

fun fromBillingResult(billingResult: BillingResult): PlatformBillingResult {
  return PlatformBillingResult(
      fromBillingResponseCode(billingResult.responseCode), billingResult.debugMessage)
}

fun fromBillingResponseCode(billingResponseCode: Int): PlatformBillingResponse =
    when (billingResponseCode) {
      BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED ->
          PlatformBillingResponse.FEATURE_NOT_SUPPORTED
      BillingClient.BillingResponseCode.SERVICE_DISCONNECTED ->
          PlatformBillingResponse.SERVICE_DISCONNECTED
      BillingClient.BillingResponseCode.OK -> PlatformBillingResponse.OK
      BillingClient.BillingResponseCode.USER_CANCELED -> PlatformBillingResponse.USER_CANCELED
      BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE ->
          PlatformBillingResponse.SERVICE_UNAVAILABLE
      BillingClient.BillingResponseCode.BILLING_UNAVAILABLE ->
          PlatformBillingResponse.BILLING_UNAVAILABLE
      BillingClient.BillingResponseCode.ITEM_UNAVAILABLE -> PlatformBillingResponse.ITEM_UNAVAILABLE
      BillingClient.BillingResponseCode.DEVELOPER_ERROR -> PlatformBillingResponse.DEVELOPER_ERROR
      BillingClient.BillingResponseCode.ERROR -> PlatformBillingResponse.ERROR
      BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED ->
          PlatformBillingResponse.ITEM_ALREADY_OWNED
      BillingClient.BillingResponseCode.ITEM_NOT_OWNED -> PlatformBillingResponse.ITEM_NOT_OWNED
      BillingClient.BillingResponseCode.NETWORK_ERROR -> PlatformBillingResponse.NETWORK_ERROR
      else -> PlatformBillingResponse.ERROR
    }

fun fromUserChoiceDetails(userChoiceDetails: UserChoiceDetails): PlatformUserChoiceDetails {
  return PlatformUserChoiceDetails(
      originalExternalTransactionId = userChoiceDetails.originalExternalTransactionId,
      externalTransactionToken = userChoiceDetails.externalTransactionToken,
      products = fromUserChoiceProductsList(userChoiceDetails.products))
}

fun fromUserChoiceProductsList(
    productsList: List<UserChoiceDetails.Product>
): List<PlatformUserChoiceProduct> {
  return productsList.map { fromUserChoiceProduct(it) }
}

fun fromUserChoiceProduct(product: UserChoiceDetails.Product): PlatformUserChoiceProduct {
  return PlatformUserChoiceProduct(
      id = product.id, offerToken = product.offerToken, type = toPlatformProductType(product.type))
}

/** Converter from [BillingResult] and [BillingConfig] to map. */
fun fromBillingConfig(
    result: BillingResult,
    billingConfig: BillingConfig?
): PlatformBillingConfigResponse {
  return PlatformBillingConfigResponse(fromBillingResult(result), billingConfig?.countryCode ?: "")
}

/** Converter from [BillingResult] and [AlternativeBillingOnlyReportingDetails] to map. */
fun fromAlternativeBillingOnlyReportingDetails(
    result: BillingResult,
    details: AlternativeBillingOnlyReportingDetails?
): PlatformAlternativeBillingOnlyReportingDetailsResponse {
  return PlatformAlternativeBillingOnlyReportingDetailsResponse(
      fromBillingResult(result), details?.externalTransactionToken ?: "")
}

fun toPendingPurchasesParams(
    platformPendingPurchasesParams: PlatformPendingPurchasesParams?
): PendingPurchasesParams {
  val pendingPurchasesBuilder = PendingPurchasesParams.newBuilder().enableOneTimeProducts()
  if (platformPendingPurchasesParams != null && platformPendingPurchasesParams.enablePrepaidPlans) {
    pendingPurchasesBuilder.enablePrepaidPlans()
  }
  return pendingPurchasesBuilder.build()
}

fun toBillingClientFeature(feature: PlatformBillingClientFeature): String {
  return when (feature) {
    PlatformBillingClientFeature.ALTERNATIVE_BILLING_ONLY ->
        BillingClient.FeatureType.ALTERNATIVE_BILLING_ONLY
    PlatformBillingClientFeature.BILLING_CONFIG -> BillingClient.FeatureType.BILLING_CONFIG
    PlatformBillingClientFeature.EXTERNAL_OFFER -> BillingClient.FeatureType.EXTERNAL_OFFER
    PlatformBillingClientFeature.IN_APP_MESSAGING -> BillingClient.FeatureType.IN_APP_MESSAGING
    PlatformBillingClientFeature.PRICE_CHANGE_CONFIRMATION ->
        BillingClient.FeatureType.PRICE_CHANGE_CONFIRMATION
    PlatformBillingClientFeature.PRODUCT_DETAILS -> BillingClient.FeatureType.PRODUCT_DETAILS
    PlatformBillingClientFeature.SUBSCRIPTIONS -> BillingClient.FeatureType.SUBSCRIPTIONS
    PlatformBillingClientFeature.SUBSCRIPTIONS_UPDATE ->
        BillingClient.FeatureType.SUBSCRIPTIONS_UPDATE
  }
}

fun toReplacementMode(replacementMode: PlatformReplacementMode): Int {
  return when (replacementMode) {
    PlatformReplacementMode.CHARGE_FULL_PRICE ->
        BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.CHARGE_FULL_PRICE
    PlatformReplacementMode.CHARGE_PRORATED_PRICE ->
        BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.CHARGE_PRORATED_PRICE
    PlatformReplacementMode.DEFERRED ->
        BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.DEFERRED
    PlatformReplacementMode.WITHOUT_PRORATION ->
        BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.WITHOUT_PRORATION
    PlatformReplacementMode.WITH_TIME_PRORATION ->
        BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.WITH_TIME_PRORATION
    PlatformReplacementMode.UNKNOWN_REPLACEMENT_MODE ->
        BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.UNKNOWN_REPLACEMENT_MODE
  }
}
