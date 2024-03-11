// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import android.content.Context;
import androidx.annotation.NonNull;
import com.android.billingclient.api.BillingClient;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingChoiceMode;

/** The implementation for {@link BillingClientFactory} for the plugin. */
final class BillingClientFactoryImpl implements BillingClientFactory {

  @Override
  public BillingClient createBillingClient(
      @NonNull Context context,
      @NonNull Messages.InAppPurchaseCallbackApi callbackApi,
      PlatformBillingChoiceMode billingChoiceMode) {
    BillingClient.Builder builder = BillingClient.newBuilder(context).enablePendingPurchases();
    if (billingChoiceMode == PlatformBillingChoiceMode.ALTERNATIVE_BILLING_ONLY) {
      // https://developer.android.com/google/play/billing/alternative/alternative-billing-without-user-choice-in-app
      builder.enableAlternativeBillingOnly();
    }
    return builder.setListener(new PluginPurchaseListener(callbackApi)).build();
  }
}
