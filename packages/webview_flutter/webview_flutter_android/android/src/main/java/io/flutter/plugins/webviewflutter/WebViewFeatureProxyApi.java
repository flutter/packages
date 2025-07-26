// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import androidx.annotation.NonNull;
import androidx.webkit.WebViewFeature;

/**
 * Host api implementation for {@link WebViewFeature}.
 *
 * <p>Handles creating {@link WebViewFeature}s that intercommunicate with a paired Dart object.
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
