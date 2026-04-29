// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.android.billingclient.api.AccountIdentifiers;
import com.android.billingclient.api.AlternativeBillingOnlyReportingDetails;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingConfig;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.PendingPurchasesParams;
import com.android.billingclient.api.ProductDetails;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchaseHistoryRecord;
import com.android.billingclient.api.QueryProductDetailsParams;
import com.android.billingclient.api.UserChoiceDetails;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Currency;
import java.util.List;
import java.util.Locale;

/**
 * Handles serialization and deserialization of {@link com.android.billingclient.api.BillingClient}
 * related objects.
 */
/*package*/ class Translator {
  static @NonNull PlatformProductDetails fromProductDetail(@NonNull ProductDetails detail) {
    return new PlatformProductDetails(
        detail.getDescription(),
        detail.getName(),
        detail.getProductId(),
        toPlatformProductType(detail.getProductType()),
        detail.getTitle(),
        fromOneTimePurchaseOfferDetails(detail.getOneTimePurchaseOfferDetails()),
        fromSubscriptionOfferDetailsList(detail.getSubscriptionOfferDetails()));
  }

  static @NonNull List<QueryProductDetailsParams.Product> toProductList(
      @NonNull List<PlatformQueryProduct> platformProducts) {
    List<QueryProductDetailsParams.Product> products = new ArrayList<>();
    for (PlatformQueryProduct platformProduct : platformProducts) {
      products.add(toProduct(platformProduct));
    }
    return products;
  }

  static @NonNull QueryProductDetailsParams.Product toProduct(
      @NonNull PlatformQueryProduct platformProduct) {

    return QueryProductDetailsParams.Product.newBuilder()
        .setProductId(platformProduct.getProductId())
        .setProductType(toProductTypeString(platformProduct.getProductType()))
        .build();
  }

  static @NonNull String toProductTypeString(PlatformProductType type) {
    switch (type) {
      case INAPP:
        return BillingClient.ProductType.INAPP;
      case SUBS:
        return BillingClient.ProductType.SUBS;
    }
    throw new FlutterError("UNKNOWN_TYPE", "Unknown product type: " + type, null);
  }

  static PlatformProductType toPlatformProductType(@NonNull String typeString) {
    switch (typeString) {
      case BillingClient.ProductType.INAPP:
      // Fallback handling to avoid throwing an exception if a new type is added in the future.
      default:
        return PlatformProductType.INAPP;
      case BillingClient.ProductType.SUBS:
        return PlatformProductType.SUBS;
    }
  }

  static @NonNull List<PlatformProductDetails> fromProductDetailsList(
      @Nullable List<ProductDetails> productDetailsList) {
    if (productDetailsList == null) {
      return Collections.emptyList();
    }

    ArrayList<PlatformProductDetails> output = new ArrayList<>();
    for (ProductDetails detail : productDetailsList) {
      output.add(fromProductDetail(detail));
    }
    return output;
  }

  static @Nullable PlatformOneTimePurchaseOfferDetails fromOneTimePurchaseOfferDetails(
      @Nullable ProductDetails.OneTimePurchaseOfferDetails oneTimePurchaseOfferDetails) {
    if (oneTimePurchaseOfferDetails == null) {
      return null;
    }

    return new PlatformOneTimePurchaseOfferDetails(
        oneTimePurchaseOfferDetails.getPriceAmountMicros(),
        oneTimePurchaseOfferDetails.getFormattedPrice(),
        oneTimePurchaseOfferDetails.getPriceCurrencyCode());
  }

  static @Nullable List<PlatformSubscriptionOfferDetails> fromSubscriptionOfferDetailsList(
      @Nullable List<ProductDetails.SubscriptionOfferDetails> subscriptionOfferDetailsList) {
    if (subscriptionOfferDetailsList == null) {
      return null;
    }

    ArrayList<PlatformSubscriptionOfferDetails> serialized = new ArrayList<>();
    for (ProductDetails.SubscriptionOfferDetails subscriptionOfferDetails :
        subscriptionOfferDetailsList) {
      serialized.add(fromSubscriptionOfferDetails(subscriptionOfferDetails));
    }

    return serialized;
  }

  static @NonNull PlatformSubscriptionOfferDetails fromSubscriptionOfferDetails(
      @NonNull ProductDetails.SubscriptionOfferDetails subscriptionOfferDetails) {
    return new PlatformSubscriptionOfferDetails(
        subscriptionOfferDetails.getBasePlanId(),
        subscriptionOfferDetails.getOfferId(),
        subscriptionOfferDetails.getOfferToken(),
        subscriptionOfferDetails.getOfferTags(),
        fromPricingPhases(subscriptionOfferDetails.getPricingPhases()),
        fromInstallmentPlanDetails(subscriptionOfferDetails.getInstallmentPlanDetails()));
  }

  static @NonNull List<PlatformPricingPhase> fromPricingPhases(
      @NonNull ProductDetails.PricingPhases pricingPhases) {
    ArrayList<PlatformPricingPhase> serialized = new ArrayList<>();
    for (ProductDetails.PricingPhase pricingPhase : pricingPhases.getPricingPhaseList()) {
      serialized.add(fromPricingPhase(pricingPhase));
    }
    return serialized;
  }

  static @NonNull PlatformPricingPhase fromPricingPhase(
      @NonNull ProductDetails.PricingPhase pricingPhase) {
    return new PlatformPricingPhase(
        (long) pricingPhase.getBillingCycleCount(),
        toPlatformRecurrenceMode(pricingPhase.getRecurrenceMode()),
        pricingPhase.getPriceAmountMicros(),
        pricingPhase.getBillingPeriod(),
        pricingPhase.getFormattedPrice(),
        pricingPhase.getPriceCurrencyCode());
  }

  static @Nullable PlatformInstallmentPlanDetails fromInstallmentPlanDetails(
      @Nullable ProductDetails.InstallmentPlanDetails installmentPlanDetails) {
    if (installmentPlanDetails == null) {
      return null;
    }

    return new PlatformInstallmentPlanDetails(
        (long) installmentPlanDetails.getInstallmentPlanCommitmentPaymentsCount(),
        (long) installmentPlanDetails.getSubsequentInstallmentPlanCommitmentPaymentsCount());
  }

  static PlatformRecurrenceMode toPlatformRecurrenceMode(int mode) {
    switch (mode) {
      case ProductDetails.RecurrenceMode.FINITE_RECURRING:
        return PlatformRecurrenceMode.FINITE_RECURRING;
      case ProductDetails.RecurrenceMode.INFINITE_RECURRING:
        return PlatformRecurrenceMode.INFINITE_RECURRING;
      case ProductDetails.RecurrenceMode.NON_RECURRING:
        return PlatformRecurrenceMode.NON_RECURRING;
    }
    return PlatformRecurrenceMode.NON_RECURRING;
  }

  static PlatformPurchaseState toPlatformPurchaseState(int state) {
    switch (state) {
      case Purchase.PurchaseState.PURCHASED:
        return PlatformPurchaseState.PURCHASED;
      case Purchase.PurchaseState.PENDING:
        return PlatformPurchaseState.PENDING;
      case Purchase.PurchaseState.UNSPECIFIED_STATE:
        return PlatformPurchaseState.UNSPECIFIED;
    }
    return PlatformPurchaseState.UNSPECIFIED;
  }

  static @NonNull PlatformPurchase fromPurchase(@NonNull Purchase purchase) {
    PlatformAccountIdentifiers accountIdentifiers = null;
    AccountIdentifiers billingAccountIdentifiers = purchase.getAccountIdentifiers();
    if (billingAccountIdentifiers != null) {
      accountIdentifiers =
          new PlatformAccountIdentifiers(
              billingAccountIdentifiers.getObfuscatedAccountId(),
              billingAccountIdentifiers.getObfuscatedProfileId());
    }

    PlatformPendingPurchaseUpdate pendingPurchaseUpdate = null;
    Purchase.PendingPurchaseUpdate billingPendingPurchaseUpdate =
        purchase.getPendingPurchaseUpdate();
    if (billingPendingPurchaseUpdate != null) {
      pendingPurchaseUpdate = fromPendingPurchaseUpdate(billingPendingPurchaseUpdate);
    }

    return new PlatformPurchase(
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
        (long) purchase.getQuantity(),
        toPlatformPurchaseState(purchase.getPurchaseState()),
        accountIdentifiers,
        pendingPurchaseUpdate);
  }

  static @Nullable PlatformPendingPurchaseUpdate fromPendingPurchaseUpdate(
      @Nullable Purchase.PendingPurchaseUpdate pendingPurchaseUpdate) {
    if (pendingPurchaseUpdate == null) {
      return null;
    }

    return new PlatformPendingPurchaseUpdate(
        pendingPurchaseUpdate.getProducts(), pendingPurchaseUpdate.getPurchaseToken());
  }

  static @NonNull PlatformPurchaseHistoryRecord fromPurchaseHistoryRecord(
      @NonNull PurchaseHistoryRecord purchaseHistoryRecord) {
    return new PlatformPurchaseHistoryRecord(
        (long) purchaseHistoryRecord.getQuantity(),
        purchaseHistoryRecord.getPurchaseTime(),
        purchaseHistoryRecord.getDeveloperPayload(),
        purchaseHistoryRecord.getOriginalJson(),
        purchaseHistoryRecord.getPurchaseToken(),
        purchaseHistoryRecord.getSignature(),
        purchaseHistoryRecord.getProducts());
  }

  static @NonNull List<PlatformPurchase> fromPurchasesList(@Nullable List<Purchase> purchases) {
    if (purchases == null) {
      return Collections.emptyList();
    }

    List<PlatformPurchase> serialized = new ArrayList<>();
    for (Purchase purchase : purchases) {
      serialized.add(fromPurchase(purchase));
    }
    return serialized;
  }

  static @NonNull List<PlatformPurchaseHistoryRecord> fromPurchaseHistoryRecordList(
      @Nullable List<PurchaseHistoryRecord> purchaseHistoryRecords) {
    if (purchaseHistoryRecords == null) {
      return Collections.emptyList();
    }

    List<PlatformPurchaseHistoryRecord> serialized = new ArrayList<>();
    for (PurchaseHistoryRecord purchaseHistoryRecord : purchaseHistoryRecords) {
      serialized.add(fromPurchaseHistoryRecord(purchaseHistoryRecord));
    }
    return serialized;
  }

  static @NonNull PlatformBillingResult fromBillingResult(@NonNull BillingResult billingResult) {
    return new PlatformBillingResult(
        fromBillingResponseCode(billingResult.getResponseCode()), billingResult.getDebugMessage());
  }

  static @NonNull PlatformBillingResponse fromBillingResponseCode(int billingResponseCode) {
    switch (billingResponseCode) {
      case BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED:
        return PlatformBillingResponse.FEATURE_NOT_SUPPORTED;
      case BillingClient.BillingResponseCode.SERVICE_DISCONNECTED:
        return PlatformBillingResponse.SERVICE_DISCONNECTED;
      case BillingClient.BillingResponseCode.OK:
        return PlatformBillingResponse.OK;
      case BillingClient.BillingResponseCode.USER_CANCELED:
        return PlatformBillingResponse.USER_CANCELED;
      case BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE:
        return PlatformBillingResponse.SERVICE_UNAVAILABLE;
      case BillingClient.BillingResponseCode.BILLING_UNAVAILABLE:
        return PlatformBillingResponse.BILLING_UNAVAILABLE;
      case BillingClient.BillingResponseCode.ITEM_UNAVAILABLE:
        return PlatformBillingResponse.ITEM_UNAVAILABLE;
      case BillingClient.BillingResponseCode.DEVELOPER_ERROR:
        return PlatformBillingResponse.DEVELOPER_ERROR;
      case BillingClient.BillingResponseCode.ERROR:
        return PlatformBillingResponse.ERROR;
      case BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED:
        return PlatformBillingResponse.ITEM_ALREADY_OWNED;
      case BillingClient.BillingResponseCode.ITEM_NOT_OWNED:
        return PlatformBillingResponse.ITEM_NOT_OWNED;
      case BillingClient.BillingResponseCode.NETWORK_ERROR:
        return PlatformBillingResponse.NETWORK_ERROR;
    }
    return PlatformBillingResponse.ERROR;
  }

  static @NonNull PlatformUserChoiceDetails fromUserChoiceDetails(
      @NonNull UserChoiceDetails userChoiceDetails) {
    return new PlatformUserChoiceDetails(
        userChoiceDetails.getOriginalExternalTransactionId(),
        userChoiceDetails.getExternalTransactionToken(),
        fromUserChoiceProductsList(userChoiceDetails.getProducts()));
  }

  static @NonNull List<PlatformUserChoiceProduct> fromUserChoiceProductsList(
      @NonNull List<UserChoiceDetails.Product> productsList) {
    if (productsList.isEmpty()) {
      return Collections.emptyList();
    }

    ArrayList<PlatformUserChoiceProduct> output = new ArrayList<>();
    for (UserChoiceDetails.Product product : productsList) {
      output.add(fromUserChoiceProduct(product));
    }
    return output;
  }

  static @NonNull PlatformUserChoiceProduct fromUserChoiceProduct(
      @NonNull UserChoiceDetails.Product product) {
    return new PlatformUserChoiceProduct(
        product.getId(), product.getOfferToken(), toPlatformProductType(product.getType()));
  }

  /** Converter from {@link BillingResult} and {@link BillingConfig} to map. */
  static @NonNull PlatformBillingConfigResponse fromBillingConfig(
      @NonNull BillingResult result, @Nullable BillingConfig billingConfig) {
    return new PlatformBillingConfigResponse(
        fromBillingResult(result), billingConfig == null ? "" : billingConfig.getCountryCode());
  }

  /**
   * Converter from {@link BillingResult} and {@link AlternativeBillingOnlyReportingDetails} to map.
   */
  static @NonNull PlatformAlternativeBillingOnlyReportingDetailsResponse
      fromAlternativeBillingOnlyReportingDetails(
          @NonNull BillingResult result, @Nullable AlternativeBillingOnlyReportingDetails details) {
    return new PlatformAlternativeBillingOnlyReportingDetailsResponse(
        fromBillingResult(result), details == null ? "" : details.getExternalTransactionToken());
  }

  static @NonNull PendingPurchasesParams toPendingPurchasesParams(
      @Nullable PlatformPendingPurchasesParams platformPendingPurchasesParams) {
    PendingPurchasesParams.Builder pendingPurchasesBuilder =
        PendingPurchasesParams.newBuilder().enableOneTimeProducts();
    if (platformPendingPurchasesParams != null
        && platformPendingPurchasesParams.getEnablePrepaidPlans()) {
      pendingPurchasesBuilder.enablePrepaidPlans();
    }
    return pendingPurchasesBuilder.build();
  }

  static @NonNull String toBillingClientFeature(@NonNull PlatformBillingClientFeature feature) {
    switch (feature) {
      case ALTERNATIVE_BILLING_ONLY:
        return BillingClient.FeatureType.ALTERNATIVE_BILLING_ONLY;
      case BILLING_CONFIG:
        return BillingClient.FeatureType.BILLING_CONFIG;
      case EXTERNAL_OFFER:
        return BillingClient.FeatureType.EXTERNAL_OFFER;
      case IN_APP_MESSAGING:
        return BillingClient.FeatureType.IN_APP_MESSAGING;
      case PRICE_CHANGE_CONFIRMATION:
        return BillingClient.FeatureType.PRICE_CHANGE_CONFIRMATION;
      case PRODUCT_DETAILS:
        return BillingClient.FeatureType.PRODUCT_DETAILS;
      case SUBSCRIPTIONS:
        return BillingClient.FeatureType.SUBSCRIPTIONS;
      case SUBSCRIPTIONS_UPDATE:
        return BillingClient.FeatureType.SUBSCRIPTIONS_UPDATE;
    }
    throw new FlutterError("UNKNOWN_FEATURE", "Unknown client feature: " + feature, null);
  }

  static int toReplacementMode(@NonNull PlatformReplacementMode replacementMode) {
    switch (replacementMode) {
      case CHARGE_FULL_PRICE:
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.CHARGE_FULL_PRICE;
      case CHARGE_PRORATED_PRICE:
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.CHARGE_PRORATED_PRICE;
      case DEFERRED:
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.DEFERRED;
      case WITHOUT_PRORATION:
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.WITHOUT_PRORATION;
      case WITH_TIME_PRORATION:
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.WITH_TIME_PRORATION;
      case UNKNOWN_REPLACEMENT_MODE:
        return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.UNKNOWN_REPLACEMENT_MODE;
    }
    return BillingFlowParams.SubscriptionUpdateParams.ReplacementMode.UNKNOWN_REPLACEMENT_MODE;
  }

  /**
   * Gets the symbol of for the given currency code for the default {@link Locale.Category#DISPLAY
   * DISPLAY} locale. For example, for the US Dollar, the symbol is "$" if the default locale is the
   * US, while for other locales it may be "US$". If no symbol can be determined, the ISO 4217
   * currency code is returned.
   *
   * @param currencyCode the ISO 4217 code of the currency
   * @return the symbol of this currency code for the default {@link Locale.Category#DISPLAY
   *     DISPLAY} locale
   * @exception NullPointerException if <code>currencyCode</code> is null
   * @exception IllegalArgumentException if <code>currencyCode</code> is not a supported ISO 4217
   *     code.
   */
  static String currencySymbolFromCode(String currencyCode) {
    return Currency.getInstance(currencyCode).getSymbol();
  }
}
