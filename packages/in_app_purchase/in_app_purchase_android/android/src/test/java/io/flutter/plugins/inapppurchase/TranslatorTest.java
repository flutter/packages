// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

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
      "{\"orderId\":\"foo\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\",\"developerPayload\":\"dummy payload\",\"isAcknowledged\":\"true\", \"obfuscatedAccountId\":\"Account101\", \"obfuscatedProfileId\":\"Profile105\"}";
  private static final String IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON =
      "{\"title\":\"Example title\",\"description\":\"Example description\",\"productId\":\"Example id\",\"type\":\"inapp\",\"name\":\"Example name\",\"oneTimePurchaseOfferDetails\":{\"priceAmountMicros\":990000,\"priceCurrencyCode\":\"USD\",\"formattedPrice\":\"$0.99\"}}";
  private static final String SUBS_PRODUCT_DETAIL_EXAMPLE_JSON =
      "{\"title\":\"Example title 2\",\"description\":\"Example description 2\",\"productId\":\"Example id 2\",\"type\":\"subs\",\"name\":\"Example name 2\",\"subscriptionOfferDetails\":[{\"offerId\":\"Example offer id\",\"basePlanId\":\"Example base plan id\",\"offerTags\":[\"Example offer tag\"],\"offerIdToken\":\"Example offer token\",\"pricingPhases\":[{\"formattedPrice\":\"$0.99\",\"priceCurrencyCode\":\"USD\",\"priceAmountMicros\":990000,\"billingCycleCount\":4,\"billingPeriod\":\"Example billing period\",\"recurrenceMode\":1}]}]}";

  Constructor<ProductDetails> productDetailsConstructor;

  @Before
  public void setup() throws NoSuchMethodException {
    Locale locale = new Locale("en", "us");
    Locale.setDefault(locale);

    productDetailsConstructor = ProductDetails.class.getDeclaredConstructor(String.class);
    productDetailsConstructor.setAccessible(true);
  }

  @Test
  public void fromInAppProductDetail()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final ProductDetails expected =
        productDetailsConstructor.newInstance(IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON);

    Messages.PlatformProductDetails serialized = Translator.fromProductDetail(expected);

    assertSerialized(expected, serialized);
  }

  @Test
  public void fromSubsProductDetail()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final ProductDetails expected =
        productDetailsConstructor.newInstance(SUBS_PRODUCT_DETAIL_EXAMPLE_JSON);

    Messages.PlatformProductDetails serialized = Translator.fromProductDetail(expected);

    assertSerialized(expected, serialized);
  }

  @Test
  public void fromProductDetailsList()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final List<ProductDetails> expected =
        Arrays.asList(
            productDetailsConstructor.newInstance(IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON),
            productDetailsConstructor.newInstance(SUBS_PRODUCT_DETAIL_EXAMPLE_JSON));

    final List<Messages.PlatformProductDetails> serialized =
        Translator.fromProductDetailsList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromProductDetailsList_null() {
    assertEquals(Collections.emptyList(), Translator.fromProductDetailsList(null));
  }

  @Test
  public void fromPurchase() throws JSONException {
    final Purchase expected = new Purchase(PURCHASE_EXAMPLE_JSON, "signature");
    assertSerialized(expected, Translator.fromPurchase(expected));
  }

  @Test
  public void fromPurchaseWithoutAccountIds() throws JSONException {
    final Purchase expected =
        new PurchaseWithoutAccountIdentifiers(PURCHASE_EXAMPLE_JSON, "signature");
    Messages.PlatformPurchase serialized = Translator.fromPurchase(expected);
    assertNotNull(serialized.getOrderId());
    assertNull(serialized.getAccountIdentifiers());
  }

  @Test
  public void fromPurchaseHistoryRecord() throws JSONException {
    final PurchaseHistoryRecord expected =
        new PurchaseHistoryRecord(PURCHASE_EXAMPLE_JSON, "signature");
    assertSerialized(expected, Translator.fromPurchaseHistoryRecord(expected));
  }

  @Test
  public void fromPurchasesHistoryRecordList() throws JSONException {
    final String purchase2Json =
        "{\"orderId\":\"foo2\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\",\"developerPayload\":\"dummy payload\",\"isAcknowledged\":\"true\"}";
    final String signature = "signature";
    final List<PurchaseHistoryRecord> expected =
        Arrays.asList(
            new PurchaseHistoryRecord(PURCHASE_EXAMPLE_JSON, signature),
            new PurchaseHistoryRecord(purchase2Json, signature));

    final List<Messages.PlatformPurchaseHistoryRecord> serialized =
        Translator.fromPurchaseHistoryRecordList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromPurchasesHistoryRecordList_null() {
    assertEquals(Collections.emptyList(), Translator.fromPurchaseHistoryRecordList(null));
  }

  @Test
  public void fromPurchasesList() throws JSONException {
    final String purchase2Json =
        "{\"orderId\":\"foo2\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\",\"developerPayload\":\"dummy payload\",\"isAcknowledged\":\"true\"}";
    final String signature = "signature";
    final List<Purchase> expected =
        Arrays.asList(
            new Purchase(PURCHASE_EXAMPLE_JSON, signature), new Purchase(purchase2Json, signature));

    final List<Messages.PlatformPurchase> serialized = Translator.fromPurchasesList(expected);

    assertEquals(expected.size(), serialized.size());
    assertSerialized(expected.get(0), serialized.get(0));
    assertSerialized(expected.get(1), serialized.get(1));
  }

  @Test
  public void fromPurchasesList_null() {
    assertEquals(Collections.emptyList(), Translator.fromPurchasesList(null));
  }

  @Test
  public void fromBillingResult() {
    BillingResult newBillingResult =
        BillingResult.newBuilder()
            .setDebugMessage("dummy debug message")
            .setResponseCode(BillingClient.BillingResponseCode.OK)
            .build();
    Messages.PlatformBillingResult platformResult = Translator.fromBillingResult(newBillingResult);

    assertEquals(platformResult.getResponseCode().longValue(), newBillingResult.getResponseCode());
    assertEquals(platformResult.getDebugMessage(), newBillingResult.getDebugMessage());
  }

  @Test
  public void fromBillingResult_debugMessageNull() {
    BillingResult newBillingResult =
        BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.OK).build();
    Messages.PlatformBillingResult platformResult = Translator.fromBillingResult(newBillingResult);

    assertEquals(platformResult.getResponseCode().longValue(), newBillingResult.getResponseCode());
    assertEquals(platformResult.getDebugMessage(), newBillingResult.getDebugMessage());
  }

  @Test
  public void currencyCodeFromSymbol() {
    assertEquals("$", Translator.currencySymbolFromCode("USD"));
    try {
      Translator.currencySymbolFromCode("EUROPACOIN");
      fail("Translator should throw an exception");
    } catch (Exception e) {
      assertTrue(e instanceof IllegalArgumentException);
    }
  }

  private void assertSerialized(
      ProductDetails expected, Messages.PlatformProductDetails serialized) {
    assertEquals(expected.getTitle(), serialized.getTitle());
    assertEquals(expected.getName(), serialized.getName());
    assertEquals(expected.getProductId(), serialized.getProductId());
    assertEquals(expected.getProductType(), productTypeFromPlatform(serialized.getProductType()));

    ProductDetails.OneTimePurchaseOfferDetails expectedOneTimePurchaseOfferDetails =
        expected.getOneTimePurchaseOfferDetails();
    Messages.PlatformOneTimePurchaseOfferDetails oneTimePurchaseOfferDetails =
        serialized.getOneTimePurchaseOfferDetails();
    assertEquals(expectedOneTimePurchaseOfferDetails == null, oneTimePurchaseOfferDetails == null);
    if (expectedOneTimePurchaseOfferDetails != null && oneTimePurchaseOfferDetails != null) {
      assertSerialized(expectedOneTimePurchaseOfferDetails, oneTimePurchaseOfferDetails);
    }

    List<ProductDetails.SubscriptionOfferDetails> expectedSubscriptionOfferDetailsList =
        expected.getSubscriptionOfferDetails();
    List<Messages.PlatformSubscriptionOfferDetails> subscriptionOfferDetailsList =
        serialized.getSubscriptionOfferDetails();
    assertEquals(
        expectedSubscriptionOfferDetailsList == null, subscriptionOfferDetailsList == null);
    if (expectedSubscriptionOfferDetailsList != null && subscriptionOfferDetailsList != null) {
      assertSerialized(expectedSubscriptionOfferDetailsList, subscriptionOfferDetailsList);
    }
  }

  private void assertSerialized(
      ProductDetails.OneTimePurchaseOfferDetails expected,
      Messages.PlatformOneTimePurchaseOfferDetails serialized) {
    assertEquals(expected.getPriceAmountMicros(), serialized.getPriceAmountMicros().longValue());
    assertEquals(expected.getPriceCurrencyCode(), serialized.getPriceCurrencyCode());
    assertEquals(expected.getFormattedPrice(), serialized.getFormattedPrice());
  }

  private void assertSerialized(
      List<ProductDetails.SubscriptionOfferDetails> expected,
      List<Messages.PlatformSubscriptionOfferDetails> serialized) {
    assertEquals(expected.size(), serialized.size());
    for (int i = 0; i < expected.size(); i++) {
      assertSerialized(expected.get(i), serialized.get(i));
    }
  }

  private void assertSerialized(
      ProductDetails.SubscriptionOfferDetails expected,
      Messages.PlatformSubscriptionOfferDetails serialized) {
    assertEquals(expected.getBasePlanId(), serialized.getBasePlanId());
    assertEquals(expected.getOfferId(), serialized.getOfferId());
    assertEquals(expected.getOfferTags(), serialized.getOfferTags());
    assertEquals(expected.getOfferToken(), serialized.getOfferToken());
    assertSerialized(expected.getPricingPhases(), serialized.getPricingPhases());
  }

  private void assertSerialized(
      ProductDetails.PricingPhases expected, List<Messages.PlatformPricingPhase> serialized) {
    List<ProductDetails.PricingPhase> expectedPhases = expected.getPricingPhaseList();
    assertEquals(expectedPhases.size(), serialized.size());
    for (int i = 0; i < serialized.size(); i++) {
      assertSerialized(expectedPhases.get(i), serialized.get(i));
    }
    expected.getPricingPhaseList();
  }

  private void assertSerialized(
      ProductDetails.PricingPhase expected, Messages.PlatformPricingPhase serialized) {
    assertEquals(expected.getFormattedPrice(), serialized.getFormattedPrice());
    assertEquals(expected.getPriceCurrencyCode(), serialized.getPriceCurrencyCode());
    assertEquals(expected.getPriceAmountMicros(), serialized.getPriceAmountMicros().longValue());
    assertEquals(expected.getBillingCycleCount(), serialized.getBillingCycleCount().intValue());
    assertEquals(expected.getBillingPeriod(), serialized.getBillingPeriod());
    assertEquals(
        expected.getRecurrenceMode(), recurrenceModeFromPlatform(serialized.getRecurrenceMode()));
  }

  private void assertSerialized(Purchase expected, Messages.PlatformPurchase serialized) {
    assertEquals(expected.getOrderId(), serialized.getOrderId());
    assertEquals(expected.getPackageName(), serialized.getPackageName());
    assertEquals(expected.getPurchaseTime(), serialized.getPurchaseTime().longValue());
    assertEquals(expected.getPurchaseToken(), serialized.getPurchaseToken());
    assertEquals(expected.getSignature(), serialized.getSignature());
    assertEquals(expected.getOriginalJson(), serialized.getOriginalJson());
    assertEquals(expected.getProducts(), serialized.getProducts());
    assertEquals(expected.getDeveloperPayload(), serialized.getDeveloperPayload());
    assertEquals(expected.isAcknowledged(), serialized.getIsAcknowledged());
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

  private String productTypeFromPlatform(Messages.PlatformProductType type) {
    switch (type) {
      case INAPP:
        return BillingClient.ProductType.INAPP;
      case SUBS:
        return BillingClient.ProductType.SUBS;
    }
    throw new IllegalStateException("Unhandled type");
  }

  private int stateFromPlatform(Messages.PlatformPurchaseState state) {
    switch (state) {
      case UNSPECIFIED:
        return Purchase.PurchaseState.UNSPECIFIED_STATE;
      case PURCHASED:
        return Purchase.PurchaseState.PURCHASED;
      case PENDING:
        return Purchase.PurchaseState.PENDING;
    }
    throw new IllegalStateException("Unhandled state");
  }

  private int recurrenceModeFromPlatform(Messages.PlatformRecurrenceMode mode) {
    switch (mode) {
      case FINITE_RECURRING:
        return ProductDetails.RecurrenceMode.FINITE_RECURRING;
      case INFINITE_RECURRING:
        return ProductDetails.RecurrenceMode.INFINITE_RECURRING;
      case NON_RECURRING:
        return ProductDetails.RecurrenceMode.NON_RECURRING;
    }
    throw new IllegalStateException("Unhandled mode");
  }

  private void assertSerialized(
      PurchaseHistoryRecord expected, Messages.PlatformPurchaseHistoryRecord serialized) {
    assertEquals(expected.getPurchaseTime(), serialized.getPurchaseTime().longValue());
    assertEquals(expected.getPurchaseToken(), serialized.getPurchaseToken());
    assertEquals(expected.getSignature(), serialized.getSignature());
    assertEquals(expected.getOriginalJson(), serialized.getOriginalJson());
    assertEquals(expected.getProducts(), serialized.getProducts());
    assertEquals(expected.getDeveloperPayload(), serialized.getDeveloperPayload());
    assertEquals(expected.getQuantity(), serialized.getQuantity().intValue());
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
