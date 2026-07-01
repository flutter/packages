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

  /**
   * This method should only be called if {@link WebViewFeatureProxyApi#isFeatureSupported(String)}
   * with WEB_AUTHENTICATION returns true.
   *
   * <p>The {@code support} parameter is a {@code long} to accommodate Dart's integer type, but is
   * safely converted to {@code int} for the underlying Android API call. {@link
   * Math#toIntExact(long)} is used to verify the value fits in the {@code int} range and throw
   * {@link ArithmeticException} if it overflows. This is safe because the valid support levels are
   * constants (0, 1, 2) that well within the integer range.
   *
   * <p>Note: {@link Math#toIntExact(long)} requires API level 24 or higher. This is compatible with
   * this plugin's minimum SDK version.
   *
   * @param webSettings the WebSettings instance
   * @param support the WebAuthentication support level (0, 1, or 2)
   * @throws ArithmeticException if {@code support} exceeds {@link Integer#MAX_VALUE}
   */
  @SuppressLint("RequiresFeature")
  @Override
  public void setWebAuthenticationSupport(@NonNull WebSettings webSettings, long support) {
    final int supportValue = Math.toIntExact(support);
    WebSettingsCompat.setWebAuthenticationSupport(webSettings, supportValue);
  }
}
