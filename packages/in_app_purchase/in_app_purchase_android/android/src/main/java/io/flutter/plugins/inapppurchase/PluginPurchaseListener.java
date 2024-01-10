// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.Translator.fromBillingResult;
import static io.flutter.plugins.inapppurchase.Translator.fromPurchasesList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class PluginPurchaseListener implements PurchasesUpdatedListener {
  private final MethodChannel channel;

  @VisibleForTesting
  static final String ON_PURCHASES_UPDATED =
      "PurchasesUpdatedListener#onPurchasesUpdated(BillingResult, List<Purchase>)";

  PluginPurchaseListener(MethodChannel channel) {
    this.channel = channel;
  }

  @Override
  public void onPurchasesUpdated(
      @NonNull BillingResult billingResult, @Nullable List<Purchase> purchases) {
    final Map<String, Object> callbackArgs = new HashMap<>();
    callbackArgs.put("billingResult", fromBillingResult(billingResult));
    callbackArgs.put("responseCode", billingResult.getResponseCode());
    callbackArgs.put("purchasesList", fromPurchasesList(purchases));
    channel.invokeMethod(ON_PURCHASES_UPDATED, callbackArgs);
  }
}
