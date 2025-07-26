// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebSettings;
import androidx.annotation.NonNull;
import androidx.webkit.WebSettingsCompat;
import androidx.webkit.WebViewFeature;

/**
 * Host api implementation for {@link WebSettingsCompat}.
 *
 * <p>Handles static methods for {@link WebSettingsCompat}.
 */
public class WebSettingsCompatProxyApi extends PigeonApiWebSettingsCompat {
  public WebSettingsCompatProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void setPaymentRequestEnabled(@NonNull WebSettings webSettings, boolean enabled) {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)) {
      WebSettingsCompat.setPaymentRequestEnabled(webSettings, enabled);
    }
  }
}
