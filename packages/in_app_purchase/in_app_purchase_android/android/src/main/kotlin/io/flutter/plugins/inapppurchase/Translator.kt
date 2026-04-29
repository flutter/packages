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
import java.util.Currency

fun fromProductDetail(detail: ProductDetails): PlatformProductDetails {
  return PlatformProductDetails(
      detail.getDescription(),
      detail.getName(),
      detail.getProductId(),
      toPlatformProductType(detail.getProductType()),
      detail.getTitle(),
      fromOneTimePurchaseOfferDetails(detail.getOneTimePurchaseOfferDetails()),
      fromSubscriptionOfferDetailsList(detail.getSubscriptionOfferDetails()))
}

fun toProductList(
    platformProducts: MutableList<PlatformQueryProduct>
): MutableList<QueryProductDetailsParams.Product> {
  val products: MutableList<QueryProductDetailsParams.Product> =
      ArrayList<QueryProductDetailsParams.Product>()
  for (platformProduct in platformProducts) {
    products.add(toProduct(platformProduct))
  }
  return products
}

fun toProduct(platformProduct: PlatformQueryProduct): QueryProductDetailsParams.Product {
  return QueryProductDetailsParams.Product.newBuilder()
      .setProductId(platformProduct.productId)
      .setProductType(toProductTypeString(platformProduct.productType))
      .build()
}

fun toProductTypeString(type: PlatformProductType): String {
  when (type) {
    PlatformProductType.INAPP -> return BillingClient.ProductType.INAPP
    PlatformProductType.SUBS -> return BillingClient.ProductType.SUBS
  }
  throw FlutterError("UNKNOWN_TYPE", "Unknown product type: " + type, null)
}

fun toPlatformProductType(typeString: String): PlatformProductType {
  when (typeString) {
    BillingClient.ProductType.INAPP -> return PlatformProductType.INAPP
    BillingClient.ProductType.SUBS -> return PlatformProductType.SUBS
    else -> return PlatformProductType.INAPP
  }
}

fun fromProductDetailsList(
    productDetailsList: MutableList<ProductDetails>?
): MutableList<PlatformProductDetails> {
  if (productDetailsList == null) {
    return mutableListOf<PlatformProductDetails>()
  }

  val output = ArrayList<PlatformProductDetails>()
  for (detail in productDetailsList) {
    output.add(fromProductDetail(detail))
  }
  return output
}

fun fromOneTimePurchaseOfferDetails(
    oneTimePurchaseOfferDetails: ProductDetails.OneTimePurchaseOfferDetails?
): PlatformOneTimePurchaseOfferDetails? {
  if (oneTimePurchaseOfferDetails == null) {
    return null
  }

  return PlatformOneTimePurchaseOfferDetails(
      oneTimePurchaseOfferDetails.getPriceAmountMicros(),
      oneTimePurchaseOfferDetails.getFormattedPrice(),
      oneTimePurchaseOfferDetails.getPriceCurrencyCode())
}

fun fromSubscriptionOfferDetailsList(
    subscriptionOfferDetailsList: MutableList<ProductDetails.SubscriptionOfferDetails>?
): MutableList<PlatformSubscriptionOfferDetails>? {
  if (subscriptionOfferDetailsList == null) {
    return null
  }

  val serialized = ArrayList<PlatformSubscriptionOfferDetails>()
  for (subscriptionOfferDetails in subscriptionOfferDetailsList) {
    serialized.add(fromSubscriptionOfferDetails(subscriptionOfferDetails))
  }

  return serialized
}

fun fromSubscriptionOfferDetails(
    subscriptionOfferDetails: ProductDetails.SubscriptionOfferDetails
): PlatformSubscriptionOfferDetails {
  return PlatformSubscriptionOfferDetails(
      subscriptionOfferDetails.getBasePlanId(),
      subscriptionOfferDetails.getOfferId(),
      subscriptionOfferDetails.getOfferToken(),
      subscriptionOfferDetails.getOfferTags(),
      fromPricingPhases(subscriptionOfferDetails.getPricingPhases()),
      fromInstallmentPlanDetails(subscriptionOfferDetails.getInstallmentPlanDetails()))
}

fun fromPricingPhases(
    pricingPhases: ProductDetails.PricingPhases
): MutableList<PlatformPricingPhase> {
  val serialized = ArrayList<PlatformPricingPhase>()
  for (pricingPhase in pricingPhases.getPricingPhaseList()) {
    serialized.add(fromPricingPhase(pricingPhase))
  }
  return serialized
}

fun fromPricingPhase(pricingPhase: ProductDetails.PricingPhase): PlatformPricingPhase {
  return PlatformPricingPhase(
      pricingPhase.getBillingCycleCount().toLong(),
      toPlatformRecurrenceMode(pricingPhase.getRecurrenceMode()),
      pricingPhase.getPriceAmountMicros(),
      pricingPhase.getBillingPeriod(),
      pricingPhase.getFormattedPrice(),
      pricingPhase.getPriceCurrencyCode())
}

fun fromInstallmentPlanDetails(
    installmentPlanDetails: InstallmentPlanDetails?
): PlatformInstallmentPlanDetails? {
  if (installmentPlanDetails == null) {
    return null
  }

  return PlatformInstallmentPlanDetails(
      installmentPlanDetails.getInstallmentPlanCommitmentPaymentsCount().toLong(),
      installmentPlanDetails.getSubsequentInstallmentPlanCommitmentPaymentsCount().toLong())
}

fun toPlatformRecurrenceMode(mode: Int): PlatformRecurrenceMode {
  when (mode) {
    ProductDetails.RecurrenceMode.FINITE_RECURRING -> return PlatformRecurrenceMode.FINITE_RECURRING
    ProductDetails.RecurrenceMode.INFINITE_RECURRING ->
        return PlatformRecurrenceMode.INFINITE_RECURRING
    ProductDetails.RecurrenceMode.NON_RECURRING -> return PlatformRecurrenceMode.NON_RECURRING
  }
  return PlatformRecurrenceMode.NON_RECURRING
}

fun toPlatformPurchaseState(state: Int): PlatformPurchaseState {
  when (state) {
    Purchase.PurchaseState.PURCHASED -> return PlatformPurchaseState.PURCHASED
    Purchase.PurchaseState.PENDING -> return PlatformPurchaseState.PENDING
    Purchase.PurchaseState.UNSPECIFIED_STATE -> return PlatformPurchaseState.UNSPECIFIED
  }
  return PlatformPurchaseState.UNSPECIFIED
}

fun fromPurchase(purchase: Purchase): PlatformPurchase {
  var accountIdentifiers: PlatformAccountIdentifiers? = null
  val billingAccountIdentifiers = purchase.getAccountIdentifiers()
  if (billingAccountIdentifiers != null) {
    accountIdentifiers =
        PlatformAccountIdentifiers(
            billingAccountIdentifiers.getObfuscatedAccountId(),
            billingAccountIdentifiers.getObfuscatedProfileId())
  }

  var pendingPurchaseUpdate: PlatformPendingPurchaseUpdate? = null
  val billingPendingPurchaseUpdate = purchase.getPendingPurchaseUpdate()
  if (billingPendingPurchaseUpdate != null) {
    pendingPurchaseUpdate = fromPendingPurchaseUpdate(billingPendingPurchaseUpdate)
  }

  return PlatformPurchase(
      purchase.getOrderId(),
      purchase.getPackageName(),
      purchase.getPurchaseTime(),
      purchase.getPurchaseToken(),
      purchase.getSignature(),
      purchase.getProducts(),
      purchase.isAutoRenewing(),
      purchase.getOriginalJson(),
      purchase.getDeveloperPayload(),
      purchase.isAcknowledged(),
      purchase.getQuantity().toLong(),
      toPlatformPurchaseState(purchase.getPurchaseState()),
      accountIdentifiers,
      pendingPurchaseUpdate)
}

fun fromPendingPurchaseUpdate(
    pendingPurchaseUpdate: PendingPurchaseUpdate?
): PlatformPendingPurchaseUpdate? {
  if (pendingPurchaseUpdate == null) {
    return null
  }

  return PlatformPendingPurchaseUpdate(
      pendingPurchaseUpdate.getProducts(), pendingPurchaseUpdate.getPurchaseToken())
}

fun fromPurchaseHistoryRecord(
    purchaseHistoryRecord: PurchaseHistoryRecord
): PlatformPurchaseHistoryRecord {
  return PlatformPurchaseHistoryRecord(
      purchaseHistoryRecord.getQuantity().toLong(),
      purchaseHistoryRecord.getPurchaseTime(),
      purchaseHistoryRecord.getDeveloperPayload(),
      purchaseHistoryRecord.getOriginalJson(),
      purchaseHistoryRecord.getPurchaseToken(),
      purchaseHistoryRecord.getSignature(),
      purchaseHistoryRecord.getProducts())
}

fun fromPurchasesList(purchases: MutableList<Purchase>?): MutableList<PlatformPurchase> {
  if (purchases == null) {
    return mutableListOf<PlatformPurchase>()
  }

  val serialized: MutableList<PlatformPurchase> = ArrayList<PlatformPurchase>()
  for (purchase in purchases) {
    serialized.add(fromPurchase(purchase))
  }
  return serialized
}

fun fromPurchaseHistoryRecordList(
    purchaseHistoryRecords: MutableList<PurchaseHistoryRecord>?
): MutableList<PlatformPurchaseHistoryRecord> {
  if (purchaseHistoryRecords == null) {
    return mutableListOf<PlatformPurchaseHistoryRecord>()
  }

  val serialized: MutableList<PlatformPurchaseHistoryRecord> =
      ArrayList<PlatformPurchaseHistoryRecord>()
  for (purchaseHistoryRecord in purchaseHistoryRecords) {
    serialized.add(fromPurchaseHistoryRecord(purchaseHistoryRecord))
  }
  return serialized
}

fun fromBillingResult(billingResult: BillingResult): PlatformBillingResult {
  return PlatformBillingResult(
      fromBillingResponseCode(billingResult.getResponseCode()), billingResult.getDebugMessage())
}

fun fromBillingResponseCode(billingResponseCode: Int): PlatformBillingResponse {
  when (billingResponseCode) {
    BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED ->
        return PlatformBillingResponse.FEATURE_NOT_SUPPORTED
    BillingClient.BillingResponseCode.SERVICE_DISCONNECTED ->
        return PlatformBillingResponse.SERVICE_DISCONNECTED
    BillingClient.BillingResponseCode.OK -> return PlatformBillingResponse.OK
    BillingClient.BillingResponseCode.USER_CANCELED -> return PlatformBillingResponse.USER_CANCELED
    BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE ->
        return PlatformBillingResponse.SERVICE_UNAVAILABLE
    BillingClient.BillingResponseCode.BILLING_UNAVAILABLE ->
        return PlatformBillingResponse.BILLING_UNAVAILABLE
    BillingClient.BillingResponseCode.ITEM_UNAVAILABLE ->
        return PlatformBillingResponse.ITEM_UNAVAILABLE
    BillingClient.BillingResponseCode.DEVELOPER_ERROR ->
        return PlatformBillingResponse.DEVELOPER_ERROR
    BillingClient.BillingResponseCode.ERROR -> return PlatformBillingResponse.ERROR
    BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED ->
        return PlatformBillingResponse.ITEM_ALREADY_OWNED
    BillingClient.BillingResponseCode.ITEM_NOT_OWNED ->
        return PlatformBillingResponse.ITEM_NOT_OWNED
    BillingClient.BillingResponseCode.NETWORK_ERROR -> return PlatformBillingResponse.NETWORK_ERROR
  }
  return PlatformBillingResponse.ERROR
}

fun fromUserChoiceDetails(userChoiceDetails: UserChoiceDetails): PlatformUserChoiceDetails {
  return PlatformUserChoiceDetails(
      userChoiceDetails.getOriginalExternalTransactionId(),
      userChoiceDetails.getExternalTransactionToken(),
      fromUserChoiceProductsList(userChoiceDetails.getProducts()))
}

fun fromUserChoiceProductsList(
    productsList: MutableList<UserChoiceDetails.Product>
): MutableList<PlatformUserChoiceProduct> {
  if (productsList.isEmpty()) {
    return mutableListOf<PlatformUserChoiceProduct>()
  }

  val output = ArrayList<PlatformUserChoiceProduct>()
  for (product in productsList) {
    output.add(fromUserChoiceProduct(product))
  }
  return output
}

fun fromUserChoiceProduct(product: UserChoiceDetails.Product): PlatformUserChoiceProduct {
  return PlatformUserChoiceProduct(
      product.getId(), product.getOfferToken(), toPlatformProductType(product.getType()))
}

/** Converter from [BillingResult] and [BillingConfig] to map. */
fun fromBillingConfig(
    result: BillingResult,
    billingConfig: BillingConfig?
): PlatformBillingConfigResponse {
  return PlatformBillingConfigResponse(
      fromBillingResult(result), if (billingConfig == null) "" else billingConfig.getCountryCode())
}

/** Converter from [BillingResult] and [AlternativeBillingOnlyReportingDetails] to map. */
fun fromAlternativeBillingOnlyReportingDetails(
    result: BillingResult,
    details: AlternativeBillingOnlyReportingDetails?
): PlatformAlternativeBillingOnlyReportingDetailsResponse {
  return PlatformAlternativeBillingOnlyReportingDetailsResponse(
      fromBillingResult(result), if (details == null) "" else details.getExternalTransactionToken())
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
  when (feature) {
    PlatformBillingClientFeature.ALTERNATIVE_BILLING_ONLY ->
        return BillingClient.FeatureType.ALTERNATIVE_BILLING_ONLY
    PlatformBillingClientFeature.BILLING_CONFIG -> return BillingClient.FeatureType.BILLING_CONFIG
    PlatformBillingClientFeature.EXTERNAL_OFFER -> return BillingClient.FeatureType.EXTERNAL_OFFER
    PlatformBillingClientFeature.IN_APP_MESSAGING ->
        return BillingClient.FeatureType.IN_APP_MESSAGING
    PlatformBillingClientFeature.PRICE_CHANGE_CONFIRMATION ->
        return BillingClient.FeatureType.PRICE_CHANGE_CONFIRMATION
    PlatformBillingClientFeature.PRODUCT_DETAILS -> return BillingClient.FeatureType.PRODUCT_DETAILS
    PlatformBillingClientFeature.SUBSCRIPTIONS -> return BillingClient.FeatureType.SUBSCRIPTIONS
    PlatformBillingClientFeature.SUBSCRIPTIONS_UPDATE ->
        return BillingClient.FeatureType.SUBSCRIPTIONS_UPDATE
  }
  throw FlutterError("UNKNOWN_FEATURE", "Unknown client feature: " + feature, null)
}

fun toReplacementMode(replacementMode: PlatformReplacementMode): Int {
  when (replacementMode) {
    PlatformReplacementMode.CHARGE_FULL_PRICE ->
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.CHARGE_FULL_PRICE
    PlatformReplacementMode.CHARGE_PRORATED_PRICE ->
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.CHARGE_PRORATED_PRICE
    PlatformReplacementMode.DEFERRED ->
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.DEFERRED
    PlatformReplacementMode.WITHOUT_PRORATION ->
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.WITHOUT_PRORATION
    PlatformReplacementMode.WITH_TIME_PRORATION ->
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.WITH_TIME_PRORATION
    PlatformReplacementMode.UNKNOWN_REPLACEMENT_MODE ->
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.UNKNOWN_REPLACEMENT_MODE
  }
  return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.UNKNOWN_REPLACEMENT_MODE
}

/**
 * Gets the symbol of for the given currency code for the default
 * [ DISPLAY][Locale.Category.DISPLAY] locale. For example, for the US Dollar, the symbol is "$" if
 * the default locale is the US, while for other locales it may be "US$". If no symbol can be
 * determined, the ISO 4217 currency code is returned.
 *
 * @param currencyCode the ISO 4217 code of the currency
 * @return the symbol of this currency code for the default [ DISPLAY][Locale.Category.DISPLAY]
 *   locale
 * @exception NullPointerException if `currencyCode` is null
 * @exception IllegalArgumentException if `currencyCode` is not a supported ISO 4217 code.
 */
fun currencySymbolFromCode(currencyCode: String?): String? {
  return Currency.getInstance(currencyCode).getSymbol()
}
