// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.UserChoiceBillingListener;
import io.flutter.Log;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingChoiceMode;

/** The implementation for {@link BillingClientFactory} for the plugin. */
final class BillingClientFactoryImpl implements BillingClientFactory {

  @Override
  public BillingClient createBillingClient(
      @NonNull Context context,
      @NonNull Messages.InAppPurchaseCallbackApi callbackApi,
      PlatformBillingChoiceMode billingChoiceMode,
      @Nullable UserChoiceBillingListener userChoiceBillingListener) {
    BillingClient.Builder builder = BillingClient.newBuilder(context).enablePendingPurchases();
    switch (billingChoiceMode) {
      case ALTERNATIVE_BILLING_ONLY:
        // https://developer.android.com/google/play/billing/alternative/alternative-billing-without-user-choice-in-app
        builder.enableAlternativeBillingOnly();
        break;
      case USER_CHOICE_BILLING:
        if (userChoiceBillingListener != null) {
          // https://developer.android.com/google/play/billing/alternative/alternative-billing-with-user-choice-in-app
          builder.enableUserChoiceBilling(userChoiceBillingListener);
        } else {
          Log.e(
              "BillingClientFactoryImpl",
              "userChoiceBillingListener null when USER_CHOICE_BILLING set. Defaulting to PLAY_BILLING_ONLY");
        }
        break;
      case PLAY_BILLING_ONLY:
        // Do nothing.
        break;
      default:
        Log.e(
            "BillingClientFactoryImpl",
            "Unknown BillingChoiceMode " + billingChoiceMode + ", Defaulting to PLAY_BILLING_ONLY");
        break;
    }
    return builder.setListener(new PluginPurchaseListener(callbackApi)).build();
  }
}
