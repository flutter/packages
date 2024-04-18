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
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ProductDetails;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchaseHistoryRecord;
import com.android.billingclient.api.QueryProductDetailsParams;
import com.android.billingclient.api.UserChoiceDetails;
import io.flutter.plugins.inapppurchase.Messages.FlutterError;
import io.flutter.plugins.inapppurchase.Messages.PlatformAccountIdentifiers;
import io.flutter.plugins.inapppurchase.Messages.PlatformAlternativeBillingOnlyReportingDetailsResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingConfigResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingResult;
import io.flutter.plugins.inapppurchase.Messages.PlatformOneTimePurchaseOfferDetails;
import io.flutter.plugins.inapppurchase.Messages.PlatformPricingPhase;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductDetails;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductType;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchase;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchaseHistoryRecord;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchaseState;
import io.flutter.plugins.inapppurchase.Messages.PlatformQueryProduct;
import io.flutter.plugins.inapppurchase.Messages.PlatformRecurrenceMode;
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
    return builder.build();
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
        .setResponseCode((long) billingResult.getResponseCode())
        .setDebugMessage(billingResult.getDebugMessage())
        .build();
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
