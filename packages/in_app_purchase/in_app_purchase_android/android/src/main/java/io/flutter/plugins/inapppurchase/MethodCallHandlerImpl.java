// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.Translator.fromAlternativeBillingOnlyReportingDetails;
import static io.flutter.plugins.inapppurchase.Translator.fromBillingConfig;
import static io.flutter.plugins.inapppurchase.Translator.fromBillingResult;
import static io.flutter.plugins.inapppurchase.Translator.fromProductDetailsList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchaseHistoryRecordList;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesList;
import static io.flutter.plugins.inapppurchase.Translator.toBillingClientFeature;
import static io.flutter.plugins.inapppurchase.Translator.toProductList;
import static io.flutter.plugins.inapppurchase.Translator.toProductTypeString;
import static io.flutter.plugins.inapppurchase.Translator.toReplacementMode;

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
import io.flutter.plugins.inapppurchase.Messages.FlutterError;
import io.flutter.plugins.inapppurchase.Messages.InAppPurchaseApi;
import io.flutter.plugins.inapppurchase.Messages.InAppPurchaseCallbackApi;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingChoiceMode;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingClientFeature;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingFlowParams;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingResult;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductDetailsResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformProductType;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchaseHistoryResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformPurchasesResponse;
import io.flutter.plugins.inapppurchase.Messages.PlatformQueryProduct;
import io.flutter.plugins.inapppurchase.Messages.PlatformReplacementMode;
import io.flutter.plugins.inapppurchase.Messages.Result;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/** Handles method channel for the plugin. */
class MethodCallHandlerImpl implements Application.ActivityLifecycleCallbacks, InAppPurchaseApi {
  @VisibleForTesting
  static final PlatformReplacementMode
      REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY =
          PlatformReplacementMode.UNKNOWN_REPLACEMENT_MODE;

  private static final String TAG = "InAppPurchasePlugin";
  private static final String LOAD_PRODUCT_DOC_URL =
      "https://github.com/flutter/packages/blob/main/packages/in_app_purchase/in_app_purchase/README.md#loading-products-for-sale";
  @VisibleForTesting static final String ACTIVITY_UNAVAILABLE = "ACTIVITY_UNAVAILABLE";

  @Nullable private BillingClient billingClient;
  private final BillingClientFactory billingClientFactory;

  @Nullable private Activity activity;
  private final Context applicationContext;
  final InAppPurchaseCallbackApi callbackApi;

  private final HashMap<String, ProductDetails> cachedProducts = new HashMap<>();

  /** Constructs the MethodCallHandlerImpl */
  MethodCallHandlerImpl(
      @Nullable Activity activity,
      @NonNull Context applicationContext,
      @NonNull InAppPurchaseCallbackApi callbackApi,
      @NonNull BillingClientFactory billingClientFactory) {
    this.billingClientFactory = billingClientFactory;
    this.applicationContext = applicationContext;
    this.activity = activity;
    this.callbackApi = callbackApi;
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
  public void showAlternativeBillingOnlyInformationDialog(
      @NonNull Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    if (activity == null) {
      result.error(new FlutterError(ACTIVITY_UNAVAILABLE, "Not attempting to show dialog", null));
      return;
    }
    try {
      billingClient.showAlternativeBillingOnlyInformationDialog(
          activity, billingResult -> result.success(fromBillingResult(billingResult)));
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  @Override
  public void createAlternativeBillingOnlyReportingDetailsAsync(
      @NonNull Result<Messages.PlatformAlternativeBillingOnlyReportingDetailsResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    try {
      billingClient.createAlternativeBillingOnlyReportingDetailsAsync(
          ((billingResult, alternativeBillingOnlyReportingDetails) ->
              result.success(
                  fromAlternativeBillingOnlyReportingDetails(
                      billingResult, alternativeBillingOnlyReportingDetails))));
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  @Override
  public void isAlternativeBillingOnlyAvailableAsync(
      @NonNull Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    try {
      billingClient.isAlternativeBillingOnlyAvailableAsync(
          billingResult -> result.success(fromBillingResult(billingResult)));
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  @Override
  public void getBillingConfigAsync(
      @NonNull Result<Messages.PlatformBillingConfigResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    try {
      billingClient.getBillingConfigAsync(
          GetBillingConfigParams.newBuilder().build(),
          (billingResult, billingConfig) ->
              result.success(fromBillingConfig(billingResult, billingConfig)));
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
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
      @NonNull List<PlatformQueryProduct> products,
      @NonNull Result<PlatformProductDetailsResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }

    try {
      QueryProductDetailsParams params =
          QueryProductDetailsParams.newBuilder().setProductList(toProductList(products)).build();
      billingClient.queryProductDetailsAsync(
          params,
          (billingResult, productDetailsList) -> {
            updateCachedProducts(productDetailsList);
            final PlatformProductDetailsResponse.Builder responseBuilder =
                new PlatformProductDetailsResponse.Builder()
                    .setBillingResult(fromBillingResult(billingResult))
                    .setProductDetails(fromProductDetailsList(productDetailsList));
            result.success(responseBuilder.build());
          });
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
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
        && (params.getReplacementMode()
            != REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY)) {
      throw new FlutterError(
          "IN_APP_PURCHASE_REQUIRE_OLD_PRODUCT",
          "launchBillingFlow failed because oldProduct is null. You must provide a valid oldProduct in order to use a replacement mode.",
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
      if (params.getReplacementMode()
          != REPLACEMENT_MODE_UNKNOWN_SUBSCRIPTION_UPGRADE_DOWNGRADE_POLICY) {
        subscriptionUpdateParamsBuilder.setSubscriptionReplacementMode(
            toReplacementMode(params.getReplacementMode()));
      }
      paramsBuilder.setSubscriptionUpdateParams(subscriptionUpdateParamsBuilder.build());
    }
    return fromBillingResult(billingClient.launchBillingFlow(activity, paramsBuilder.build()));
  }

  @Override
  public void consumeAsync(
      @NonNull String purchaseToken, @NonNull Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }

    try {
      ConsumeResponseListener listener =
          (billingResult, outToken) -> result.success(fromBillingResult(billingResult));
      ConsumeParams.Builder paramsBuilder =
          ConsumeParams.newBuilder().setPurchaseToken(purchaseToken);
      ConsumeParams params = paramsBuilder.build();

      billingClient.consumeAsync(params, listener);
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  @Override
  public void queryPurchasesAsync(
      @NonNull PlatformProductType productType,
      @NonNull Result<Messages.PlatformPurchasesResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }

    try {
      // Like in our connect call, consider the billing client responding a "success" here
      // regardless
      // of status code.
      QueryPurchasesParams.Builder paramsBuilder = QueryPurchasesParams.newBuilder();
      paramsBuilder.setProductType(toProductTypeString(productType));
      billingClient.queryPurchasesAsync(
          paramsBuilder.build(),
          (billingResult, purchasesList) -> {
            PlatformPurchasesResponse.Builder builder =
                new PlatformPurchasesResponse.Builder()
                    .setBillingResult(fromBillingResult(billingResult))
                    .setPurchases(fromPurchasesList(purchasesList));
            result.success(builder.build());
          });
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  @Override
  @Deprecated
  public void queryPurchaseHistoryAsync(
      @NonNull PlatformProductType productType,
      @NonNull Result<Messages.PlatformPurchaseHistoryResponse> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }

    try {
      billingClient.queryPurchaseHistoryAsync(
          QueryPurchaseHistoryParams.newBuilder()
              .setProductType(toProductTypeString(productType))
              .build(),
          (billingResult, purchasesList) -> {
            PlatformPurchaseHistoryResponse.Builder builder =
                new PlatformPurchaseHistoryResponse.Builder()
                    .setBillingResult(fromBillingResult(billingResult))
                    .setPurchases(fromPurchaseHistoryRecordList(purchasesList));
            result.success(builder.build());
          });
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  @Override
  public void startConnection(
      @NonNull Long handle,
      @NonNull PlatformBillingChoiceMode billingMode,
      @NonNull Messages.PlatformPendingPurchasesParams pendingPurchasesParams,
      @NonNull Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      billingClient =
          billingClientFactory.createBillingClient(
              applicationContext, callbackApi, billingMode, pendingPurchasesParams);
    }

    try {
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
              result.success(fromBillingResult(billingResult));
            }

            @Override
            public void onBillingServiceDisconnected() {
              callbackApi.onBillingServiceDisconnected(
                  handle,
                  new Messages.VoidResult() {
                    @Override
                    public void success() {}

                    @Override
                    public void error(@NonNull Throwable error) {
                      io.flutter.Log.e(
                          "IN_APP_PURCHASE",
                          "onBillingServiceDisconnected handler error: " + error);
                    }
                  });
            }
          });
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  @Override
  public void acknowledgePurchase(
      @NonNull String purchaseToken, @NonNull Result<PlatformBillingResult> result) {
    if (billingClient == null) {
      result.error(getNullBillingClientError());
      return;
    }
    try {
      AcknowledgePurchaseParams params =
          AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchaseToken).build();
      billingClient.acknowledgePurchase(
          params, billingResult -> result.success(fromBillingResult(billingResult)));
    } catch (RuntimeException e) {
      result.error(new FlutterError("error", e.getMessage(), Log.getStackTraceString(e)));
    }
  }

  protected void updateCachedProducts(@Nullable List<ProductDetails> productDetailsList) {
    if (productDetailsList == null) {
      return;
    }

    for (ProductDetails productDetails : productDetailsList) {
      cachedProducts.put(productDetails.getProductId(), productDetails);
    }
  }

  private @NonNull FlutterError getNullBillingClientError() {
    return new FlutterError("UNAVAILABLE", "BillingClient is unset. Try reconnecting.", null);
  }

  @Override
  public @NonNull Boolean isFeatureSupported(@NonNull PlatformBillingClientFeature feature) {
    if (billingClient == null) {
      throw getNullBillingClientError();
    }
    BillingResult billingResult = billingClient.isFeatureSupported(toBillingClientFeature(feature));
    return billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK;
  }
}
