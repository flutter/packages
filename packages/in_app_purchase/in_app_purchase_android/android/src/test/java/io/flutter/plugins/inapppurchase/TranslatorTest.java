// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import androidx.annotation.NonNull;
import com.android.billingclient.api.AccountIdentifiers;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ProductDetails;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchaseHistoryRecord;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import org.json.JSONException;
import org.junit.Before;
import org.junit.Test;

public class TranslatorTest {
  private static final String PURCHASE_EXAMPLE_JSON =
      "{\"orderId\":\"foo\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\",\"developerPayload\":\"dummy"
          + " payload\",\"isAcknowledged\":\"true\", \"obfuscatedAccountId\":\"Account101\","
          + " \"obfuscatedProfileId\":\"Profile105\"}";
  private static final String IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON =
      "{\"title\":\"Example title\",\"description\":\"Example description\",\"productId\":\"Example"
          + " id\",\"type\":\"inapp\",\"name\":\"Example"
          + " name\",\"oneTimePurchaseOfferDetails\":{\"priceAmountMicros\":990000,\"priceCurrencyCode\":\"USD\",\"formattedPrice\":\"$0.99\"}}";
  private static final String SUBS_PRODUCT_DETAIL_EXAMPLE_JSON =
      "{\"title\":\"Example title 2\",\"description\":\"Example description"
          + " 2\",\"productId\":\"Example id 2\",\"type\":\"subs\",\"name\":\"Example name"
          + " 2\",\"subscriptionOfferDetails\":[{\"offerId\":\"Example offer"
          + " id\",\"basePlanId\":\"Example base plan id\",\"offerTags\":[\"Example offer"
          + " tag\"],\"offerIdToken\":\"Example offer"
          + " token\",\"pricingPhases\":[{\"formattedPrice\":\"$0.99\",\"priceCurrencyCode\":\"USD\",\"priceAmountMicros\":990000,\"billingCycleCount\":4,\"billingPeriod\":\"Example"
          + " billing period\",\"recurrenceMode\":1}]}]}";

  Constructor<ProductDetails> productDetailsConstructor;

  @Before
  public void setup() throws NoSuchMethodException {
    Locale locale = Locale.US;
    Locale.setDefault(locale);

    productDetailsConstructor = ProductDetails.class.getDeclaredConstructor(String.class);
    productDetailsConstructor.setAccessible(true);
  }

  @Test
  public void fromInAppProductDetail()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final ProductDetails expected =
        productDetailsConstructor.newInstance(IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON);

    PlatformProductDetails serialized = TranslatorKt.fromProductDetail(expected);

    assertSerialized(expected, serialized);
  }

  @Test
  public void fromSubsProductDetail()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final ProductDetails expected =
        productDetailsConstructor.newInstance(SUBS_PRODUCT_DETAIL_EXAMPLE_JSON);

    PlatformProductDetails serialized = TranslatorKt.fromProductDetail(expected);

    assertSerialized(expected, serialized);
  }

  @Test
  public void fromProductDetailsList()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final List<ProductDetails> expected =
        Arrays.asList(
            productDetailsConstructor.newInstance(IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON),
            productDetailsConstructor.newInstance(SUBS_PRODUCT_DETAIL_EXAMPLE_JSON));

    final List<PlatformProductDetails> serialized = TranslatorKt.fromProductDetailsList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromProductDetailsList_null() {
    assertEquals(Collections.emptyList(), TranslatorKt.fromProductDetailsList(null));
  }

  @Test
  public void fromPurchase() throws JSONException {
    final Purchase expected = new Purchase(PURCHASE_EXAMPLE_JSON, "signature");
    assertSerialized(expected, TranslatorKt.fromPurchase(expected));
  }

  @Test
  public void fromPurchaseWithoutAccountIds() throws JSONException {
    final Purchase expected =
        new PurchaseWithoutAccountIdentifiers(PURCHASE_EXAMPLE_JSON, "signature");
    PlatformPurchase serialized = TranslatorKt.fromPurchase(expected);
    assertNotNull(serialized.getOrderId());
    assertNull(serialized.getAccountIdentifiers());
  }

  @Test
  public void fromPurchaseHistoryRecord() throws JSONException {
    final PurchaseHistoryRecord expected =
        new PurchaseHistoryRecord(PURCHASE_EXAMPLE_JSON, "signature");
    assertSerialized(expected, TranslatorKt.fromPurchaseHistoryRecord(expected));
  }

  @Test
  public void fromPurchasesHistoryRecordList() throws JSONException {
    final String purchase2Json =
        "{\"orderId\":\"foo2\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\",\"developerPayload\":\"dummy"
            + " payload\",\"isAcknowledged\":\"true\"}";
    final String signature = "signature";
    final List<PurchaseHistoryRecord> expected =
        Arrays.asList(
            new PurchaseHistoryRecord(PURCHASE_EXAMPLE_JSON, signature),
            new PurchaseHistoryRecord(purchase2Json, signature));

    final List<PlatformPurchaseHistoryRecord> serialized =
        TranslatorKt.fromPurchaseHistoryRecordList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromPurchasesHistoryRecordList_null() {
    assertEquals(Collections.emptyList(), TranslatorKt.fromPurchaseHistoryRecordList(null));
  }

  @Test
  public void fromPurchasesList() throws JSONException {
    final String purchase2Json =
        "{\"orderId\":\"foo2\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\",\"developerPayload\":\"dummy"
            + " payload\",\"isAcknowledged\":\"true\"}";
    final String signature = "signature";
    final List<Purchase> expected =
        Arrays.asList(
            new Purchase(PURCHASE_EXAMPLE_JSON, signature), new Purchase(purchase2Json, signature));

    final List<PlatformPurchase> serialized = TranslatorKt.fromPurchasesList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromPurchasesList_null() {
    assertEquals(Collections.emptyList(), TranslatorKt.fromPurchasesList(null));
  }

  @Test
  public void fromBillingResult() {
    BillingResult newBillingResult =
        BillingResult.newBuilder()
            .setDebugMessage("dummy debug message")
            .setResponseCode(BillingClient.BillingResponseCode.OK)
            .build();
    PlatformBillingResult platformResult = TranslatorKt.fromBillingResult(newBillingResult);

    assertEquals(PlatformBillingResponse.OK, platformResult.getResponseCode());
    assertEquals(platformResult.getDebugMessage(), newBillingResult.getDebugMessage());
  }

  @Test
  public void fromBillingResult_debugMessageNull() {
    BillingResult newBillingResult =
        BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.OK).build();
    PlatformBillingResult platformResult = TranslatorKt.fromBillingResult(newBillingResult);

    assertEquals(PlatformBillingResponse.OK, platformResult.getResponseCode());
    assertEquals(platformResult.getDebugMessage(), newBillingResult.getDebugMessage());
  }

  private void assertSerialized(ProductDetails expected, PlatformProductDetails serialized) {
    assertEquals(expected.getTitle(), serialized.getTitle());
    assertEquals(expected.getName(), serialized.getName());
    assertEquals(expected.getProductId(), serialized.getProductId());
    assertEquals(expected.getProductType(), productTypeFromPlatform(serialized.getProductType()));

    ProductDetails.OneTimePurchaseOfferDetails expectedOneTimePurchaseOfferDetails =
        expected.getOneTimePurchaseOfferDetails();
    PlatformOneTimePurchaseOfferDetails oneTimePurchaseOfferDetails =
        serialized.getOneTimePurchaseOfferDetails();
    assertEquals(expectedOneTimePurchaseOfferDetails == null, oneTimePurchaseOfferDetails == null);
    if (expectedOneTimePurchaseOfferDetails != null && oneTimePurchaseOfferDetails != null) {
      assertSerialized(expectedOneTimePurchaseOfferDetails, oneTimePurchaseOfferDetails);
    }

    List<ProductDetails.SubscriptionOfferDetails> expectedSubscriptionOfferDetailsList =
        expected.getSubscriptionOfferDetails();
    List<PlatformSubscriptionOfferDetails> subscriptionOfferDetailsList =
        serialized.getSubscriptionOfferDetails();
    assertEquals(
        expectedSubscriptionOfferDetailsList == null, subscriptionOfferDetailsList == null);
    if (expectedSubscriptionOfferDetailsList != null && subscriptionOfferDetailsList != null) {
      assertSerialized(expectedSubscriptionOfferDetailsList, subscriptionOfferDetailsList);
    }
  }

  private void assertSerialized(
      ProductDetails.OneTimePurchaseOfferDetails expected,
      PlatformOneTimePurchaseOfferDetails serialized) {
    assertEquals(expected.getPriceAmountMicros(), serialized.getPriceAmountMicros());
    assertEquals(expected.getPriceCurrencyCode(), serialized.getPriceCurrencyCode());
    assertEquals(expected.getFormattedPrice(), serialized.getFormattedPrice());
  }

  private void assertSerialized(
      List<ProductDetails.SubscriptionOfferDetails> expected,
      List<PlatformSubscriptionOfferDetails> serialized) {
    assertEquals(expected.size(), serialized.size());
    for (int i = 0; i < expected.size(); i++) {
      assertSerialized(expected.get(i), serialized.get(i));
    }
  }

  private void assertSerialized(
      ProductDetails.SubscriptionOfferDetails expected,
      PlatformSubscriptionOfferDetails serialized) {
    assertEquals(expected.getBasePlanId(), serialized.getBasePlanId());
    assertEquals(expected.getOfferId(), serialized.getOfferId());
    assertEquals(expected.getOfferTags(), serialized.getOfferTags());
    assertEquals(expected.getOfferToken(), serialized.getOfferToken());
    assertSerialized(expected.getPricingPhases(), serialized.getPricingPhases());

    ProductDetails.InstallmentPlanDetails expectedInstallmentPlanDetails =
        expected.getInstallmentPlanDetails();
    PlatformInstallmentPlanDetails serializedInstallmentPlanDetails =
        serialized.getInstallmentPlanDetails();
    assertEquals(expectedInstallmentPlanDetails == null, serializedInstallmentPlanDetails == null);
    if (expectedInstallmentPlanDetails != null && serializedInstallmentPlanDetails != null) {
      assertSerialized(expectedInstallmentPlanDetails, serializedInstallmentPlanDetails);
    }
  }

  private void assertSerialized(
      ProductDetails.PricingPhases expected, List<PlatformPricingPhase> serialized) {
    List<ProductDetails.PricingPhase> expectedPhases = expected.getPricingPhaseList();
    assertEquals(expectedPhases.size(), serialized.size());
    for (int i = 0; i < serialized.size(); i++) {
      assertSerialized(expectedPhases.get(i), serialized.get(i));
    }
    expected.getPricingPhaseList();
  }

  private void assertSerialized(
      ProductDetails.PricingPhase expected, PlatformPricingPhase serialized) {
    assertEquals(expected.getFormattedPrice(), serialized.getFormattedPrice());
    assertEquals(expected.getPriceCurrencyCode(), serialized.getPriceCurrencyCode());
    assertEquals(expected.getPriceAmountMicros(), serialized.getPriceAmountMicros());
    assertEquals(expected.getBillingCycleCount(), serialized.getBillingCycleCount());
    assertEquals(expected.getBillingPeriod(), serialized.getBillingPeriod());
    assertEquals(
        expected.getRecurrenceMode(), recurrenceModeFromPlatform(serialized.getRecurrenceMode()));
  }

  private void assertSerialized(Purchase expected, PlatformPurchase serialized) {
    assertEquals(expected.getOrderId(), serialized.getOrderId());
    assertEquals(expected.getPackageName(), serialized.getPackageName());
    assertEquals(expected.getPurchaseTime(), serialized.getPurchaseTime());
    assertEquals(expected.getPurchaseToken(), serialized.getPurchaseToken());
    assertEquals(expected.getSignature(), serialized.getSignature());
    assertEquals(expected.getOriginalJson(), serialized.getOriginalJson());
    assertEquals(expected.getProducts(), serialized.getProducts());
    assertEquals(expected.getDeveloperPayload(), serialized.getDeveloperPayload());
    assertEquals(expected.isAcknowledged(), serialized.isAcknowledged());
    assertEquals(expected.getPurchaseState(), stateFromPlatform(serialized.getPurchaseState()));
    assertNotNull(
        Objects.requireNonNull(expected.getAccountIdentifiers()).getObfuscatedAccountId());
    assertEquals(
        expected.getAccountIdentifiers().getObfuscatedAccountId(),
        Objects.requireNonNull(serialized.getAccountIdentifiers()).getObfuscatedAccountId());
    assertNotNull(expected.getAccountIdentifiers().getObfuscatedProfileId());
    assertEquals(
        expected.getAccountIdentifiers().getObfuscatedProfileId(),
        Objects.requireNonNull(serialized.getAccountIdentifiers()).getObfuscatedProfileId());
  }

  private void assertSerialized(
      ProductDetails.InstallmentPlanDetails expected, PlatformInstallmentPlanDetails serialized) {
    assertEquals(
        expected.getInstallmentPlanCommitmentPaymentsCount(),
        serialized.getCommitmentPaymentsCount());
    assertEquals(
        expected.getSubsequentInstallmentPlanCommitmentPaymentsCount(),
        serialized.getSubsequentCommitmentPaymentsCount());
  }

  private String productTypeFromPlatform(PlatformProductType type) {
    return switch (type) {
      case INAPP -> BillingClient.ProductType.INAPP;
      case SUBS -> BillingClient.ProductType.SUBS;
    };
  }

  private int stateFromPlatform(PlatformPurchaseState state) {
    return switch (state) {
      case UNSPECIFIED -> Purchase.PurchaseState.UNSPECIFIED_STATE;
      case PURCHASED -> Purchase.PurchaseState.PURCHASED;
      case PENDING -> Purchase.PurchaseState.PENDING;
    };
  }

  private int recurrenceModeFromPlatform(PlatformRecurrenceMode mode) {
    return switch (mode) {
      case FINITE_RECURRING -> ProductDetails.RecurrenceMode.FINITE_RECURRING;
      case INFINITE_RECURRING -> ProductDetails.RecurrenceMode.INFINITE_RECURRING;
      case NON_RECURRING -> ProductDetails.RecurrenceMode.NON_RECURRING;
    };
  }

  private void assertSerialized(
      PurchaseHistoryRecord expected, PlatformPurchaseHistoryRecord serialized) {
    assertEquals(expected.getPurchaseTime(), serialized.getPurchaseTime());
    assertEquals(expected.getPurchaseToken(), serialized.getPurchaseToken());
    assertEquals(expected.getSignature(), serialized.getSignature());
    assertEquals(expected.getOriginalJson(), serialized.getOriginalJson());
    assertEquals(expected.getProducts(), serialized.getProducts());
    assertEquals(expected.getDeveloperPayload(), serialized.getDeveloperPayload());
    assertEquals(expected.getQuantity(), serialized.getQuantity());
  }
}

class PurchaseWithoutAccountIdentifiers extends Purchase {
  public PurchaseWithoutAccountIdentifiers(@NonNull String s, @NonNull String s1)
      throws JSONException {
    super(s, s1);
  }

  @Override
  public AccountIdentifiers getAccountIdentifiers() {
    return null;
  }
}
