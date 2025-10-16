// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.SuppressLint;
import android.webkit.WebSettings;
import androidx.annotation.NonNull;
import androidx.webkit.WebSettingsCompat;

/**
 * Proxy API implementation for {@link WebSettingsCompat}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class WebSettingsCompatProxyApi extends PigeonApiWebSettingsCompat {
  public WebSettingsCompatProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  /**
   * This method should only be called if {@link WebViewFeatureProxyApi#isFeatureSupported(String)}
   * with PAYMENT_REQUEST returns true.
   */
  @SuppressLint("RequiresFeature")
  @Override
  public void setPaymentRequestEnabled(@NonNull WebSettings webSettings, boolean enabled) {
    WebSettingsCompat.setPaymentRequestEnabled(webSettings, enabled);
  }
}
