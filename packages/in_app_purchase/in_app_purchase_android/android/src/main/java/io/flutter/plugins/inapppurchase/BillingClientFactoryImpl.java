// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import static io.flutter.plugins.inapppurchase.TranslatorKt.fromUserChoiceDetails;
import static io.flutter.plugins.inapppurchase.TranslatorKt.toPendingPurchasesParams;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.UserChoiceBillingListener;
import io.flutter.Log;
import kotlin.Unit;

/** The implementation for {@link BillingClientFactory} for the plugin. */
final class BillingClientFactoryImpl implements BillingClientFactory {

  @Override
  public BillingClient createBillingClient(
      @NonNull Context context,
      @NonNull InAppPurchaseCallbackApi callbackApi,
      PlatformBillingChoiceMode billingChoiceMode,
      PlatformPendingPurchasesParams pendingPurchasesParams) {
    BillingClient.Builder builder =
        BillingClient.newBuilder(context)
            .enablePendingPurchases(toPendingPurchasesParams(pendingPurchasesParams));
    switch (billingChoiceMode) {
      case ALTERNATIVE_BILLING_ONLY:
        // https://developer.android.com/google/play/billing/alternative/alternative-billing-without-user-choice-in-app
        builder.enableAlternativeBillingOnly();
        break;
      case USER_CHOICE_BILLING:
        builder.enableUserChoiceBilling(createUserChoiceBillingListener(callbackApi));
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

  @VisibleForTesting
  /* package */ UserChoiceBillingListener createUserChoiceBillingListener(
      @NonNull InAppPurchaseCallbackApi callbackApi) {
    return userChoiceDetails ->
        callbackApi.userSelectedalternativeBilling(
            fromUserChoiceDetails(userChoiceDetails),
            ResultCompat.asCompatCallback(
                result -> {
                  Throwable error = result.exceptionOrNull();
                  if (error != null) {
                    io.flutter.Log.e(
                        "IN_APP_PURCHASE",
                        "userSelectedalternativeBilling handler error: " + error);
                  }
                  return Unit.INSTANCE;
                }));
  }
}
