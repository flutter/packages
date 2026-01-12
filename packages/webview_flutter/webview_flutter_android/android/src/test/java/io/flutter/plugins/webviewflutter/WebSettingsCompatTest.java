// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.fail;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;

import android.webkit.WebSettings;
import androidx.webkit.WebSettingsCompat;
import androidx.webkit.WebViewFeature;
import org.junit.Test;
import org.mockito.MockedStatic;

public class WebSettingsCompatTest {
  @Test
  public void setPaymentRequestEnabled() {
    final PigeonApiWebSettingsCompat api =
        new TestProxyApiRegistrar().getPigeonApiWebSettingsCompat();

    final WebSettings webSettings = mock(WebSettings.class);

    try (MockedStatic<WebSettingsCompat> mockedStatic = mockStatic(WebSettingsCompat.class)) {
      try (MockedStatic<WebViewFeature> mockedWebViewFeature = mockStatic(WebViewFeature.class)) {
        mockedWebViewFeature
            .when(() -> WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST))
            .thenReturn(true);
        api.setPaymentRequestEnabled(webSettings, true);
        mockedStatic.verify(() -> WebSettingsCompat.setPaymentRequestEnabled(webSettings, true));
      } catch (Exception e) {
        fail(e.toString());
      }
    } catch (Exception e) {
      fail(e.toString());
    }
  }
}
