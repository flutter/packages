// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.Translator.fromBillingResult;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import io.flutter.Log;
import java.util.List;

class PluginPurchaseListener implements PurchasesUpdatedListener {
  private final Messages.InAppPurchaseCallbackApi callbackApi;

  PluginPurchaseListener(Messages.InAppPurchaseCallbackApi callbackApi) {
    this.callbackApi = callbackApi;
  }

  @Override
  public void onPurchasesUpdated(
      @NonNull BillingResult billingResult, @Nullable List<Purchase> purchases) {
    Messages.PlatformPurchasesResponse.Builder builder =
        new Messages.PlatformPurchasesResponse.Builder()
            .setBillingResult(fromBillingResult(billingResult))
            .setPurchases(fromPurchasesList(purchases));
    callbackApi.onPurchasesUpdated(
        builder.build(),
        new Messages.VoidResult() {
          @Override
          public void success() {}

          @Override
          public void error(@NonNull Throwable error) {
            Log.e("IN_APP_PURCHASE", "onPurchaseUpdated handler error: " + error);
          }
        });
  }
}
