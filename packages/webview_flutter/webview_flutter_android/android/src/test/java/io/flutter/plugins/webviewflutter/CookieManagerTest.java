// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class CookieManagerTest {
  @Test
  public void setCookie() {
    final PigeonApiCookieManager api = new TestProxyApiRegistrar().getPigeonApiCookieManager();

    final CookieManager instance = mock(CookieManager.class);
    final String url = "myString";
    final String value = "myString2";
    api.setCookie(instance, url, value);

    verify(instance).setCookie(url, value);
  }

  @Test
  public void removeAllCookies() {
    final PigeonApiCookieManager api = new TestProxyApiRegistrar().getPigeonApiCookieManager();

    final CookieManager instance = mock(CookieManager.class);

    final Boolean[] successResult = new Boolean[1];
    api.removeAllCookies(
        instance,
        ResultCompat.asCompatCallback(
            reply -> {
              successResult[0] = reply.getOrNull();
              return null;
            }));

    @SuppressWarnings("unchecked")
    final ArgumentCaptor<ValueCallback<Boolean>> valueCallbackArgumentCaptor =
        ArgumentCaptor.forClass(ValueCallback.class);
    verify(instance).removeAllCookies(valueCallbackArgumentCaptor.capture());

    final Boolean returnValue = true;
    valueCallbackArgumentCaptor.getValue().onReceiveValue(returnValue);

    assertEquals(successResult[0], returnValue);
  }

  @Test
  public void setAcceptThirdPartyCookies() {
    final PigeonApiCookieManager api = new TestProxyApiRegistrar().getPigeonApiCookieManager();

    final CookieManager instance = mock(CookieManager.class);
    final android.webkit.WebView webView = mock(WebView.class);
    final boolean accept = true;
    api.setAcceptThirdPartyCookies(instance, webView, accept);

    verify(instance).setAcceptThirdPartyCookies(webView, accept);
  }
}
