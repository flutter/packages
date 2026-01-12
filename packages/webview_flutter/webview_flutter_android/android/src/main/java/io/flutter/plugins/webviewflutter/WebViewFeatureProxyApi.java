// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import androidx.annotation.NonNull;
import androidx.webkit.WebViewFeature;

/**
 * Proxy API implementation for {@link WebViewFeature}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class WebViewFeatureProxyApi extends PigeonApiWebViewFeature {
  public WebViewFeatureProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public boolean isFeatureSupported(@NonNull String feature) {
    return WebViewFeature.isFeatureSupported(feature);
  }
}
