// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.ACTIVITY_UNAVAILABLE;
import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.MethodNames.CREATE_ALTERNATIVE_BILLING_ONLY_REPORTING_DETAILS;
import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.MethodNames.GET_BILLING_CONFIG;
import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.MethodNames.ON_DISCONNECT;
import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.MethodNames.QUERY_PURCHASES_ASYNC;
import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.MethodNames.QUERY_PURCHASE_HISTORY_ASYNC;
import static io.flutter.plugins.inapppurchase.MethodCallHandlerImpl.PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY;
import static io.flutter.plugins.inapppurchase.PluginPurchaseListener.ON_PURCHASES_UPDATED;
import static io.flutter.plugins.inapppurchase.Translator.fromAlternativeBillingOnlyReportingDetails;
import static io.flutter.plugins.inapppurchase.Translator.fromBillingConfig;
import static io.flutter.plugins.inapppurchase.Translator.fromBillingResult;
import static io.flutter.plugins.inapppurchase.Translator.fromProductDetailsList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchaseHistoryRecordList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesList;
import static java.util.Arrays.asList;
import static java.util.Collections.singletonList;
import static java.util.Collections.unmodifiableList;
import static java.util.stream.Collectors.toList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.refEq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
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
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingChoiceMode;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingFlowParams;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingResult;
import io.flutter.plugins.inapppurchase.Messages.PlatformProduct;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductDetailsResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductType;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.mockito.stubbing.Answer;

public class MethodCallHandlerTest {
  private AutoCloseable openMocks;
  private MethodCallHandlerImpl methodChannelHandler;
  @Mock BillingClientFactory factory;
  @Mock BillingClient mockBillingClient;
  @Mock MethodChannel mockMethodChannel;
  @Spy Result result;
  @Spy Messages.Result<PlatformBillingResult> platformBillingResult;
  @Spy Messages.Result<PlatformProductDetailsResponse> platformProductDetailsResult;
  @Mock Activity activity;
  @Mock Context context;
  @Mock ActivityPluginBinding mockActivityPluginBinding;
  @Captor ArgumentCaptor<HashMap<String, Object>> resultCaptor;

  @Before
  public void setUp() {
    openMocks = MockitoAnnotations.openMocks(this);
    // Use the same client no matter if alternative billing is enabled or not.
    when(factory.createBillingClient(
            context, mockMethodChannel, PlatformBillingChoiceMode.PLAY_BILLING_ONLY))
        .thenReturn(mockBillingClient);
    when(factory.createBillingClient(
            context, mockMethodChannel, PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY))
        .thenReturn(mockBillingClient);
    methodChannelHandler = new MethodCallHandlerImpl(activity, context, mockMethodChannel, factory);
    when(mockActivityPluginBinding.getActivity()).thenReturn(activity);
  }

  @After
  public void tearDown() throws Exception {
    openMocks.close();
  }

  @Test
  public void invalidMethod() {
    MethodCall call = new MethodCall("invalid", null);
    methodChannelHandler.onMethodCall(call, result);
    verify(result, times(1)).notImplemented();
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

    Messages.FlutterError exception =
        assertThrows(Messages.FlutterError.class, () -> methodChannelHandler.isReady());
    assertEquals("UNAVAILABLE", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("BillingClient"));
  }

  @Test
  public void startConnection() {
    ArgumentCaptor<BillingClientStateListener> captor =
        mockStartConnection(PlatformBillingChoiceMode.PLAY_BILLING_ONLY);
    verify(platformBillingResult, never()).success(any());
    verify(factory, times(1))
        .createBillingClient(
            context, mockMethodChannel, PlatformBillingChoiceMode.PLAY_BILLING_ONLY);

    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    captor.getValue().onBillingSetupFinished(billingResult);

    ArgumentCaptor<PlatformBillingResult> resultCaptor =
        ArgumentCaptor.forClass(PlatformBillingResult.class);
    verify(platformBillingResult, times(1)).success(resultCaptor.capture());
    assertResultsMatch(resultCaptor.getValue(), billingResult);
  }

  @Test
  public void startConnectionAlternativeBillingOnly() {
    ArgumentCaptor<BillingClientStateListener> captor =
        mockStartConnection(PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY);
    verify(platformBillingResult, never()).success(any());
    verify(factory, times(1))
        .createBillingClient(
            context, mockMethodChannel, PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY);

    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    captor.getValue().onBillingSetupFinished(billingResult);

    ArgumentCaptor<PlatformBillingResult> resultCaptor =
        ArgumentCaptor.forClass(PlatformBillingResult.class);
    verify(platformBillingResult, times(1)).success(resultCaptor.capture());
    assertResultsMatch(resultCaptor.getValue(), billingResult);
  }

  @Test
  public void startConnection_multipleCalls() {
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());

    methodChannelHandler.startConnection(
        1L, PlatformBillingChoiceMode.PLAY_BILLING_ONLY, platformBillingResult);
    verify(platformBillingResult, never()).success(any());
    BillingResult billingResult1 =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
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

    ArgumentCaptor<PlatformBillingResult> resultCaptor =
        ArgumentCaptor.forClass(PlatformBillingResult.class);
    verify(platformBillingResult, times(1)).success(resultCaptor.capture());
    assertEquals(
        resultCaptor.getValue().getResponseCode().longValue(), billingResult1.getResponseCode());
    assertEquals(resultCaptor.getValue().getDebugMessage(), billingResult1.getDebugMessage());
    verify(platformBillingResult, times(1)).success(any());
  }

  @Test
  public void getBillingConfigSuccess() {
    mockStartConnection();
    ArgumentCaptor<GetBillingConfigParams> paramsCaptor =
        ArgumentCaptor.forClass(GetBillingConfigParams.class);
    ArgumentCaptor<BillingConfigResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(BillingConfigResponseListener.class);
    MethodCall billingCall = new MethodCall(GET_BILLING_CONFIG, null);
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    final String expectedCountryCode = "US";
    final BillingConfig expectedConfig = mock(BillingConfig.class);
    when(expectedConfig.getCountryCode()).thenReturn(expectedCountryCode);

    doNothing()
        .when(mockBillingClient)
        .getBillingConfigAsync(paramsCaptor.capture(), listenerCaptor.capture());

    methodChannelHandler.onMethodCall(billingCall, result);
    listenerCaptor.getValue().onBillingConfigResponse(billingResult, expectedConfig);

    verify(result, times(1)).success(fromBillingConfig(billingResult, expectedConfig));
  }

  @Test
  public void getBillingConfig_serviceDisconnected() {
    MethodCall billingCall = new MethodCall(GET_BILLING_CONFIG, null);
    methodChannelHandler.onMethodCall(billingCall, mock(Result.class));

    methodChannelHandler.onMethodCall(billingCall, result);

    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
  }

  @Test
  public void createAlternativeBillingOnlyReportingDetailsSuccess() {
    mockStartConnection();
    ArgumentCaptor<AlternativeBillingOnlyReportingDetailsListener> listenerCaptor =
        ArgumentCaptor.forClass(AlternativeBillingOnlyReportingDetailsListener.class);
    MethodCall createABOReportingDetailsCall =
        new MethodCall(CREATE_ALTERNATIVE_BILLING_ONLY_REPORTING_DETAILS, null);
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(BillingResponseCode.OK)
            .setDebugMessage("dummy debug message")
            .build();
    final AlternativeBillingOnlyReportingDetails expectedDetails =
        mock(AlternativeBillingOnlyReportingDetails.class);
    final String expectedExternalTransactionToken = "abc123youandme";

    when(expectedDetails.getExternalTransactionToken())
        .thenReturn(expectedExternalTransactionToken);
    doNothing()
        .when(mockBillingClient)
        .createAlternativeBillingOnlyReportingDetailsAsync(listenerCaptor.capture());

    methodChannelHandler.onMethodCall(createABOReportingDetailsCall, result);
    listenerCaptor.getValue().onAlternativeBillingOnlyTokenResponse(billingResult, expectedDetails);

    verify(result, times(1))
        .success(fromAlternativeBillingOnlyReportingDetails(billingResult, expectedDetails));
  }

  @Test
  public void createAlternativeBillingOnlyReportingDetails_serviceDisconnected() {
    MethodCall createCall = new MethodCall(CREATE_ALTERNATIVE_BILLING_ONLY_REPORTING_DETAILS, null);
    methodChannelHandler.onMethodCall(createCall, mock(Result.class));

    methodChannelHandler.onMethodCall(createCall, result);

    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
  }

  @Test
  public void isAlternativeBillingOnlyAvailableSuccess() {
    mockStartConnection();
    ArgumentCaptor<AlternativeBillingOnlyAvailabilityListener> listenerCaptor =
        ArgumentCaptor.forClass(AlternativeBillingOnlyAvailabilityListener.class);
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(BillingClient.BillingResponseCode.OK)
            .setDebugMessage("dummy debug message")
            .build();

    doNothing()
        .when(mockBillingClient)
        .isAlternativeBillingOnlyAvailableAsync(listenerCaptor.capture());

    methodChannelHandler.isAlternativeBillingOnlyAvailableAsync(platformBillingResult);
    listenerCaptor.getValue().onAlternativeBillingOnlyAvailabilityResponse(billingResult);

    ArgumentCaptor<PlatformBillingResult> resultCaptor =
        ArgumentCaptor.forClass(PlatformBillingResult.class);
    verify(platformBillingResult, times(1)).success(resultCaptor.capture());
    assertResultsMatch(resultCaptor.getValue(), billingResult);
  }

  @Test
  public void isAlternativeBillingOnlyAvailable_serviceDisconnected() {
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () ->
                methodChannelHandler.isAlternativeBillingOnlyAvailableAsync(platformBillingResult));
    assertEquals("UNAVAILABLE", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("BillingClient"));
  }

  @Test
  public void showAlternativeBillingOnlyInformationDialogSuccess() {
    mockStartConnection();
    ArgumentCaptor<AlternativeBillingOnlyInformationDialogListener> listenerCaptor =
        ArgumentCaptor.forClass(AlternativeBillingOnlyInformationDialogListener.class);
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(BillingResponseCode.OK)
            .setDebugMessage("dummy debug message")
            .build();

    when(mockBillingClient.showAlternativeBillingOnlyInformationDialog(
            eq(activity), listenerCaptor.capture()))
        .thenReturn(billingResult);

    methodChannelHandler.showAlternativeBillingOnlyInformationDialog(platformBillingResult);
    listenerCaptor.getValue().onAlternativeBillingOnlyInformationDialogResponse(billingResult);

    ArgumentCaptor<PlatformBillingResult> resultCaptor =
        ArgumentCaptor.forClass(PlatformBillingResult.class);
    verify(platformBillingResult, times(1)).success(resultCaptor.capture());
    assertResultsMatch(resultCaptor.getValue(), billingResult);
  }

  @Test
  public void showAlternativeBillingOnlyInformationDialog_serviceDisconnected() {
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () ->
                methodChannelHandler.showAlternativeBillingOnlyInformationDialog(
                    platformBillingResult));
    assertEquals("UNAVAILABLE", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("BillingClient"));
  }

  @Test
  public void showAlternativeBillingOnlyInformationDialog_NullActivity() {
    mockStartConnection();
    methodChannelHandler.setActivity(null);

    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () ->
                methodChannelHandler.showAlternativeBillingOnlyInformationDialog(
                    platformBillingResult));
    assertEquals(ACTIVITY_UNAVAILABLE, exception.code);
    assertTrue(
        Objects.requireNonNull(exception.getMessage()).contains("Not attempting to show dialog"));
  }

  @Test
  public void endConnection() {
    // Set up a connected BillingClient instance
    final long disconnectCallbackHandle = 22;
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());
    @SuppressWarnings("unchecked")
    final Messages.Result<PlatformBillingResult> mockResult = mock(Messages.Result.class);
    methodChannelHandler.startConnection(
        disconnectCallbackHandle, PlatformBillingChoiceMode.PLAY_BILLING_ONLY, mockResult);
    final BillingClientStateListener stateListener = captor.getValue();

    // Disconnect the connected client
    methodChannelHandler.endConnection();

    // Verify that the client is disconnected and that the OnDisconnect callback has
    // been triggered
    verify(mockBillingClient, times(1)).endConnection();
    stateListener.onBillingServiceDisconnected();
    Map<String, Long> expectedInvocation = new HashMap<>();
    expectedInvocation.put("handle", disconnectCallbackHandle);
    verify(mockMethodChannel, times(1)).invokeMethod(ON_DISCONNECT, expectedInvocation);
  }

  @Test
  public void queryProductDetailsAsync() {
    // Connect a billing client and set up the product query listeners
    establishConnectedBillingClient();
    List<String> productsIds = asList("id1", "id2");
    final List<PlatformProduct> productList =
        buildProductList(productsIds, PlatformProductType.INAPP);

    // Query for product details
    methodChannelHandler.queryProductDetailsAsync(productList, platformProductDetailsResult);

    // Assert the arguments were forwarded correctly to BillingClient
    ArgumentCaptor<QueryProductDetailsParams> paramCaptor =
        ArgumentCaptor.forClass(QueryProductDetailsParams.class);
    ArgumentCaptor<ProductDetailsResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(ProductDetailsResponseListener.class);
    verify(mockBillingClient)
        .queryProductDetailsAsync(paramCaptor.capture(), listenerCaptor.capture());

    // Assert that we handed result BillingClient's response
    List<ProductDetails> productDetailsResponse = singletonList(buildProductDetails("foo"));
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    listenerCaptor.getValue().onProductDetailsResponse(billingResult, productDetailsResponse);
    ArgumentCaptor<PlatformProductDetailsResponse> resultCaptor =
        ArgumentCaptor.forClass(PlatformProductDetailsResponse.class);
    verify(platformProductDetailsResult).success(resultCaptor.capture());
    PlatformProductDetailsResponse resultData = resultCaptor.getValue();
    assertResultsMatch(resultData.getBillingResult(), billingResult);
    assertEquals(
        resultData.getProductDetailsJsonList(), fromProductDetailsList(productDetailsResponse));
  }

  @Test
  public void queryProductDetailsAsync_clientDisconnected() {
    // Disconnect the Billing client and prepare a queryProductDetails call
    methodChannelHandler.endConnection();
    List<String> productsIds = asList("id1", "id2");
    final List<PlatformProduct> productList =
        buildProductList(productsIds, PlatformProductType.INAPP);

    // Assert that we throw an error.
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () ->
                methodChannelHandler.queryProductDetailsAsync(
                    productList, platformProductDetailsResult));
    assertEquals("UNAVAILABLE", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("BillingClient"));
  }

  // Test launchBillingFlow not crash if `accountId` is `null`
  // Ideally, we should check if the `accountId` is null in the parameter; however,
  // since PBL 3.0, the `accountId` variable is not public.
  @Test
  public void launchBillingFlow_null_AccountId_do_not_crash() {
    // Fetch the product details first and then prepare the launch billing flow call
    String productId = "foo";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Launch the billing flow
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult =
        methodChannelHandler.launchBillingFlow(paramsBuilder.build());

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_null_OldProduct() {
    // Fetch the product details first and then prepare the launch billing flow call
    String productId = "foo";
    String accountId = "account";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Launch the billing flow
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult =
        methodChannelHandler.launchBillingFlow(paramsBuilder.build());

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());

    // Verify the response.
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_null_Activity() {
    methodChannelHandler.setActivity(null);

    // Fetch the product details first and then prepare the launch billing flow call
    String productId = "foo";
    String accountId = "account";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Verify the error response.
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () -> methodChannelHandler.launchBillingFlow(paramsBuilder.build()));
    assertEquals("ACTIVITY_UNAVAILABLE", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("foreground"));
    verify(result, never()).success(any());
  }

  @Test
  public void launchBillingFlow_ok_oldProduct() {
    // Fetch the product details first and query the method call
    String productId = "foo";
    String accountId = "account";
    String oldProductId = "oldFoo";
    queryForProducts(unmodifiableList(asList(productId, oldProductId)));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setOldProduct(oldProductId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Launch the billing flow
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult =
        methodChannelHandler.launchBillingFlow(paramsBuilder.build());

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());

    // Verify the response.
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_ok_AccountId() {
    // Fetch the product details first and query the method call
    String productId = "foo";
    String accountId = "account";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Launch the billing flow
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult =
        methodChannelHandler.launchBillingFlow(paramsBuilder.build());

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());

    // Verify the response.
    assertResultsMatch(platformResult, billingResult);
  }

  // TODO(gmackall): Replace uses of deprecated ProrationMode enum values with new
  // ReplacementMode enum values.
  // https://github.com/flutter/flutter/issues/128957.
  @Test
  @SuppressWarnings(value = "deprecation")
  public void launchBillingFlow_ok_Proration() {
    // Fetch the product details first and query the method call
    String productId = "foo";
    String oldProductId = "oldFoo";
    String purchaseToken = "purchaseTokenFoo";
    String accountId = "account";
    int prorationMode = BillingFlowParams.ProrationMode.IMMEDIATE_AND_CHARGE_PRORATED_PRICE;
    queryForProducts(unmodifiableList(asList(productId, oldProductId)));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setOldProduct(oldProductId);
    paramsBuilder.setPurchaseToken(purchaseToken);
    paramsBuilder.setProrationMode((long) prorationMode);

    // Launch the billing flow
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult =
        methodChannelHandler.launchBillingFlow(paramsBuilder.build());

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());

    // Verify the response.
    assertResultsMatch(platformResult, billingResult);
  }

  // TODO(gmackall): Replace uses of deprecated ProrationMode enum values with new
  // ReplacementMode enum values.
  // https://github.com/flutter/flutter/issues/128957.
  @Test
  @SuppressWarnings(value = "deprecation")
  public void launchBillingFlow_ok_Proration_with_null_OldProduct() {
    // Fetch the product details first and query the method call
    String productId = "foo";
    String accountId = "account";
    String queryOldProductId = "oldFoo";
    int prorationMode = BillingFlowParams.ProrationMode.IMMEDIATE_AND_CHARGE_PRORATED_PRICE;
    queryForProducts(unmodifiableList(asList(productId, queryOldProductId)));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setOldProduct(null);
    paramsBuilder.setProrationMode((long) prorationMode);

    // Launch the billing flow
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);

    // Assert that we sent an error back.
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () -> methodChannelHandler.launchBillingFlow(paramsBuilder.build()));
    assertEquals("IN_APP_PURCHASE_REQUIRE_OLD_PRODUCT", exception.code);
    assertTrue(
        Objects.requireNonNull(exception.getMessage())
            .contains("launchBillingFlow failed because oldProduct is null"));
  }

  // TODO(gmackall): Replace uses of deprecated ProrationMode enum values with new
  // ReplacementMode enum values.
  // https://github.com/flutter/flutter/issues/128957.
  @Test
  @SuppressWarnings(value = "deprecation")
  public void launchBillingFlow_ok_Full() {
    // Fetch the product details first and query the method call
    String productId = "foo";
    String oldProductId = "oldFoo";
    String purchaseToken = "purchaseTokenFoo";
    String accountId = "account";
    int prorationMode = BillingFlowParams.ProrationMode.IMMEDIATE_AND_CHARGE_FULL_PRICE;
    queryForProducts(unmodifiableList(asList(productId, oldProductId)));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setOldProduct(oldProductId);
    paramsBuilder.setPurchaseToken(purchaseToken);
    paramsBuilder.setProrationMode((long) prorationMode);

    // Launch the billing flow
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.launchBillingFlow(any(), any())).thenReturn(billingResult);
    PlatformBillingResult platformResult =
        methodChannelHandler.launchBillingFlow(paramsBuilder.build());

    // Verify we pass the arguments to the billing flow
    ArgumentCaptor<BillingFlowParams> billingFlowParamsCaptor =
        ArgumentCaptor.forClass(BillingFlowParams.class);
    verify(mockBillingClient).launchBillingFlow(any(), billingFlowParamsCaptor.capture());

    // Verify the response.
    assertResultsMatch(platformResult, billingResult);
  }

  @Test
  public void launchBillingFlow_clientDisconnected() {
    // Prepare the launch call after disconnecting the client
    methodChannelHandler.endConnection();
    String productId = "foo";
    String accountId = "account";
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Assert that we sent an error back.
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () -> methodChannelHandler.launchBillingFlow(paramsBuilder.build()));
    assertEquals("UNAVAILABLE", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains("BillingClient"));
  }

  @Test
  public void launchBillingFlow_productNotFound() {
    // Try to launch the billing flow for a random product ID
    establishConnectedBillingClient();
    String productId = "foo";
    String accountId = "account";
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Assert that we sent an error back.
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () -> methodChannelHandler.launchBillingFlow(paramsBuilder.build()));
    assertEquals("NOT_FOUND", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains(productId));
  }

  @Test
  public void launchBillingFlow_oldProductNotFound() {
    // Try to launch the billing flow for a random product ID
    establishConnectedBillingClient();
    String productId = "foo";
    String accountId = "account";
    String oldProductId = "oldProduct";
    queryForProducts(singletonList(productId));
    PlatformBillingFlowParams.Builder paramsBuilder = new PlatformBillingFlowParams.Builder();
    paramsBuilder.setProduct(productId);
    paramsBuilder.setAccountId(accountId);
    paramsBuilder.setOldProduct(oldProductId);
    paramsBuilder.setProrationMode(
        (long) PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY);

    // Assert that we sent an error back.
    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () -> methodChannelHandler.launchBillingFlow(paramsBuilder.build()));
    assertEquals("IN_APP_PURCHASE_INVALID_OLD_PRODUCT", exception.code);
    assertTrue(Objects.requireNonNull(exception.getMessage()).contains(oldProductId));
  }

  @Test
  public void queryPurchases_clientDisconnected() {
    methodChannelHandler.endConnection();

    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("type", BillingClient.ProductType.INAPP);
    methodChannelHandler.onMethodCall(new MethodCall(QUERY_PURCHASES_ASYNC, arguments), result);

    // Assert that we sent an error back.
    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
    verify(result, never()).success(any());
  }

  @Test
  public void queryPurchases_returns_success() throws Exception {
    establishConnectedBillingClient();

    CountDownLatch lock = new CountDownLatch(1);
    doAnswer(
            (Answer<Object>)
                invocation -> {
                  lock.countDown();
                  return null;
                })
        .when(result)
        .success(any(HashMap.class));

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

    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("productType", BillingClient.ProductType.INAPP);
    methodChannelHandler.onMethodCall(new MethodCall(QUERY_PURCHASES_ASYNC, arguments), result);

    lock.await(5000, TimeUnit.MILLISECONDS);

    verify(result, never()).error(any(), any(), any());

    @SuppressWarnings("unchecked")
    ArgumentCaptor<HashMap<String, Object>> hashMapCaptor = ArgumentCaptor.forClass(HashMap.class);
    verify(result, times(1)).success(hashMapCaptor.capture());

    HashMap<String, Object> map = hashMapCaptor.getValue();
    assert (map.containsKey("responseCode"));
    assert (map.containsKey("billingResult"));
    assert (map.containsKey("purchasesList"));
    assert ((int) map.get("responseCode") == 0);
  }

  @Test
  public void queryPurchaseHistoryAsync() {
    // Set up an established billing client and all our mocked responses
    establishConnectedBillingClient();
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    List<PurchaseHistoryRecord> purchasesList = singletonList(buildPurchaseHistoryRecord("foo"));
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("productType", BillingClient.ProductType.INAPP);
    ArgumentCaptor<PurchaseHistoryResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(PurchaseHistoryResponseListener.class);

    methodChannelHandler.onMethodCall(
        new MethodCall(QUERY_PURCHASE_HISTORY_ASYNC, arguments), result);

    // Verify we pass the data to result
    verify(mockBillingClient)
        .queryPurchaseHistoryAsync(any(QueryPurchaseHistoryParams.class), listenerCaptor.capture());
    listenerCaptor.getValue().onPurchaseHistoryResponse(billingResult, purchasesList);
    verify(result).success(resultCaptor.capture());
    HashMap<String, Object> resultData = resultCaptor.getValue();
    assertEquals(fromBillingResult(billingResult), resultData.get("billingResult"));
    assertEquals(
        fromPurchaseHistoryRecordList(purchasesList), resultData.get("purchaseHistoryRecordList"));
  }

  @Test
  public void queryPurchaseHistoryAsync_clientDisconnected() {
    methodChannelHandler.endConnection();

    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("type", BillingClient.ProductType.INAPP);
    methodChannelHandler.onMethodCall(
        new MethodCall(QUERY_PURCHASE_HISTORY_ASYNC, arguments), result);

    // Assert that we sent an error back.
    verify(result).error(contains("UNAVAILABLE"), contains("BillingClient"), any());
    verify(result, never()).success(any());
  }

  @Test
  public void onPurchasesUpdatedListener() {
    PluginPurchaseListener listener = new PluginPurchaseListener(mockMethodChannel);

    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    List<Purchase> purchasesList = singletonList(buildPurchase("foo"));
    doNothing()
        .when(mockMethodChannel)
        .invokeMethod(eq(ON_PURCHASES_UPDATED), resultCaptor.capture());
    listener.onPurchasesUpdated(billingResult, purchasesList);

    HashMap<String, Object> resultData = resultCaptor.getValue();
    assertEquals(fromBillingResult(billingResult), resultData.get("billingResult"));
    assertEquals(fromPurchasesList(purchasesList), resultData.get("purchasesList"));
  }

  @Test
  public void consumeAsync() {
    establishConnectedBillingClient();
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    final String token = "mockToken";
    ArgumentCaptor<ConsumeResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(ConsumeResponseListener.class);

    methodChannelHandler.consumeAsync(token, platformBillingResult);

    ConsumeParams params = ConsumeParams.newBuilder().setPurchaseToken(token).build();

    // Verify we pass the data to result
    verify(mockBillingClient).consumeAsync(refEq(params), listenerCaptor.capture());

    listenerCaptor.getValue().onConsumeResponse(billingResult, token);

    // Verify we pass the response code to result
    verify(platformBillingResult, never()).error(any());
    ArgumentCaptor<PlatformBillingResult> resultCaptor =
        ArgumentCaptor.forClass(PlatformBillingResult.class);
    verify(platformBillingResult, times(1)).success(resultCaptor.capture());
    assertResultsMatch(resultCaptor.getValue(), billingResult);
  }

  @Test
  public void acknowledgePurchase() {
    establishConnectedBillingClient();
    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    final String purchaseToken = "mockToken";
    ArgumentCaptor<AcknowledgePurchaseResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(AcknowledgePurchaseResponseListener.class);

    methodChannelHandler.acknowledgePurchase(purchaseToken, platformBillingResult);

    AcknowledgePurchaseParams params =
        AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchaseToken).build();

    // Verify we pass the data to result
    verify(mockBillingClient).acknowledgePurchase(refEq(params), listenerCaptor.capture());

    listenerCaptor.getValue().onAcknowledgePurchaseResponse(billingResult);

    // Verify we pass the response code to result
    verify(platformBillingResult, never()).error(any());
    ArgumentCaptor<PlatformBillingResult> resultCaptor =
        ArgumentCaptor.forClass(PlatformBillingResult.class);
    verify(platformBillingResult, times(1)).success(resultCaptor.capture());
    assertResultsMatch(resultCaptor.getValue(), billingResult);
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

    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(BillingClient.BillingResponseCode.OK)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.isFeatureSupported(feature)).thenReturn(billingResult);

    assertTrue(methodChannelHandler.isFeatureSupported(feature));
  }

  @Test
  public void isFutureSupported_false() {
    mockStartConnection();
    final String feature = "subscriptions";

    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED)
            .setDebugMessage("dummy debug message")
            .build();
    when(mockBillingClient.isFeatureSupported(feature)).thenReturn(billingResult);

    assertFalse(methodChannelHandler.isFeatureSupported(feature));
  }

  /**
   * Call {@link MethodCallHandlerImpl#startConnection(Long, PlatformBillingChoiceMode,
   * Messages.Result)} with startup params.
   *
   * <p>Defaults to play billing only which is the default.
   */
  private ArgumentCaptor<BillingClientStateListener> mockStartConnection() {
    return mockStartConnection(PlatformBillingChoiceMode.PLAY_BILLING_ONLY);
  }

  /**
   * Call {@link MethodCallHandlerImpl#startConnection(Long, PlatformBillingChoiceMode,
   * Messages.Result)} with startup params.
   */
  private ArgumentCaptor<BillingClientStateListener> mockStartConnection(
      PlatformBillingChoiceMode billingChoiceMode) {
    ArgumentCaptor<BillingClientStateListener> captor =
        ArgumentCaptor.forClass(BillingClientStateListener.class);
    doNothing().when(mockBillingClient).startConnection(captor.capture());

    methodChannelHandler.startConnection(1L, billingChoiceMode, platformBillingResult);
    return captor;
  }

  private void establishConnectedBillingClient() {
    @SuppressWarnings("unchecked")
    final Messages.Result<PlatformBillingResult> mockResult = mock(Messages.Result.class);
    methodChannelHandler.startConnection(
        1L, PlatformBillingChoiceMode.PLAY_BILLING_ONLY, mockResult);
  }

  private void queryForProducts(List<String> productIdList) {
    // Set up the query method call
    establishConnectedBillingClient();
    List<String> productsIds = asList("id1", "id2");
    final List<PlatformProduct> productList =
        buildProductList(productsIds, PlatformProductType.INAPP);

    // Call the method.
    methodChannelHandler.queryProductDetailsAsync(productList, platformProductDetailsResult);

    // Respond to the call with a matching set of product details.
    ArgumentCaptor<ProductDetailsResponseListener> listenerCaptor =
        ArgumentCaptor.forClass(ProductDetailsResponseListener.class);
    verify(mockBillingClient).queryProductDetailsAsync(any(), listenerCaptor.capture());
    List<ProductDetails> productDetailsResponse =
        productIdList.stream().map(this::buildProductDetails).collect(toList());

    BillingResult billingResult =
        BillingResult.newBuilder()
            .setResponseCode(100)
            .setDebugMessage("dummy debug message")
            .build();
    listenerCaptor.getValue().onProductDetailsResponse(billingResult, productDetailsResponse);
  }

  private List<PlatformProduct> buildProductList(
      List<String> productIds, PlatformProductType productType) {
    List<PlatformProduct> productList = new ArrayList<>();
    for (String productId : productIds) {
      PlatformProduct.Builder builder =
          new PlatformProduct.Builder().setProductId(productId).setProductType(productType);
      productList.add(builder.build());
    }
    return productList;
  }

  private ProductDetails buildProductDetails(String id) {
    String json =
        String.format(
            "{\"title\":\"Example title\",\"description\":\"Example description\",\"productId\":\"%s\",\"type\":\"inapp\",\"name\":\"Example name\",\"oneTimePurchaseOfferDetails\":{\"priceAmountMicros\":990000,\"priceCurrencyCode\":\"USD\",\"formattedPrice\":\"$0.99\"}}",
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
    return purchase;
  }

  private PurchaseHistoryRecord buildPurchaseHistoryRecord(String purchaseToken) {
    PurchaseHistoryRecord purchase = mock(PurchaseHistoryRecord.class);
    when(purchase.getPurchaseToken()).thenReturn(purchaseToken);
    return purchase;
  }

  private void assertResultsMatch(PlatformBillingResult pigeonResult, BillingResult nativeResult) {
    assertEquals(pigeonResult.getResponseCode().longValue(), nativeResult.getResponseCode());
    assertEquals(pigeonResult.getDebugMessage(), nativeResult.getDebugMessage());
  }
}
