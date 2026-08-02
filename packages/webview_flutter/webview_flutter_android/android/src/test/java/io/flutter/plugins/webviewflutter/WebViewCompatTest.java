// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;

import android.webkit.WebView;
import androidx.webkit.WebViewCompat;
import java.util.Collections;
import java.util.HashSet;
import org.junit.Test;
import org.mockito.MockedStatic;

public class WebViewCompatTest {
  @Test
  public void addDocumentStartJavaScript() {
    final PigeonApiWebViewCompat api = new TestProxyApiRegistrar().getPigeonApiWebViewCompat();

    final WebView webView = mock(WebView.class);

    try (MockedStatic<WebViewCompat> mockedStatic = mockStatic(WebViewCompat.class)) {
      api.addDocumentStartJavaScript(
          webView, "window.injected = true;", Collections.singletonList("https://example.com"));

      mockedStatic.verify(
          () ->
              WebViewCompat.addDocumentStartJavaScript(
                  webView,
                  "window.injected = true;",
                  new HashSet<>(Collections.singletonList("https://example.com"))));
    }
  }
}
