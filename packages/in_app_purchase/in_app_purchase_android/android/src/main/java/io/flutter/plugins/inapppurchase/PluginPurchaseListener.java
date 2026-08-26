// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.TranslatorKt.fromBillingResult;
import static io.flutter.plugins.inapppurchase.TranslatorKt.fromPurchasesList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import io.flutter.Log;
import java.util.List;
import kotlin.Unit;

class PluginPurchaseListener implements PurchasesUpdatedListener {
  private final InAppPurchaseCallbackApi callbackApi;

  PluginPurchaseListener(InAppPurchaseCallbackApi callbackApi) {
    this.callbackApi = callbackApi;
  }

  @Override
  public void onPurchasesUpdated(
      @NonNull BillingResult billingResult, @Nullable List<Purchase> purchases) {
    PlatformPurchasesResponse response =
        new PlatformPurchasesResponse(
            fromBillingResult(billingResult), fromPurchasesList(purchases));
    callbackApi.onPurchasesUpdated(
        response,
        ResultCompat.asCompatCallback(
            result -> {
              Throwable error = result.exceptionOrNull();
              if (error != null) {
                Log.e("IN_APP_PURCHASE", "onPurchaseUpdated handler error: " + error);
              }
              return Unit.INSTANCE;
            }));
  }
}
