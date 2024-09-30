// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.CookieManager;
import android.webkit.WebView;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.junit.Test;

public class CookieManagerTest {
  @Test
  public void setCookie() {
    final PigeonApiCookieManager api = new TestProxyApiRegistrar().getPigeonApiCookieManager();

    final CookieManager instance = mock(CookieManager.class);
    final String url = "myString";
    final String value = "myString";
    api.setCookie(instance, url, value);

    verify(instance).setCookie(url, value);
  }

  @Test
  public void removeAllCookies() {
    final PigeonApiCookieManager api = new TestProxyApiRegistrar().getPigeonApiCookieManager();

    final CookieManager instance = mock(CookieManager.class);
    final Boolean value = true;

    api.removeAllCookies(
        instance,
        (Function1<? super Result<Boolean>, Unit>)
            ResultCompat.withSuccessResult(value).getResult());

    verify(instance).removeAllCookies(any());
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
