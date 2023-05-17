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
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.json.JSONException;
import org.junit.Before;
import org.junit.Test;

public class TranslatorTest {
  private static final String PURCHASE_EXAMPLE_JSON =
      "{\"orderId\":\"foo\",\"packageName\":\"bar\",\"productId\":\"consumable\",\"purchaseTime\":11111111,\"purchaseState\":0,\"purchaseToken\":\"baz\",\"developerPayload\":\"dummy payload\",\"isAcknowledged\":\"true\", \"obfuscatedAccountId\":\"Account101\", \"obfuscatedProfileId\":\"Profile105\"}";
  private static final String IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON =
      "{\"title\":\"Example title\",\"description\":\"Example description\",\"productId\":\"Example id\",\"type\":\"inapp\",\"name\":\"Example name\",\"oneTimePurchaseOfferDetails\":{\"priceAmountMicros\":990000,\"priceCurrencyCode\":\"USD\",\"formattedPrice\":\"$0.99\"}}";
  private static final String SUBS_PRODUCT_DETAIL_EXAMPLE_JSON =
      "{\"title\":\"Example title 2\",\"description\":\"Example description 2\",\"productId\":\"Example id 2\",\"type\":\"subs\",\"name\":\"Example name 2\",\"subscriptionOfferDetails\":[{\"offerId\":\"Example offer id\",\"basePlanId\":\"Example base plan id\",\"offerTags\":[\"Example offer tag\"],\"offerIdToken\":\"Example offer token\",\"pricingPhases\":[{\"formattedPrice\":\"$0.99\",\"priceCurrencyCode\":\"USD\",\"priceAmountMicros\":990000,\"billingCycleCount\":4,\"billingPeriod\":\"Example billing period\",\"recurrenceMode\":0}]}]}";

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

    Map<String, Object> serialized = Translator.fromProductDetail(expected);

    assertSerialized(expected, serialized);
  }

  @Test
  public void fromSubsProductDetail()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final ProductDetails expected =
        productDetailsConstructor.newInstance(SUBS_PRODUCT_DETAIL_EXAMPLE_JSON);

    Map<String, Object> serialized = Translator.fromProductDetail(expected);

    assertSerialized(expected, serialized);
  }

  @Test
  public void fromProductDetailsList()
      throws InvocationTargetException, IllegalAccessException, InstantiationException {
    final List<ProductDetails> expected =
        Arrays.asList(
            productDetailsConstructor.newInstance(IN_APP_PRODUCT_DETAIL_EXAMPLE_JSON),
            productDetailsConstructor.newInstance(SUBS_PRODUCT_DETAIL_EXAMPLE_JSON));

    final List<HashMap<String, Object>> serialized = Translator.fromProductDetailsList(expected);

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
    Map<String, Object> serialized = Translator.fromPurchase(expected);
    assertNotNull(serialized.get("orderId"));
    assertNull(serialized.get("obfuscatedProfileId"));
    assertNull(serialized.get("obfuscatedAccountId"));
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

    final List<HashMap<String, Object>> serialized =
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

    final List<HashMap<String, Object>> serialized = Translator.fromPurchasesList(expected);

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
    Map<String, Object> billingResultMap = Translator.fromBillingResult(newBillingResult);

    assertEquals(billingResultMap.get("responseCode"), newBillingResult.getResponseCode());
    assertEquals(billingResultMap.get("debugMessage"), newBillingResult.getDebugMessage());
  }

  @Test
  public void fromBillingResult_debugMessageNull() {
    BillingResult newBillingResult =
        BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.OK).build();
    Map<String, Object> billingResultMap = Translator.fromBillingResult(newBillingResult);

    assertEquals(billingResultMap.get("responseCode"), newBillingResult.getResponseCode());
    assertEquals(billingResultMap.get("debugMessage"), newBillingResult.getDebugMessage());
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

  private void assertSerialized(ProductDetails expected, Map<String, Object> serialized) {
    assertEquals(expected.getDescription(), serialized.get("description"));
    assertEquals(expected.getTitle(), serialized.get("title"));
    assertEquals(expected.getName(), serialized.get("name"));
    assertEquals(expected.getProductId(), serialized.get("productId"));
    assertEquals(expected.getProductType(), serialized.get("productType"));

    ProductDetails.OneTimePurchaseOfferDetails expectedOneTimePurchaseOfferDetails =
        expected.getOneTimePurchaseOfferDetails();
    Object oneTimePurchaseOfferDetailsObject = serialized.get("oneTimePurchaseOfferDetails");
    assertEquals(
        expectedOneTimePurchaseOfferDetails == null, oneTimePurchaseOfferDetailsObject == null);
    if (expectedOneTimePurchaseOfferDetails != null && oneTimePurchaseOfferDetailsObject != null) {
      @SuppressWarnings(value = "unchecked")
      Map<String, Object> oneTimePurchaseOfferDetailsMap =
          (Map<String, Object>) oneTimePurchaseOfferDetailsObject;
      assertSerialized(expectedOneTimePurchaseOfferDetails, oneTimePurchaseOfferDetailsMap);
    }

    List<ProductDetails.SubscriptionOfferDetails> expectedSubscriptionOfferDetailsList =
        expected.getSubscriptionOfferDetails();
    Object subscriptionOfferDetailsListObject = serialized.get("subscriptionOfferDetails");
    assertEquals(
        expectedSubscriptionOfferDetailsList == null, subscriptionOfferDetailsListObject == null);
    if (expectedSubscriptionOfferDetailsList != null
        && subscriptionOfferDetailsListObject != null) {
      @SuppressWarnings(value = "unchecked")
      List<Object> subscriptionOfferDetailsListList =
          (List<Object>) subscriptionOfferDetailsListObject;
      assertSerialized(expectedSubscriptionOfferDetailsList, subscriptionOfferDetailsListList);
    }
  }

  private void assertSerialized(
      ProductDetails.OneTimePurchaseOfferDetails expected, Map<String, Object> serialized) {
    assertEquals(expected.getPriceAmountMicros(), serialized.get("priceAmountMicros"));
    assertEquals(expected.getPriceCurrencyCode(), serialized.get("priceCurrencyCode"));
    assertEquals(expected.getFormattedPrice(), serialized.get("formattedPrice"));
  }

  private void assertSerialized(
      List<ProductDetails.SubscriptionOfferDetails> expected, List<Object> serialized) {
    assertEquals(expected.size(), serialized.size());
    for (int i = 0; i < expected.size(); i++) {
      @SuppressWarnings(value = "unchecked")
      Map<String, Object> serializedMap = (Map<String, Object>) serialized.get(i);
      assertSerialized(expected.get(i), serializedMap);
    }
  }

  private void assertSerialized(
      ProductDetails.SubscriptionOfferDetails expected, Map<String, Object> serialized) {
    assertEquals(expected.getBasePlanId(), serialized.get("basePlanId"));
    assertEquals(expected.getOfferId(), serialized.get("offerId"));
    assertEquals(expected.getOfferTags(), serialized.get("offerTags"));
    assertEquals(expected.getOfferToken(), serialized.get("offerIdToken"));

    @SuppressWarnings(value = "unchecked")
    List<Object> serializedPricingPhases = (List<Object>) serialized.get("pricingPhases");
    assertNotNull(serializedPricingPhases);
    assertSerialized(expected.getPricingPhases(), serializedPricingPhases);
  }

  private void assertSerialized(ProductDetails.PricingPhases expected, List<Object> serialized) {
    List<ProductDetails.PricingPhase> expectedPhases = expected.getPricingPhaseList();
    assertEquals(expectedPhases.size(), serialized.size());
    for (int i = 0; i < serialized.size(); i++) {
      @SuppressWarnings(value = "unchecked")
      Map<String, Object> pricingPhaseMap = (Map<String, Object>) serialized.get(i);
      assertSerialized(expectedPhases.get(i), pricingPhaseMap);
    }
    expected.getPricingPhaseList();
  }

  private void assertSerialized(
      ProductDetails.PricingPhase expected, Map<String, Object> serialized) {
    assertEquals(expected.getFormattedPrice(), serialized.get("formattedPrice"));
    assertEquals(expected.getPriceCurrencyCode(), serialized.get("priceCurrencyCode"));
    assertEquals(expected.getPriceAmountMicros(), serialized.get("priceAmountMicros"));
    assertEquals(expected.getBillingCycleCount(), serialized.get("billingCycleCount"));
    assertEquals(expected.getBillingPeriod(), serialized.get("billingPeriod"));
    assertEquals(expected.getRecurrenceMode(), serialized.get("recurrenceMode"));
  }

  private void assertSerialized(Purchase expected, Map<String, Object> serialized) {
    assertEquals(expected.getOrderId(), serialized.get("orderId"));
    assertEquals(expected.getPackageName(), serialized.get("packageName"));
    assertEquals(expected.getPurchaseTime(), serialized.get("purchaseTime"));
    assertEquals(expected.getPurchaseToken(), serialized.get("purchaseToken"));
    assertEquals(expected.getSignature(), serialized.get("signature"));
    assertEquals(expected.getOriginalJson(), serialized.get("originalJson"));
    assertEquals(expected.getProducts(), serialized.get("products"));
    assertEquals(expected.getDeveloperPayload(), serialized.get("developerPayload"));
    assertEquals(expected.isAcknowledged(), serialized.get("isAcknowledged"));
    assertEquals(expected.getPurchaseState(), serialized.get("purchaseState"));
    assertNotNull(expected.getAccountIdentifiers().getObfuscatedAccountId());
    assertEquals(
        expected.getAccountIdentifiers().getObfuscatedAccountId(),
        serialized.get("obfuscatedAccountId"));
    assertNotNull(expected.getAccountIdentifiers().getObfuscatedProfileId());
    assertEquals(
        expected.getAccountIdentifiers().getObfuscatedProfileId(),
        serialized.get("obfuscatedProfileId"));
  }

  private void assertSerialized(PurchaseHistoryRecord expected, Map<String, Object> serialized) {
    assertEquals(expected.getPurchaseTime(), serialized.get("purchaseTime"));
    assertEquals(expected.getPurchaseToken(), serialized.get("purchaseToken"));
    assertEquals(expected.getSignature(), serialized.get("signature"));
    assertEquals(expected.getOriginalJson(), serialized.get("originalJson"));
    assertEquals(expected.getProducts(), serialized.get("products"));
    assertEquals(expected.getDeveloperPayload(), serialized.get("developerPayload"));
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
