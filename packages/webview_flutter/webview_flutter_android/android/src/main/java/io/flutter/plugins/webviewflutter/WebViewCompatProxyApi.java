// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.SuppressLint;
import android.webkit.WebView;
import androidx.annotation.NonNull;
import androidx.webkit.WebViewCompat;
import java.util.HashSet;
import java.util.List;

/**
 * Proxy API implementation for {@link WebViewCompat}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class WebViewCompatProxyApi extends PigeonApiWebViewCompat {
  public WebViewCompatProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  /**
   * This method should only be called if {@link WebViewFeatureProxyApi#isFeatureSupported(String)}
   * with DOCUMENT_START_SCRIPT returns true.
   */
  @SuppressLint("RequiresFeature")
  @Override
  public void addDocumentStartJavaScript(
      @NonNull WebView webView, @NonNull String script, @NonNull List<String> allowedOriginRules) {
    WebViewCompat.addDocumentStartJavaScript(webView, script, new HashSet<>(allowedOriginRules));
  }
}
