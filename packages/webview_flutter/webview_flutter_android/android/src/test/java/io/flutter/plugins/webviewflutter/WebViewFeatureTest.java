// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.mockStatic;

import androidx.webkit.WebViewFeature;
import org.junit.Test;
import org.mockito.MockedStatic;

public class WebViewFeatureTest {
  @Test
  public void isFeatureSupported() {
    final PigeonApiWebViewFeature api = new TestProxyApiRegistrar().getPigeonApiWebViewFeature();

    try (MockedStatic<WebViewFeature> mockedStatic = mockStatic(WebViewFeature.class)) {
      mockedStatic
          .when(() -> WebViewFeature.isFeatureSupported("PAYMENT_REQUEST"))
          .thenReturn(true);

      boolean result = api.isFeatureSupported("PAYMENT_REQUEST");

      assertTrue(result);

      mockedStatic.verify(() -> WebViewFeature.isFeatureSupported("PAYMENT_REQUEST"));
    } catch (Exception e) {
      fail(e.toString());
    }
  }

  @Test
  public void isFeatureSupportedReturnsFalse() {
    final PigeonApiWebViewFeature api = new TestProxyApiRegistrar().getPigeonApiWebViewFeature();

    try (MockedStatic<WebViewFeature> mockedStatic = mockStatic(WebViewFeature.class)) {
      mockedStatic
          .when(() -> WebViewFeature.isFeatureSupported("UNSUPPORTED_FEATURE"))
          .thenReturn(false);

      boolean result = api.isFeatureSupported("UNSUPPORTED_FEATURE");

      assertFalse(result);

      mockedStatic.verify(() -> WebViewFeature.isFeatureSupported("UNSUPPORTED_FEATURE"));
    } catch (Exception e) {
      fail(e.toString());
    }
  }
}
