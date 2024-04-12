// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.inapppurchase;

import android.content.Context;
import androidx.annotation.NonNull;
import com.android.billingclient.api.BillingClient;
import io.flutter.plugins.inapppurchase.Messages.PlatformBillingChoiceMode;

/** Responsible for creating a {@link BillingClient} object. */
interface BillingClientFactory {

  /**
   * Creates and returns a {@link BillingClient}.
   *
   * @param context The context used to create the {@link BillingClient}.
   * @param callbackApi The callback API to be used by the {@link BillingClient}.
   * @param billingChoiceMode Enables the ability to offer alternative billing or Google Play
   *     billing.
   * @return The {@link BillingClient} object that is created.
   */
  BillingClient createBillingClient(
      @NonNull Context context,
      @NonNull Messages.InAppPurchaseCallbackApi callbackApi,
      PlatformBillingChoiceMode billingChoiceMode);
}
