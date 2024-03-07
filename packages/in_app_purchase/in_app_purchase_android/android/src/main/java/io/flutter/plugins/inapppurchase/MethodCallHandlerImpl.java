// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.Translator.fromBillingResult;
import static io.flutter.plugins.inapppurchase.Translator.fromProductDetailsList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchaseHistoryRecordList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesList;
import static io.flutter.plugins.inapppurchase.Translator.pigeonResultFromAlternativeBillingOnlyReportingDetails;
import static io.flutter.plugins.inapppurchase.Translator.pigeonResultFromBillingConfig;
import static io.flutter.plugins.inapppurchase.Translator.pigeonResultFromBillingResult;
import static io.flutter.plugins.inapppurchase.Translator.toProductList;
import static io.flutter.plugins.inapppurchase.Translator.toProductTypeString;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.GetBillingConfigParams;
import com.android.billingclient.api.ProductDetails;
import com.android.billingclient.api.QueryProductDetailsParams;
import com.android.billingclient.api.QueryPurchaseHistoryParams;
import com.android.billingclient.api.QueryPurchasesParams;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.inapppurchase.Messages.FlutterError;
import io.flutter.plugins.inapppurchase.Messages.InAppPurchaseApi;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingChoiceMode;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingFlowParams;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingResult;
import io.flutter.plugins.inapppurchase.Messages.PlatformProduct;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductDetailsResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchasesResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Handles method channel for the plugin. */
class MethodCallHandlerImpl
    implements MethodChannel.MethodCallHandler,
        Application.ActivityLifecycleCallbacks,
        InAppPurchaseApi {

  @VisibleForTesting
  static final class MethodNames {
    static final String ON_DISCONNECT = "BillingClientStateListener#onBillingServiceDisconnected()";
    static final String QUERY_PURCHASE_HISTORY_ASYNC =
        "BillingClient#queryPurchaseHistoryAsync(QueryPurchaseHistoryParams, PurchaseHistoryResponseListener)";

    private MethodNames() {}
  }

  // TODO(gmackall): Replace uses of deprecated ProrationMode enum values with new
  // ReplacementMode enum values.
  // https://github.com/flutter/flutter/issues/128957.
  @SuppressWarnings(value = "deprecation")
  @VisibleForTesting
  static final int PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY =
      com.android.billingclient.api.BillingFlowParams.ProrationMode
          .UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY;

  private static final String TAG = "InAppPurchasePlugin";
  private static final String LOAD_PRODUCT_DOC_URL =
      "https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase/README.md#loading-products-for-sale";
  @VisibleForTesting static final String ACTIVITY_UNAVAILABLE = "ACTIVITY_UNAVAILABLE";

  @Nullable private BillingClient billingClient;
  private final BillingClientFactory billingClientFactory;

  @Nullable private Activity activity;
  private final Context applicationContext;
  final MethodChannel methodChannel;

  private final HashMap<String, ProductDetails> cachedProducts = new HashMap<>();

  /** Constructs the MethodCallHandlerImpl */
  MethodCallHandlerImpl(
      @Nullable Activity activity,
      @NonNull Context applicationContext,
      @NonNull MethodChannel methodChannel,
      @NonNull BillingClientFactory billingClientFactory) {
    this.billingClientFactory = billingClientFactory;
    this.applicationContext = applicationContext;
    this.activity = activity;
    this.methodChannel = methodChannel;
  }

  /**
   * Sets the activity. Should be called as soon as the the activity is available. When the activity
   * becomes unavailable, call this method again with {@code null}.
   */
  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onActivityCreated(@NonNull Activity activity, Bundle savedInstanceState) {}

  @Override
  public void onActivityStarted(@NonNull Activity activity) {}

  @Override
  public void onActivityResumed(@NonNull Activity activity) {}

  @Override
  public void onActivityPaused(@NonNull Activity activity) {}

  @Override
  public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {}

  @Override
  public void onActivityDestroyed(@NonNull Activity activity) {
    if (this.activity == activity && this.applicationContext != null) {
      ((Application) this.applicationContext).unregisterActivityLifecycleCallbacks(this);
      endBillingClientConnection();
    }
  }

  @Override
  public void onActivityStopped(@NonNull Activity activity) {}

  void onDetachedFromActivity() {
    endBillingClientConnection();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case MethodNames.QUERY_PURCHASE_HISTORY_ASYNC:
        queryPurchaseHistoryAsync((String) call.argument("productType"), result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void showAlternativeBillingOnlyInformationDialog(
      @NonNull Messages.Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    if (activity == null) {
      result.error(new FlutterError(ACTIVITY_UNAVAILABLE, "Not attempting to show dialog", null));
      return;
    }
    billingClient.showAlternativeBillingOnlyInformationDialog(
        activity, billingResult -> result.success(pigeonResultFromBillingResult(billingResult)));
  }

  @Override
  public void createAlternativeBillingOnlyReportingDetailsAsync(
      @NonNull
          Messages.Result<Messages.PlatformAlternativeBillingOnlyReportingDetailsResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    billingClient.createAlternativeBillingOnlyReportingDetailsAsync(
        ((billingResult, alternativeBillingOnlyReportingDetails) ->
            result.success(
                pigeonResultFromAlternativeBillingOnlyReportingDetails(
                    billingResult, alternativeBillingOnlyReportingDetails))));
  }

  @Override
  public void isAlternativeBillingOnlyAvailableAsync(
      @NonNull Messages.Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    billingClient.isAlternativeBillingOnlyAvailableAsync(
        billingResult -> result.success(pigeonResultFromBillingResult(billingResult)));
  }

  @Override
  public void getBillingConfigAsync(
      @NonNull Messages.Result<Messages.PlatformBillingConfigResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    billingClient.getBillingConfigAsync(
        GetBillingConfigParams.newBuilder().build(),
        (billingResult, billingConfig) ->
            result.success(pigeonResultFromBillingConfig(billingResult, billingConfig)));
  }

  @Override
  public void endConnection() {
    endBillingClientConnection();
  }

  private void endBillingClientConnection() {
    if (billingClient != null) {
      billingClient.endConnection();
      billingClient = null;
    }
  }

  @Override
  @NonNull
  public Boolean isReady() {
    if (billingClient == null) {
      throw getNullBillingClientError();
    }
    return billingClient.isReady();
  }

  @Override
  public void queryProductDetailsAsync(
      @NonNull List<PlatformProduct> products,
      @NonNull Messages.Result<PlatformProductDetailsResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }

    QueryProductDetailsParams params =
        QueryProductDetailsParams.newBuilder().setProductList(toProductList(products)).build();
    billingClient.queryProductDetailsAsync(
        params,
        (billingResult, productDetailsList) -> {
          updateCachedProducts(productDetailsList);
          final PlatformProductDetailsResponse.Builder responseBuilder =
              new PlatformProductDetailsResponse.Builder()
                  .setBillingResult(pigeonResultFromBillingResult(billingResult))
                  .setProductDetailsJsonList(fromProductDetailsList(productDetailsList));
          result.success(responseBuilder.build());
        });
  }

  @Override
  public @NonNull PlatformBillingResult launchBillingFlow(
      @NonNull PlatformBillingFlowParams params) {
    if (billingClient == null) {
      throw getNullBillingClientError();
    }

    com.android.billingclient.api.ProductDetails productDetails =
        cachedProducts.get(params.getProduct());
    if (productDetails == null) {
      throw new FlutterError(
          "NOT_FOUND",
          "Details for product "
              + params.getProduct()
              + " are not available. It might because products were not fetched prior to the call. Please fetch the products first. An example of how to fetch the products could be found here: "
              + LOAD_PRODUCT_DOC_URL,
          null);
    }

    @Nullable
    List<ProductDetails.SubscriptionOfferDetails> subscriptionOfferDetails =
        productDetails.getSubscriptionOfferDetails();
    if (subscriptionOfferDetails != null) {
      boolean isValidOfferToken = false;
      for (ProductDetails.SubscriptionOfferDetails offerDetails : subscriptionOfferDetails) {
        if (params.getOfferToken() != null
            && params.getOfferToken().equals(offerDetails.getOfferToken())) {
          isValidOfferToken = true;
          break;
        }
      }
      if (!isValidOfferToken) {
        throw new FlutterError(
            "INVALID_OFFER_TOKEN",
            "Offer token "
                + params.getOfferToken()
                + " for product "
                + params.getProduct()
                + " is not valid. Make sure to only pass offer tokens that belong to the product. To obtain offer tokens for a product, fetch the products. An example of how to fetch the products could be found here: "
                + LOAD_PRODUCT_DOC_URL,
            null);
      }
    }

    if (params.getOldProduct() == null
        && params.getProrationMode()
            != PRORATION_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY) {
      throw new FlutterError(
          "IN_APP_PURCHASE_REQUIRE_OLD_PRODUCT",
          "launchBillingFlow failed because oldProduct is null. You must provide a valid oldProduct in order to use a proration mode.",
          null);
    } else if (params.getOldProduct() != null
        && !cachedProducts.containsKey(params.getOldProduct())) {
      throw new FlutterError(
          "IN_APP_PURCHASE_INVALID_OLD_PRODUCT",
          "Details for product "
              + params.getOldProduct()
              + " are not available. It might because products were not fetched prior to the call. Please fetch the products first. An example of how to fetch the products could be found here: "
              + LOAD_PRODUCT_DOC_URL,
          null);
    }

    if (activity == null) {
      throw new FlutterError(
          ACTIVITY_UNAVAILABLE,
          "Details for product "
              + params.getProduct()
              + " are not available. This method must be run with the app in foreground.",
          null);
    }

    BillingFlowParams.ProductDetailsParams.Builder productDetailsParamsBuilder =
        BillingFlowParams.ProductDetailsParams.newBuilder();
    productDetailsParamsBuilder.setProductDetails(productDetails);
    if (params.getOfferToken() != null) {
      productDetailsParamsBuilder.setOfferToken(params.getOfferToken());
    }

    List<BillingFlowParams.ProductDetailsParams> productDetailsParamsList = new ArrayList<>();
    productDetailsParamsList.add(productDetailsParamsBuilder.build());

    BillingFlowParams.Builder paramsBuilder =
        BillingFlowParams.newBuilder().setProductDetailsParamsList(productDetailsParamsList);
    if (params.getAccountId() != null && !params.getAccountId().isEmpty()) {
      paramsBuilder.setObfuscatedAccountId(params.getAccountId());
    }
    if (params.getObfuscatedProfileId() != null && !params.getObfuscatedProfileId().isEmpty()) {
      paramsBuilder.setObfuscatedProfileId(params.getObfuscatedProfileId());
    }
    BillingFlowParams.SubscriptionUpdateParams.Builder subscriptionUpdateParamsBuilder =
        BillingFlowParams.SubscriptionUpdateParams.newBuilder();
    if (params.getOldProduct() != null
        && !params.getOldProduct().isEmpty()
        && params.getPurchaseToken() != null) {
      subscriptionUpdateParamsBuilder.setOldPurchaseToken(params.getPurchaseToken());
      // Set the prorationMode using a helper to minimize impact of deprecation warning suppression.
      setReplaceProrationMode(
          subscriptionUpdateParamsBuilder, params.getProrationMode().intValue());
      paramsBuilder.setSubscriptionUpdateParams(subscriptionUpdateParamsBuilder.build());
    }
    return pigeonResultFromBillingResult(
        billingClient.launchBillingFlow(activity, paramsBuilder.build()));
  }

  // TODO(gmackall): Replace uses of deprecated setReplaceProrationMode.
  // https://github.com/flutter/flutter/issues/128957.
  @SuppressWarnings(value = "deprecation")
  private void setReplaceProrationMode(
      BillingFlowParams.SubscriptionUpdateParams.Builder builder, int prorationMode) {
    // The proration mode value has to match one of the following declared in
    // https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode
    builder.setReplaceProrationMode(prorationMode);
  }

  @Override
  public void consumeAsync(
      @NonNull String purchaseToken, @NonNull Messages.Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }

    ConsumeResponseListener listener =
        (billingResult, outToken) -> result.success(pigeonResultFromBillingResult(billingResult));
    ConsumeParams.Builder paramsBuilder =
        ConsumeParams.newBuilder().setPurchaseToken(purchaseToken);
    ConsumeParams params = paramsBuilder.build();

    billingClient.consumeAsync(params, listener);
  }

  @Override
  public void queryPurchasesAsync(
      @NonNull Messages.PlatformProductType productType,
      @NonNull Messages.Result<Messages.PlatformPurchasesResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }

    // Like in our connect call, consider the billing client responding a "success" here regardless
    // of status code.
    QueryPurchasesParams.Builder paramsBuilder = QueryPurchasesParams.newBuilder();
    paramsBuilder.setProductType(toProductTypeString(productType));
    billingClient.queryPurchasesAsync(
        paramsBuilder.build(),
        (billingResult, purchasesList) -> {
          PlatformPurchasesResponse.Builder builder =
              new PlatformPurchasesResponse.Builder()
                  .setBillingResult(pigeonResultFromBillingResult(billingResult))
                  .setPurchasesJsonList(fromPurchasesList(purchasesList));
          result.success(builder.build());
        });
  }

  private void queryPurchaseHistoryAsync(String productType, final MethodChannel.Result result) {
    if (billingClientError(result)) {
      return;
    }
    assert billingClient != null;

    billingClient.queryPurchaseHistoryAsync(
        QueryPurchaseHistoryParams.newBuilder().setProductType(productType).build(),
        (billingResult, purchasesList) -> {
          final Map<String, Object> serialized = new HashMap<>();
          serialized.put("billingResult", fromBillingResult(billingResult));
          serialized.put("purchaseHistoryRecordList", fromPurchaseHistoryRecordList(purchasesList));
          result.success(serialized);
        });
  }

  @Override
  public void startConnection(
      @NonNull Long handle,
      @NonNull PlatformBillingChoiceMode billingMode,
      @NonNull Messages.Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      billingClient =
          billingClientFactory.createBillingClient(applicationContext, methodChannel, billingMode);
    }

    billingClient.startConnection(
        new BillingClientStateListener() {
          private boolean alreadyFinished = false;

          @Override
          public void onBillingSetupFinished(@NonNull BillingResult billingResult) {
            if (alreadyFinished) {
              Log.d(TAG, "Tried to call onBillingSetupFinished multiple times.");
              return;
            }
            alreadyFinished = true;
            // Consider the fact that we've finished a success, leave it to the Dart side to
            // validate the responseCode.
            result.success(pigeonResultFromBillingResult(billingResult));
          }

          @Override
          public void onBillingServiceDisconnected() {
            final Map<String, Object> arguments = new HashMap<>();
            arguments.put("handle", handle);
            methodChannel.invokeMethod(MethodNames.ON_DISCONNECT, arguments);
          }
        });
  }

  @Override
  public void acknowledgePurchase(
      @NonNull String purchaseToken, @NonNull Messages.Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    AcknowledgePurchaseParams params =
        AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchaseToken).build();
    billingClient.acknowledgePurchase(
        params, billingResult -> result.success(pigeonResultFromBillingResult(billingResult)));
  }

  protected void updateCachedProducts(@Nullable List<ProductDetails> productDetailsList) {
    if (productDetailsList == null) {
      return;
    }

    for (ProductDetails productDetails : productDetailsList) {
      cachedProducts.put(productDetails.getProductId(), productDetails);
    }
  }

  private boolean billingClientError(MethodChannel.Result result) {
    if (billingClient != null) {
      return false;
    }

    result.error("UNAVAILABLE", "BillingClient is unset. Try reconnecting.", null);
    return true;
  }

  private @NonNull FlutterError getNullBillingClientError() {
    return new FlutterError("UNAVAILABLE", "BillingClient is unset. Try reconnecting.", null);
  }

  @Override
  public @NonNull Boolean isFeatureSupported(@NonNull String feature) {
    if (billingClient == null) {
      throw getNullBillingClientError();
    }
    BillingResult billingResult = billingClient.isFeatureSupported(feature);
    return billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK;
  }
}
