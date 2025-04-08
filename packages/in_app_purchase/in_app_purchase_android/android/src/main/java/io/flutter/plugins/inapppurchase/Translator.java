// Copyright 2013 The Flutter Authors. All rights reserved.
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
import io.flutter.plugins.inapppurchase.Messages.FlutterError;
import io.flutter.plugins.inapppurchase.Messages.PlatformAccountIdentifiers;
import io.flutter.plugins.inapppurchase.Messages.PlatformAlternativeBillingOnlyReportingDetailsResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingClientFeature;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingConfigResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingResult;
import io.flutter.plugins.inapppurchase.Messages.PlatformOneTimePurchaseOfferDetails;
import io.flutter.plugins.inapppurchase.Messages.PlatformPendingPurchaseUpdate;
import io.flutter.plugins.inapppurchase.Messages.PlatformPricingPhase;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductDetails;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductType;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchase;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchaseHistoryRecord;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchaseState;
import io.flutter.plugins.inapppurchase.Messages.PlatformQueryProduct;
import io.flutter.plugins.inapppurchase.Messages.PlatformRecurrenceMode;
import io.flutter.plugins.inapppurchase.Messages.PlatformReplacementMode;
import io.flutter.plugins.inapppurchase.Messages.PlatformSubscriptionOfferDetails;
import io.flutter.plugins.inapppurchase.Messages.PlatformUserChoiceDetails;
import io.flutter.plugins.inapppurchase.Messages.PlatformUserChoiceProduct;
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
    return new PlatformProductDetails.Builder()
        .setTitle(detail.getTitle())
        .setDescription(detail.getDescription())
        .setProductId(detail.getProductId())
        .setProductType(toPlatformProductType(detail.getProductType()))
        .setName(detail.getName())
        .setOneTimePurchaseOfferDetails(
            fromOneTimePurchaseOfferDetails(detail.getOneTimePurchaseOfferDetails()))
        .setSubscriptionOfferDetails(
            fromSubscriptionOfferDetailsList(detail.getSubscriptionOfferDetails()))
        .build();
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

    return new PlatformOneTimePurchaseOfferDetails.Builder()
        .setPriceAmountMicros(oneTimePurchaseOfferDetails.getPriceAmountMicros())
        .setPriceCurrencyCode(oneTimePurchaseOfferDetails.getPriceCurrencyCode())
        .setFormattedPrice(oneTimePurchaseOfferDetails.getFormattedPrice())
        .build();
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
    return new PlatformSubscriptionOfferDetails.Builder()
        .setOfferId(subscriptionOfferDetails.getOfferId())
        .setBasePlanId(subscriptionOfferDetails.getBasePlanId())
        .setOfferTags(subscriptionOfferDetails.getOfferTags())
        .setOfferToken(subscriptionOfferDetails.getOfferToken())
        .setPricingPhases(fromPricingPhases(subscriptionOfferDetails.getPricingPhases()))
        .setInstallmentPlanDetails(
            fromInstallmentPlanDetails(subscriptionOfferDetails.getInstallmentPlanDetails()))
        .build();
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
    return new PlatformPricingPhase.Builder()
        .setFormattedPrice(pricingPhase.getFormattedPrice())
        .setPriceCurrencyCode(pricingPhase.getPriceCurrencyCode())
        .setPriceAmountMicros(pricingPhase.getPriceAmountMicros())
        .setBillingCycleCount((long) pricingPhase.getBillingCycleCount())
        .setBillingPeriod(pricingPhase.getBillingPeriod())
        .setRecurrenceMode(toPlatformRecurrenceMode(pricingPhase.getRecurrenceMode()))
        .build();
  }

  static @Nullable Messages.PlatformInstallmentPlanDetails fromInstallmentPlanDetails(
      @Nullable ProductDetails.InstallmentPlanDetails installmentPlanDetails) {
    if (installmentPlanDetails == null) {
      return null;
    }

    return new Messages.PlatformInstallmentPlanDetails.Builder()
        .setCommitmentPaymentsCount(
            (long) installmentPlanDetails.getInstallmentPlanCommitmentPaymentsCount())
        .setSubsequentCommitmentPaymentsCount(
            (long) installmentPlanDetails.getSubsequentInstallmentPlanCommitmentPaymentsCount())
        .build();
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
    PlatformPurchase.Builder builder =
        new PlatformPurchase.Builder()
            .setOrderId(purchase.getOrderId())
            .setPackageName(purchase.getPackageName())
            .setPurchaseTime(purchase.getPurchaseTime())
            .setPurchaseToken(purchase.getPurchaseToken())
            .setSignature(purchase.getSignature())
            .setProducts(purchase.getProducts())
            .setIsAutoRenewing(purchase.isAutoRenewing())
            .setOriginalJson(purchase.getOriginalJson())
            .setDeveloperPayload(purchase.getDeveloperPayload())
            .setIsAcknowledged(purchase.isAcknowledged())
            .setPurchaseState(toPlatformPurchaseState(purchase.getPurchaseState()))
            .setQuantity((long) purchase.getQuantity());
    AccountIdentifiers accountIdentifiers = purchase.getAccountIdentifiers();
    if (accountIdentifiers != null) {
      builder.setAccountIdentifiers(
          new PlatformAccountIdentifiers.Builder()
              .setObfuscatedAccountId(accountIdentifiers.getObfuscatedAccountId())
              .setObfuscatedProfileId(accountIdentifiers.getObfuscatedProfileId())
              .build());
    }

    Purchase.PendingPurchaseUpdate pendingPurchaseUpdate = purchase.getPendingPurchaseUpdate();
    if (pendingPurchaseUpdate != null) {
      builder.setPendingPurchaseUpdate(fromPendingPurchaseUpdate(pendingPurchaseUpdate));
    }

    return builder.build();
  }

  static @Nullable PlatformPendingPurchaseUpdate fromPendingPurchaseUpdate(
      @Nullable Purchase.PendingPurchaseUpdate pendingPurchaseUpdate) {
    if (pendingPurchaseUpdate == null) {
      return null;
    }

    return new Messages.PlatformPendingPurchaseUpdate.Builder()
        .setPurchaseToken(pendingPurchaseUpdate.getPurchaseToken())
        .setProducts(pendingPurchaseUpdate.getProducts())
        .build();
  }

  static @NonNull PlatformPurchaseHistoryRecord fromPurchaseHistoryRecord(
      @NonNull PurchaseHistoryRecord purchaseHistoryRecord) {
    return new PlatformPurchaseHistoryRecord.Builder()
        .setPurchaseTime(purchaseHistoryRecord.getPurchaseTime())
        .setPurchaseToken(purchaseHistoryRecord.getPurchaseToken())
        .setSignature(purchaseHistoryRecord.getSignature())
        .setProducts(purchaseHistoryRecord.getProducts())
        .setDeveloperPayload(purchaseHistoryRecord.getDeveloperPayload())
        .setOriginalJson(purchaseHistoryRecord.getOriginalJson())
        .setQuantity((long) purchaseHistoryRecord.getQuantity())
        .build();
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
    return new PlatformBillingResult.Builder()
        .setResponseCode(fromBillingResponseCode(billingResult.getResponseCode()))
        .setDebugMessage(billingResult.getDebugMessage())
        .build();
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
    return new PlatformUserChoiceDetails.Builder()
        .setExternalTransactionToken(userChoiceDetails.getExternalTransactionToken())
        .setOriginalExternalTransactionId(userChoiceDetails.getOriginalExternalTransactionId())
        .setProducts(fromUserChoiceProductsList(userChoiceDetails.getProducts()))
        .build();
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
    return new PlatformUserChoiceProduct.Builder()
        .setId(product.getId())
        .setOfferToken(product.getOfferToken())
        .setType(toPlatformProductType(product.getType()))
        .build();
  }

  /** Converter from {@link BillingResult} and {@link BillingConfig} to map. */
  static @NonNull PlatformBillingConfigResponse fromBillingConfig(
      @NonNull BillingResult result, @Nullable BillingConfig billingConfig) {
    return new PlatformBillingConfigResponse.Builder()
        .setBillingResult(fromBillingResult(result))
        .setCountryCode(billingConfig == null ? "" : billingConfig.getCountryCode())
        .build();
  }

  /**
   * Converter from {@link BillingResult} and {@link AlternativeBillingOnlyReportingDetails} to map.
   */
  static @NonNull PlatformAlternativeBillingOnlyReportingDetailsResponse
      fromAlternativeBillingOnlyReportingDetails(
          @NonNull BillingResult result, @Nullable AlternativeBillingOnlyReportingDetails details) {
    return new PlatformAlternativeBillingOnlyReportingDetailsResponse.Builder()
        .setBillingResult(fromBillingResult(result))
        .setExternalTransactionToken(details == null ? "" : details.getExternalTransactionToken())
        .build();
  }

  static @NonNull PendingPurchasesParams toPendingPurchasesParams(
      @Nullable Messages.PlatformPendingPurchasesParams platformPendingPurchasesParams) {
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
