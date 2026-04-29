// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.ACTIVITY_UNAVAILABLE;
import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY;
import static io.flutter.plugins.inapppurchase.TranslatorKt.fromBillingResponseCode;
import static java.util.Arrays.asList;
import static java.util.Collections.singletonList;
import static java.util.stream.Collectors.toList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.refEq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.Nullable;
import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.AcknowledgePurchaseResponseListener;
import com.android.billingclient.api.AlternativeBillingOnlyAvailabilityListener;
import com.android.billingclient.api.AlternativeBillingOnlyInformationDialogListener;
import com.android.billingclient.api.AlternativeBillingOnlyReportingDetails;
import com.android.billingclient.api.AlternativeBillingOnlyReportingDetailsListener;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClient.BillingResponseCode;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingConfig;
import com.android.billingclient.api.BillingConfigResponseListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.GetBillingConfigParams;
import com.android.billingclient.api.ProductDetails;
import com.android.billingclient.api.ProductDetailsResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchaseHistoryRecord;
import com.android.billingclient.api.PurchaseHistoryResponseListener;
import com.android.billingclient.api.PurchasesResponseListener;
import com.android.billingclient.api.QueryProductDetailsParams;
import com.android.billingclient.api.QueryPurchaseHistoryParams;
import com.android.billingclient.api.QueryPurchasesParams;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.stubbing.Answer;

public class MethodCallHandlerTest {
  private AutoCloseable openMocks;
  private MethodCallHandlerImpl methodChannelHandler;
  @Mock BillingClientFactory factory;
  @Mock BillingClient mockBillingClient;
  @Mock InAppPurchaseCallbackApi mockCallbackApi;

  TestResult<PlatformAlternativeBillingOnlyReportingDetailsResponse>
      platformAlternativeBillingOnlyReportingDetailsResult = new TestResult<>();

  TestResult<PlatformBillingConfigResponse> platformBillingConfigResult = new TestResult<>();
  TestResult<PlatformBillingResult> platformBillingResult = new TestResult<>();
  TestResult<PlatformProductDetailsResponse> platformProductDetailsResult = new TestResult<>();
  TestResult<PlatformPurchaseHistoryResponse> platformPurchaseHistoryResult = new TestResult<>();
  TestResult<PlatformPurchasesResponse> platformPurchasesResult = new TestResult<>();

  @Mock Activity activity;
  @Mock Context context;
  @Mock ActivityPluginBinding mockActivityPluginBinding;

  private final PlatformPendingPurchasesParams defaultPendingPurchasesParams =
      new PlatformPendingPurchasesParams(false);

  private final Long DEFAULT_HANDLE = 1L;

  @Before
  public void setUp() {
    openMocks = MockitoAnnotations.openMocks(this);

    // Use the same client no matter if alternative billing is enabled or not.
    when(factory.createBillingClient(
            context,
            mockCallbackApi,
            PlatformBillingChoiceMode.PLAY_BILLING_ONLY,
            defaultPendingPurchasesParams))
        .thenReturn(mockBillingClient);
    when(factory.createBillingClient(
            context,
            mockCallbackApi,
            PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY,
            defaultPendingPurchasesParams))
        .thenReturn(mockBillingClient);
    when(factory.createBillingClient(
            any(Context.class),
            any(InAppPurchaseCallbackApi.class),
            eq(PlatformBillingChoiceMode.USER_CHOICE_BILLING),
            any(PlatformPendingPurchasesParams.class)))
        .thenReturn(mockBillingClient);
    methodChannelHandler = new MethodCallHandlerImpl(activity, context, mockCallbackApi, factory);
    when(mockActivityPluginBinding.getActivity()).thenReturn(activity);
  }

  @After
  public void tearDown() throws Exception {
    openMocks.close();
  }

  @Test
  public void isReady_true() {
    mockStartConnection();
    when(mockBillingClient.isReady()).thenReturn(true);
    boolean result = methodChannelHandler.isReady();
    assertTrue(result);
  }

  @Test
  public void isReady_false() {
    mockStartConnection();
    when(mockBillingClient.isReady()).thenReturn(false);
    boolean result = methodChannelHandler.isReady();
    assertFalse(result);
  }

  @Test
  public void isReady_clientDisconnected() {
    methodChannelHandler.endConnection();

    // Assert that the synchronous call throws an exception.
    FlutterError exception = assertThrows(FlutterError.class, () -> methodChannelHandler.isReady());
    assertEquals("UNAVAILABLE", exception.getCode());
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("BillingClient"));
  }

  @Test
  public void startConnection() {
    ArgumentCaptor<BillingClientStateListener> captor =
        mockStartConnection(
            PlatformBillingChoiceMode.PLAY_BILLING_ONLY, defaultPendingPurchasesParams);
    assertFalse(platformBillingResult.called);
    verify(factory, times(1))
        .createBillingClient(
            context,
            mockCallbackApi,
            PlatformBillingChoiceMode.PLAY_BILLING_ONLY,
            defaultPendingPurchasesParams);

    BillingResult billingResult = buildBillingResult();
    captor.getValue().onBillingSetupFinished(billingResult);

    assertTrue(platformBillingResult.called);
    assertResultsMatch(platformBillingResult.result.getOrNull(), billingResult);
  }

  @Test
  public void startConnectionAlternativeBillingOnly() {
    ArgumentCaptor<BillingClientStateListener> captor =
        mockStartConnection(
            PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY, defaultPendingPurchasesParams);
    assertFalse(platformBillingResult.called);
    verify(factory, times(1))
        .createBillingClient(
            context,
            mockCallbackApi,
            PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY,
            defaultPendingPurchasesParams);

    BillingResult billingResult = buildBillingResult();
    captor.getValue().onBillingSetupFinished(billingResult);

    assertTrue(platformBillingResult.called);
    assertResultsMatch(platformBillingResult.result.getOrNull(), billingResult);
  }

  @Test
  public void startConnectionPendingPurchasesPrepaidPlans() {
    PlatformPendingPurchasesParams pendingPurchasesParams =
        new PlatformPendingPurchasesParams(true);
    ArgumentCaptor<BillingClientStateListener> captor =
        mockStartConnection(PlatformBillingChoiceMode.USER_CHOICE_BILLING, pendingPurchasesParams);
    assertFalse(platformBillingResult.called);
    verify(factory, times(1))
        .createBillingClient(
            context,
            mockCallbackApi,
            PlatformBillingChoiceMode.USER_CHOICE_BILLING,
            pendingPurchasesParams);

    BillingResult billingResult = buildBillingResult();
    captor.getValue().onBillingSetupFinished(billingResult);

    assertTrue(platformBillingResult.called);
  }

  @Test
  public void startConnectionUserChoiceBilling() {
    ArgumentCaptor<BillingClientStateListener> captor =
        mockStartConnection(
            PlatformBillingChoiceMode.USER_CHOICE_BILLING, defaultPendingPurchasesParams);
    assertFalse(platformBillingResult.called);

    verify(factory, times(1))
        .createBillingClient(
            any(Context.class),
            any(InAppPurchaseCallbackApi.class),
            eq(PlatformBillingChoiceMode.USER_CHOICE_BILLING),
            any(PlatformPendingPurchasesParams.class));

    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    captor.getValue().onBillingSetupFinished(billingResult);

    assertTrue(platformBillingResult.called);
  }

  @Test
  public void userChoiceBillingOnSecondConnection() {
    // First connection.
    ArgumentCaptor<BillingClientStateListener> captor1 =
        mockStartConnection(
            PlatformBillingChoiceMode.PLAY_BILLING_ONLY, defaultPendingPurchasesParams);
    assertFalse(platformBillingResult.called);
    verify(factory, times(1))
        .createBillingClient(
            context,
            mockCallbackApi,
            PlatformBillingChoiceMode.PLAY_BILLING_ONLY,
            defaultPendingPurchasesParams);

    BillingResult billingResult1 =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    final BillingClientStateListener stateListener = captor1.getValue();
    stateListener.onBillingSetupFinished(billingResult1);
    assertTrue(platformBillingResult.called);

    // Reset state
    platformBillingResult.called = false;
    platformBillingResult.result = null;
    Mockito.reset(mockCallbackApi, mockBillingClient);

    // Disconnect
    methodChannelHandler.endConnection();

    verify(mockBillingClient, times(1)).endConnection();
    stateListener.onBillingServiceDisconnected();
    verify(mockCallbackApi, times(1)).onBillingServiceDisconnected(eq(DEFAULT_HANDLE), any());
    Mockito.reset(mockCallbackApi, mockBillingClient);

    // Second connection.
    ArgumentCaptor<BillingClientStateListener> captor2 =
        mockStartConnection(
            PlatformBillingChoiceMode.USER_CHOICE_BILLING, defaultPendingPurchasesParams);
    assertFalse(platformBillingResult.called);
    verify(factory, times(1))
        .createBillingClient(
            any(Context.class),
            any(InAppPurchaseCallbackApi.class),
            eq(PlatformBillingChoiceMode.USER_CHOICE_BILLING),
            eq(defaultPendingPurchasesParams));

    BillingResult billingResult2 =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    captor2.getValue().onBillingSetupFinished(billingResult2);

    assertTrue(platformBillingResult.called);
  }

  @Test
  public void startConnection_multipleCalls() {
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());

    methodChannelHandler.startConnection(
        DEFAULT_HANDLE,
        PlatformBillingChoiceMode.PLAY_BILLING_ONLY,
        defaultPendingPurchasesParams,
        platformBillingResult.asCallback());
    assertFalse(platformBillingResult.called);
    BillingResult billingResult1 = buildBillingResult();
    BillingResult billingResult2 =
        BillingResult.newBuilder()
            .setResponseCode(200)
            .setDebugMessage("dummy debug message")
            .build();
    BillingResult billingResult3 =
        BillingResult.newBuilder()
            .setResponseCode(300)
            .setDebugMessage("dummy debug message")
            .build();

    captor.getValue().onBillingSetupFinished(billingResult1);
    captor.getValue().onBillingSetupFinished(billingResult2);
    captor.getValue().onBillingSetupFinished(billingResult3);

    assertTrue(platformBillingResult.called);
    PlatformBillingResult response = platformBillingResult.result.getOrNull();
    assertEquals(
        response.getResponseCode(), fromBillingResponseCode(billingResult1.getResponseCode()));
    assertEquals(response.getDebugMessage(), billingResult1.getDebugMessage());
  }

  @Test
  public void getBillingConfigSuccess() {
    mockStartConnection();
    ArgumentCaptor<GetBillingConfigParams> paramsCaptor =
        ArgumentCaptor.forClass(GetBillingConfigParams.class);
    ArgumentCaptor<BillingConfigResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(BillingConfigResponseListener.class);
    BillingResult billingResult = buildBillingResult();
    final String expectedCountryCode = "US";
    final BillingConfig expectedConfig = mock(BillingConfig.class);
    when(expectedConfig.getCountryCode()).thenReturn(expectedCountryCode);

    doNothing()
        .when(mockBillingClient)
        .getBillingConfigAsync(paramsCaptor.capture(), listenerCaptor.capture());

    methodChannelHandler.getBillingConfigAsync(platformBillingConfigResult.asCallback());
    listenerCaptor.getValue().onBillingConfigResponse(billingResult, expectedConfig);

    assertTrue(platformBillingConfigResult.called);
    PlatformBillingConfigResponse response = platformBillingConfigResult.result.getOrNull();
    assertResultsMatch(response.getBillingResult(), billingResult);
    assertEquals(expectedCountryCode, response.getCountryCode());
  }

  @Test
  public void getBillingConfig_serviceDisconnected() {
    methodChannelHandler.getBillingConfigAsync(platformBillingConfigResult.asCallback());

    // Assert that the async call returns an error result.
    assertTrue(platformBillingConfigResult.called);
    Throwable error = platformBillingConfigResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals("UNAVAILABLE", flutterError.getCode());
    assertTrue(Objects.requireNonNull(flutterError.getMessage()).contains("BillingClient"));
  }

  @Test
  public void createAlternativeBillingOnlyReportingDetailsSuccess() {
    mockStartConnection();
    ArgumentCaptor<AlternativeBillingOnlyReportingDetailsListener> listenerCaptor =
        ArgumentCaptor.forClass(AlternativeBillingOnlyReportingDetailsListener.class);
    BillingResult billingResult = buildBillingResult(BillingResponseCode.OK);
    final AlternativeBillingOnlyReportingDetails expectedDetails =
        mock(AlternativeBillingOnlyReportingDetails.class);
    final String expectedExternalTransactionToken = "abc123youandme";

    when(expectedDetails.getExternalTransactionToken())
        .thenReturn(expectedExternalTransactionToken);
    doNothing()
        .when(mockBillingClient)
        .createAlternativeBillingOnlyReportingDetailsAsync(listenerCaptor.capture());

    methodChannelHandler.createAlternativeBillingOnlyReportingDetailsAsync(
        platformAlternativeBillingOnlyReportingDetailsResult.asCallback());
    listenerCaptor.getValue().onAlternativeBillingOnlyTokenResponse(billingResult, expectedDetails);

    assertTrue(platformAlternativeBillingOnlyReportingDetailsResult.called);
    PlatformAlternativeBillingOnlyReportingDetailsResponse response =
        platformAlternativeBillingOnlyReportingDetailsResult.result.getOrNull();
    assertResultsMatch(response.getBillingResult(), billingResult);
    assertEquals(expectedExternalTransactionToken, response.getExternalTransactionToken());
  }

  @Test
  public void createAlternativeBillingOnlyReportingDetails_serviceDisconnected() {
    methodChannelHandler.createAlternativeBillingOnlyReportingDetailsAsync(
        platformAlternativeBillingOnlyReportingDetailsResult.asCallback());

    // Assert that the async call returns an error result.
    assertTrue(platformAlternativeBillingOnlyReportingDetailsResult.called);
    Throwable error = platformAlternativeBillingOnlyReportingDetailsResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals("UNAVAILABLE", flutterError.getCode());
    assertTrue(Objects.requireNonNull(flutterError.getMessage()).contains("BillingClient"));
  }

  @Test
  public void isAlternativeBillingOnlyAvailableSuccess() {
    mockStartConnection();
    ArgumentCaptor<AlternativeBillingOnlyAvailabilityListener> listenerCaptor =
        ArgumentCaptor.forClass(AlternativeBillingOnlyAvailabilityListener.class);
    BillingResult billingResult = buildBillingResult(BillingClient.BillingResponseCode.OK);

    doNothing()
        .when(mockBillingClient)
        .isAlternativeBillingOnlyAvailableAsync(listenerCaptor.capture());

    methodChannelHandler.isAlternativeBillingOnlyAvailableAsync(platformBillingResult.asCallback());
    listenerCaptor.getValue().onAlternativeBillingOnlyAvailabilityResponse(billingResult);

    assertTrue(platformBillingResult.called);
    assertResultsMatch(platformBillingResult.result.getOrNull(), billingResult);
  }

  @Test
  public void isAlternativeBillingOnlyAvailable_serviceDisconnected() {
    methodChannelHandler.isAlternativeBillingOnlyAvailableAsync(platformBillingResult.asCallback());

    // Assert that the async call returns an error result.
    assertTrue(platformBillingResult.called);
    Throwable error = platformBillingResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals("UNAVAILABLE", flutterError.getCode());
    assertTrue(Objects.requireNonNull(flutterError.getMessage()).contains("BillingClient"));
  }

  @Test
  public void showAlternativeBillingOnlyInformationDialogSuccess() {
    mockStartConnection();
    ArgumentCaptor<AlternativeBillingOnlyInformationDialogListener> listenerCaptor =
        ArgumentCaptor.forClass(AlternativeBillingOnlyInformationDialogListener.class);
    BillingResult billingResult = buildBillingResult(BillingClient.BillingResponseCode.OK);

    when(mockBillingClient.showAlternativeBillingOnlyInformationDialog(
            eq(activity), listenerCaptor.capture()))
        .thenReturn(billingResult);

    methodChannelHandler.showAlternativeBillingOnlyInformationDialog(
        platformBillingResult.asCallback());
    listenerCaptor.getValue().onAlternativeBillingOnlyInformationDialogResponse(billingResult);

    assertTrue(platformBillingResult.called);
    assertResultsMatch(platformBillingResult.result.getOrNull(), billingResult);
  }

  @Test
  public void showAlternativeBillingOnlyInformationDialog_serviceDisconnected() {
    methodChannelHandler.showAlternativeBillingOnlyInformationDialog(
        platformBillingResult.asCallback());

    // Assert that the async call returns an error result.
    assertTrue(platformBillingResult.called);
    Throwable error = platformBillingResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals("UNAVAILABLE", flutterError.getCode());
    assertTrue(Objects.requireNonNull(flutterError.getMessage()).contains("BillingClient"));
  }

  @Test
  public void showAlternativeBillingOnlyInformationDialog_NullActivity() {
    mockStartConnection();
    methodChannelHandler.setActivity(null);

    methodChannelHandler.showAlternativeBillingOnlyInformationDialog(
        platformBillingResult.asCallback());

    // Assert that the async call returns an error result.
    assertTrue(platformBillingResult.called);
    Throwable error = platformBillingResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals(ACTIVITY_UNAVAILABLE, flutterError.getCode());
    assertTrue(
        Objects.requireNonNull(flutterError.getMessage())
            .contains("Not attempting to show dialog"));
  }

  @Test
  public void endConnection() {
    // Set up a connected BillingClient instance
    final long disconnectCallbackHandle = 22;
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());

    methodChannelHandler.startConnection(
        disconnectCallbackHandle,
        PlatformBillingChoiceMode.PLAY_BILLING_ONLY,
        defaultPendingPurchasesParams,
        ResultCompat.asCompatCallback(reply -> Unit.INSTANCE));
    final BillingClientStateListener stateListener = captor.getValue();

    // Disconnect the connected client
    methodChannelHandler.endConnection();

    // Verify that the client is disconnected and that the OnDisconnect callback has
    // been triggered
    verify(mockBillingClient, times(1)).endConnection();
    stateListener.onBillingServiceDisconnected();
    ArgumentCaptor<Long> handleCaptor = ArgumentCaptor.forClass(Long.class);
    verify(mockCallbackApi, times(1)).onBillingServiceDisconnected(handleCaptor.capture(), any());
    assertEquals(disconnectCallbackHandle, handleCaptor.getValue().longValue());
  }

  @Test
  public void queryProductDetailsAsync() {
    establishConnectedBillingClient();
    List<String> productsIds = asList("id1", "id2");
    final List<PlatformQueryProduct> productList =
        buildProductList(productsIds, PlatformProductType.INAPP);

    methodChannelHandler.queryProductDetailsAsync(
        productList, platformProductDetailsResult.asCallback());

    ArgumentCaptor<QueryProductDetailsParams> paramCaptor =
        ArgumentCaptor.forClass(QueryProductDetailsParams.class);
    ArgumentCaptor<ProductDetailsResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(ProductDetailsResponseListener.class);
    verify(mockBillingClient)
        .queryProductDetailsAsync(paramCaptor.capture(), listenerCaptor.capture());

    List<ProductDetails> productDetailsResponse = singletonList(buildProductDetails("foo"));
    BillingResult billingResult = buildBillingResult();
    listenerCaptor.getValue().onProductDetailsResponse(billingResult, productDetailsResponse);

    assertTrue(platformProductDetailsResult.called);
    PlatformProductDetailsResponse resultData = platformProductDetailsResult.result.getOrNull();
    assertResultsMatch(resultData.getBillingResult(), billingResult);
    assertDetailListsMatch(productDetailsResponse, resultData.getProductDetails());
  }

  @Test
  public void queryProductDetailsAsync_clientDisconnected() {
    methodChannelHandler.endConnection();
    List<String> productsIds = asList("id1", "id2");
    final List<PlatformQueryProduct> productList =
        buildProductList(productsIds, PlatformProductType.INAPP);

    methodChannelHandler.queryProductDetailsAsync(
        productList, platformProductDetailsResult.asCallback());

    assertTrue(platformProductDetailsResult.called);
    Throwable error = platformProductDetailsResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals("UNAVAILABLE", flutterError.getCode());
    assertTrue(Objects.requireNonNull(flutterError.getMessage()).contains("BillingClient"));
  }

  // Test launchBillingFlow not crash if `accountId` is `null`
  // Ideally, we should check if the `accountId` is null in the parameter; however,
  // since PBL 3.0, the `accountId` variable is not public.
  @Test
  public void launchBillingFlow_null_AccountId_do_not_crash() {
    String productId = "foo";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            null,
            null,
            null,
            null);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult = methodChannelHandler.launchBillingFlow(params);

    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_null_OldProduct() {
    String productId = "foo";
    String accountId = "account";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            accountId,
            null,
            null,
            null);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult = methodChannelHandler.launchBillingFlow(params);

    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_null_Activity() {
    methodChannelHandler.setActivity(null);

    String productId = "foo";
    String accountId = "account";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            accountId,
            null,
            null,
            null);

    FlutterError exception =
        assertThrows(FlutterError.class, () -> methodChannelHandler.launchBillingFlow(params));
    assertEquals("ACTIVITY_UNAVAILABLE", exception.getCode());
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("foreground"));
  }

  @Test
  public void launchBillingFlow_ok_oldProduct() {
    String productId = "foo";
    String accountId = "account";
    String oldProductId = "oldFoo";
    queryForProducts(List.of(productId, oldProductId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            accountId,
            null,
            oldProductId,
            null);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult = methodChannelHandler.launchBillingFlow(params);

    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_AccountId() {
    String productId = "foo";
    String accountId = "account";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            accountId,
            null,
            null,
            null);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult = methodChannelHandler.launchBillingFlow(params);

    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_Proration() {
    String productId = "foo";
    String oldProductId = "oldFoo";
    String purchaseToken = "purchaseTokenFoo";
    String accountId = "account";
    PlatformReplacementMode replacementMode = PlatformReplacementMode.CHARGE_PRORATED_PRICE;
    queryForProducts(List.of(productId, oldProductId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId, replacementMode, null, accountId, null, oldProductId, purchaseToken);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult = methodChannelHandler.launchBillingFlow(params);

    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_Proration_with_null_OldProduct() {
    String productId = "foo";
    String accountId = "account";
    String queryOldProductId = "oldFoo";
    PlatformReplacementMode replacementMode = PlatformReplacementMode.CHARGE_PRORATED_PRICE;
    queryForProducts(List.of(productId, queryOldProductId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId, replacementMode, null, accountId, null, null, null);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);

    FlutterError exception =
        assertThrows(FlutterError.class, () -> methodChannelHandler.launchBillingFlow(params));
    assertEquals("IN_APP_PURCHASE_REQUIRE_OLD_PRODUCT", exception.getCode());
    assertTrue(
        Objects.requireNonNull(exception.getMessage())
            .contains("launchBillingFlow failed because oldProduct is null"));
  }

  @Test
  @SuppressWarnings(value = "deprecation")
  public void launchBillingFlow_ok_Replacement_with_null_OldProduct() {
    String productId = "foo";
    String accountId = "account";
    String queryOldProductId = "oldFoo";
    PlatformReplacementMode replacementMode = PlatformReplacementMode.CHARGE_PRORATED_PRICE;
    queryForProducts(List.of(productId, queryOldProductId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId, replacementMode, null, accountId, null, null, null);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);

    FlutterError exception =
        assertThrows(FlutterError.class, () -> methodChannelHandler.launchBillingFlow(params));
    assertEquals("IN_APP_PURCHASE_REQUIRE_OLD_PRODUCT", exception.getCode());
    assertTrue(
        Objects.requireNonNull(exception.getMessage())
            .contains("launchBillingFlow failed because oldProduct is null"));
  }

  @Test
  public void launchBillingFlow_ok_Full() {
    String productId = "foo";
    String oldProductId = "oldFoo";
    String purchaseToken = "purchaseTokenFoo";
    String accountId = "account";
    PlatformReplacementMode replacementMode = PlatformReplacementMode.CHARGE_FULL_PRICE;
    queryForProducts(List.of(productId, oldProductId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId, replacementMode, null, accountId, null, oldProductId, purchaseToken);

    BillingResult billingResult = buildBillingResult();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult = methodChannelHandler.launchBillingFlow(params);

    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_clientDisconnected() {
    methodChannelHandler.endConnection();
    String productId = "foo";
    String accountId = "account";
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            accountId,
            null,
            null,
            null);

    FlutterError exception =
        assertThrows(FlutterError.class, () -> methodChannelHandler.launchBillingFlow(params));
    assertEquals("UNAVAILABLE", exception.getCode());
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("BillingClient"));
  }

  @Test
  public void launchBillingFlow_productNotFound() {
    establishConnectedBillingClient();
    String productId = "foo";
    String accountId = "account";
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            accountId,
            null,
            null,
            null);

    FlutterError exception =
        assertThrows(FlutterError.class, () -> methodChannelHandler.launchBillingFlow(params));
    assertEquals("NOT_FOUND", exception.getCode());
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains(productId));
  }

  @Test
  public void launchBillingFlow_oldProductNotFound() {
    establishConnectedBillingClient();
    String productId = "foo";
    String accountId = "account";
    String oldProductId = "oldProduct";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams params =
        new PlatformBillingFlowParams(
            productId,
            REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY,
            null,
            accountId,
            null,
            oldProductId,
            null);

    FlutterError exception =
        assertThrows(FlutterError.class, () -> methodChannelHandler.launchBillingFlow(params));
    assertEquals("IN_APP_PURCHASE_INVALID_OLD_PRODUCT", exception.getCode());
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains(oldProductId));
  }

  @Test
  public void queryPurchases_clientDisconnected() {
    methodChannelHandler.endConnection();

    methodChannelHandler.queryPurchasesAsync(
        PlatformProductType.INAPP, platformPurchasesResult.asCallback());

    assertTrue(platformPurchasesResult.called);
    Throwable error = platformPurchasesResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals("UNAVAILABLE", flutterError.getCode());
    assertTrue(Objects.requireNonNull(flutterError.getMessage()).contains("BillingClient"));
  }

  @Test
  public void queryPurchases_returns_success() {
    establishConnectedBillingClient();

    ArgumentCaptor<PurchasesResponseListener> purchasesResponseListenerArgumentCaptor =
        ArgumentCaptor.forClass(PurchasesResponseListener.class);
    doAnswer(
            (Answer<Object>)
                invocation -> {
                  BillingResult.Builder resultBuilder =
                      BillingResult.newBuilder()
                          .setResponseCode(BillingClient.BillingResponseCode.OK)
                          .setDebugMessage("hello message");
                  purchasesResponseListenerArgumentCaptor
                      .getValue()
                      .onQueryPurchasesResponse(resultBuilder.build(), new ArrayList<>());
                  return null;
                })
        .when(mockBillingClient)
        .queryPurchasesAsync(
            any(QueryPurchasesParams.class), purchasesResponseListenerArgumentCaptor.capture());

    methodChannelHandler.queryPurchasesAsync(
        PlatformProductType.INAPP, platformPurchasesResult.asCallback());

    assertTrue(platformPurchasesResult.called);
    PlatformPurchasesResponse purchasesResponse = platformPurchasesResult.result.getOrNull();
    assertEquals(
        PlatformBillingResponse.OK, purchasesResponse.getBillingResult().getResponseCode());
    assertTrue(purchasesResponse.getPurchases().isEmpty());
  }

  @Test
  @SuppressWarnings(value = "deprecation")
  public void queryPurchaseHistoryAsync() {
    establishConnectedBillingClient();
    BillingResult billingResult = buildBillingResult();
    final String purchaseToken = "foo";
    List<PurchaseHistoryRecord> purchasesList =
        singletonList(buildPurchaseHistoryRecord(purchaseToken));
    ArgumentCaptor<PurchaseHistoryResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(PurchaseHistoryResponseListener.class);

    methodChannelHandler.queryPurchaseHistoryAsync(
        PlatformProductType.INAPP, platformPurchaseHistoryResult.asCallback());

    verify(mockBillingClient)
        .queryPurchaseHistoryAsync(any(QueryPurchaseHistoryParams.class), listenerCaptor.capture());
    listenerCaptor.getValue().onPurchaseHistoryResponse(billingResult, purchasesList);

    assertTrue(platformPurchaseHistoryResult.called);
    PlatformPurchaseHistoryResponse result = platformPurchaseHistoryResult.result.getOrNull();
    assertResultsMatch(result.getBillingResult(), billingResult);
    assertEquals(1, result.getPurchases().size());
    assertEquals(purchaseToken, result.getPurchases().get(0).getPurchaseToken());
  }

  @Test
  @SuppressWarnings(value = "deprecation")
  public void queryPurchaseHistoryAsync_clientDisconnected() {
    methodChannelHandler.endConnection();

    methodChannelHandler.queryPurchaseHistoryAsync(
        PlatformProductType.INAPP, platformPurchaseHistoryResult.asCallback());

    // Assert that the async call returns an error result.
    assertTrue(platformPurchaseHistoryResult.called);
    Throwable error = platformPurchaseHistoryResult.result.exceptionOrNull();
    assertTrue(error instanceof FlutterError);
    FlutterError flutterError = (FlutterError) error;
    assertEquals("UNAVAILABLE", flutterError.getCode());
    assertTrue(Objects.requireNonNull(flutterError.getMessage()).contains("BillingClient"));
  }

  @Test
  public void onPurchasesUpdatedListener() {
    PluginPurchaseListener listener = new PluginPurchaseListener(mockCallbackApi);

    BillingResult billingResult = buildBillingResult();
    final String orderId = "foo";
    List<Purchase> purchasesList = singletonList(buildPurchase(orderId));
    ArgumentCaptor<PlatformPurchasesResponse> resultCaptor =
        ArgumentCaptor.forClass(PlatformPurchasesResponse.class);
    doNothing().when(mockCallbackApi).onPurchasesUpdated(resultCaptor.capture(), any());
    listener.onPurchasesUpdated(billingResult, purchasesList);

    PlatformPurchasesResponse response = resultCaptor.getValue();
    assertResultsMatch(response.getBillingResult(), billingResult);
    assertEquals(1, response.getPurchases().size());
    assertEquals(orderId, response.getPurchases().get(0).getOrderId());
  }

  @Test
  public void consumeAsync() {
    establishConnectedBillingClient();
    BillingResult billingResult = buildBillingResult();
    final String token = "mockToken";
    ArgumentCaptor<ConsumeResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(ConsumeResponseListener.class);

    methodChannelHandler.consumeAsync(token, platformBillingResult.asCallback());

    ConsumeParams params = ConsumeParams.newBuilder().setPurchaseToken(token).build();

    verify(mockBillingClient).consumeAsync(refEq(params), listenerCaptor.capture());

    listenerCaptor.getValue().onConsumeResponse(billingResult, token);

    assertTrue(platformBillingResult.called);
    assertResultsMatch(platformBillingResult.result.getOrNull(), billingResult);
  }

  @Test
  public void acknowledgePurchase() {
    establishConnectedBillingClient();
    BillingResult billingResult = buildBillingResult();
    final String purchaseToken = "mockToken";
    ArgumentCaptor<AcknowledgePurchaseResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(AcknowledgePurchaseResponseListener.class);

    methodChannelHandler.acknowledgePurchase(purchaseToken, platformBillingResult.asCallback());

    AcknowledgePurchaseParams params =
        AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchaseToken).build();

    verify(mockBillingClient).acknowledgePurchase(refEq(params), listenerCaptor.capture());

    listenerCaptor.getValue().onAcknowledgePurchaseResponse(billingResult);

    assertTrue(platformBillingResult.called);
    assertResultsMatch(platformBillingResult.result.getOrNull(), billingResult);
  }

  @Test
  public void endConnection_if_activity_detached() {
    InAppPurchasePlugin plugin = new InAppPurchasePlugin();
    plugin.setMethodCallHandler(methodChannelHandler);
    mockStartConnection();
    plugin.onDetachedFromActivity();
    verify(mockBillingClient).endConnection();
  }

  @Test
  public void isFutureSupported_true() {
    mockStartConnection();
    final String feature = "subscriptions";

    BillingResult billingResult = buildBillingResult(BillingClient.BillingResponseCode.OK);
    when(mockBillingClient.isFeatureSupported(feature)).thenReturn(billingResult);

    assertTrue(methodChannelHandler.isFeatureSupported(PlatformBillingClientFeature.SUBSCRIPTIONS));
  }

  @Test
  public void isFutureSupported_false() {
    mockStartConnection();
    final String feature = "subscriptions";

    BillingResult billingResult = buildBillingResult(BillingResponseCode.FEATURE_NOT_SUPPORTED);
    when(mockBillingClient.isFeatureSupported(feature)).thenReturn(billingResult);

    assertFalse(
        methodChannelHandler.isFeatureSupported(PlatformBillingClientFeature.SUBSCRIPTIONS));
  }

  /**
   * Call {@link MethodCallHandlerImpl#startConnection(long, PlatformBillingChoiceMode,
   * PlatformPendingPurchasesParams, Function1)} with startup params.
   *
   * <p>Defaults to play billing only which is the default.
   */
  private ArgumentCaptor<BillingClientStateListener> mockStartConnection() {
    return mockStartConnection(
        PlatformBillingChoiceMode.PLAY_BILLING_ONLY, defaultPendingPurchasesParams);
  }

  /**
   * Call {@link MethodCallHandlerImpl#startConnection(long, PlatformBillingChoiceMode,
   * PlatformPendingPurchasesParams, Function1)} with startup params.
   */
  private ArgumentCaptor<BillingClientStateListener> mockStartConnection(
      PlatformBillingChoiceMode billingChoiceMode,
      PlatformPendingPurchasesParams pendingPurchasesParams) {
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());

    methodChannelHandler.startConnection(
        DEFAULT_HANDLE,
        billingChoiceMode,
        pendingPurchasesParams,
        platformBillingResult.asCallback());
    return captor;
  }

  private void establishConnectedBillingClient() {
    methodChannelHandler.startConnection(
        DEFAULT_HANDLE,
        PlatformBillingChoiceMode.PLAY_BILLING_ONLY,
        defaultPendingPurchasesParams,
        ResultCompat.asCompatCallback(reply -> Unit.INSTANCE));
  }

  private void queryForProducts(List<String> productIdList) {
    // Set up the query method call
    establishConnectedBillingClient();
    List<String> productsIds = asList("id1", "id2");
    final List<PlatformQueryProduct> productList =
        buildProductList(productsIds, PlatformProductType.INAPP);

    // Call the method.
    methodChannelHandler.queryProductDetailsAsync(
        productList, platformProductDetailsResult.asCallback());

    // Respond to the call with a matching set of product details.
    ArgumentCaptor<ProductDetailsResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(ProductDetailsResponseListener.class);
    verify(mockBillingClient).queryProductDetailsAsync(any(), listenerCaptor.capture());
    List<ProductDetails> productDetailsResponse =
        productIdList.stream().map(this::buildProductDetails).collect(toList());

    BillingResult billingResult = buildBillingResult();
    listenerCaptor.getValue().onProductDetailsResponse(billingResult, productDetailsResponse);
  }

  private List<PlatformQueryProduct> buildProductList(
      List<String> productIds, PlatformProductType productType) {
    List<PlatformQueryProduct> productList = new ArrayList<>();
    for (String productId : productIds) {
      productList.add(new PlatformQueryProduct(productId, productType));
    }
    return productList;
  }

  private ProductDetails buildProductDetails(String id) {
    String json =
        String.format(
            "{\"title\":\"Example title\",\"description\":\"Example"
                + " description\",\"productId\":\"%s\",\"type\":\"inapp\",\"name\":\"Example"
                + " name\",\"oneTimePurchaseOfferDetails\":{\"priceAmountMicros\":990000,\"priceCurrencyCode\":\"USD\",\"formattedPrice\":\"$0.99\"}}",
            id);

    try {
      Constructor<ProductDetails> productDetailsConstructor =
          ProductDetails.class.getDeclaredConstructor(String.class);
      productDetailsConstructor.setAccessible(true);
      return productDetailsConstructor.newInstance(json);
    } catch (NoSuchMethodException e) {
      fail("buildProductDetails failed with NoSuchMethodException " + e);
    } catch (InvocationTargetException e) {
      fail("buildProductDetails failed with InvocationTargetException " + e);
    } catch (IllegalAccessException e) {
      fail("buildProductDetails failed with IllegalAccessException " + e);
    } catch (InstantiationException e) {
      fail("buildProductDetails failed with InstantiationException " + e);
    }
    return null;
  }

  private Purchase buildPurchase(String orderId) {
    Purchase purchase = mock(Purchase.class);
    when(purchase.getOrderId()).thenReturn(orderId);
    when(purchase.getPurchaseState()).thenReturn(Purchase.PurchaseState.UNSPECIFIED_STATE);
    when(purchase.getQuantity()).thenReturn(1);
    when(purchase.getPurchaseTime()).thenReturn(0L);
    when(purchase.getDeveloperPayload()).thenReturn("");
    when(purchase.getOriginalJson()).thenReturn("");
    when(purchase.getPackageName()).thenReturn("");
    when(purchase.getPurchaseToken()).thenReturn("");
    when(purchase.getSignature()).thenReturn("");
    when(purchase.getProducts()).thenReturn(Collections.emptyList());
    return purchase;
  }

  private PurchaseHistoryRecord buildPurchaseHistoryRecord(String purchaseToken) {
    PurchaseHistoryRecord purchase = mock(PurchaseHistoryRecord.class);
    when(purchase.getPurchaseToken()).thenReturn(purchaseToken);
    when(purchase.getQuantity()).thenReturn(1);
    when(purchase.getPurchaseTime()).thenReturn(0L);
    when(purchase.getDeveloperPayload()).thenReturn("");
    when(purchase.getOriginalJson()).thenReturn("");
    when(purchase.getSignature()).thenReturn("");
    when(purchase.getProducts()).thenReturn(Collections.emptyList());
    return purchase;
  }

  private BillingResult buildBillingResult() {
    return buildBillingResult(100);
  }

  private BillingResult buildBillingResult(int responseCode) {
    return BillingResult.newBuilder()
        .setResponseCode(responseCode)
        .setDebugMessage("dummy debug message")
        .build();
  }

  private void assertResultsMatch(
      @Nullable PlatformBillingResult pigeonResult, BillingResult nativeResult) {
    assertNotNull(pigeonResult);
    assertEquals(
        pigeonResult.getResponseCode(), fromBillingResponseCode(nativeResult.getResponseCode()));
    assertEquals(pigeonResult.getDebugMessage(), nativeResult.getDebugMessage());
  }

  private void assertDetailListsMatch(
      List<ProductDetails> expected, List<PlatformProductDetails> actual) {
    assertEquals(expected.size(), actual.size());
    for (int i = 0; i < expected.size(); i++) {
      assertDetailsMatch(expected.get(i), actual.get(i));
    }
  }

  private void assertDetailsMatch(ProductDetails expected, PlatformProductDetails actual) {
    assertEquals(expected.getDescription(), actual.getDescription());
    assertEquals(expected.getName(), actual.getName());
    assertEquals(expected.getProductId(), actual.getProductId());
    assertEquals(expected.getTitle(), actual.getTitle());
    // This doesn't do a deep match; TranslatorTest covers that. This is just a sanity check.
    assertEquals(
        expected.getOneTimePurchaseOfferDetails() == null,
        actual.getOneTimePurchaseOfferDetails() == null);
    assertEquals(
        expected.getSubscriptionOfferDetails() == null,
        actual.getSubscriptionOfferDetails() == null);
  }

  private static class TestResult<T> implements Function1<ResultCompat<T>, Unit> {
    ResultCompat<T> result;
    boolean called = false;

    @Override
    public Unit invoke(ResultCompat<T> reply) {
      this.result = reply;
      this.called = true;
      return Unit.INSTANCE;
    }

    public Function1<? super Result<T>, Unit> asCallback() {
      return ResultCompat.asCompatCallback(this);
    }
  }
}
