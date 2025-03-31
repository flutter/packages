// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.webkit.HttpAuthHandler;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import io.flutter.plugins.webviewflutter.WebViewClientProxyApi.WebViewClientImpl;
import org.junit.Test;

public class WebViewClientTest {
  @Test
  public void onPageStarted() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientProxyApi.WebViewClientImpl(mockApi);
    final WebView webView = mock(WebView.class);
    final String url = "myString";
    instance.onPageStarted(webView, url, null);

    verify(mockApi).onPageStarted(eq(instance), eq(webView), eq(url), any());
  }

  @Test
  public void onReceivedError() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final Long errorCode = 0L;
    final String description = "myString";
    final String failingUrl = "myString1";
    instance.onReceivedError(webView, errorCode.intValue(), description, failingUrl);

    verify(mockApi)
        .onReceivedError(
            eq(instance), eq(webView), eq(errorCode), eq(description), eq(failingUrl), any());
  }

  @Test
  public void urlLoading() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final String url = "myString";
    instance.shouldOverrideUrlLoading(webView, url);

    verify(mockApi).urlLoading(eq(instance), eq(webView), eq(url), any());
  }

  @Test
  public void urlLoadingForMainFrame() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    instance.setReturnValueForShouldOverrideUrlLoading(false);
    final android.webkit.WebView webView = mock(WebView.class);
    final String url = "myString";
    instance.shouldOverrideUrlLoading(webView, url);

    verify(mockApi).urlLoading(eq(instance), eq(webView), eq(url), any());
  }

  @Test
  public void urlLoadingForMainFrameWithOverride() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    instance.setReturnValueForShouldOverrideUrlLoading(true);
    final android.webkit.WebView webView = mock(WebView.class);
    final String url = "myString";

    assertTrue(instance.shouldOverrideUrlLoading(webView, url));
    verify(mockApi).urlLoading(eq(instance), eq(webView), eq(url), any());
  }

  @Test
  public void urlLoadingNotForMainFrame() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final android.webkit.WebResourceRequest request = mock(WebResourceRequest.class);
    when(request.isForMainFrame()).thenReturn(false);
    instance.shouldOverrideUrlLoading(webView, request);

    verify(mockApi).requestLoading(eq(instance), eq(webView), eq(request), any());
  }

  @Test
  public void urlLoadingNotForMainFrameWithOverride() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final android.webkit.WebResourceRequest request = mock(WebResourceRequest.class);
    when(request.isForMainFrame()).thenReturn(false);

    assertFalse(instance.shouldOverrideUrlLoading(webView, request));
    verify(mockApi).requestLoading(eq(instance), eq(webView), eq(request), any());
  }

  @Test
  public void doUpdateVisitedHistory() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final String url = "myString";
    final Boolean isReload = true;
    instance.doUpdateVisitedHistory(webView, url, isReload);

    verify(mockApi).doUpdateVisitedHistory(eq(instance), eq(webView), eq(url), eq(isReload), any());
  }

  @Test
  public void onReceivedHttpError() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final HttpAuthHandler handler = mock(HttpAuthHandler.class);
    final String host = "myString";
    final String realm = "myString1";
    instance.onReceivedHttpAuthRequest(webView, handler, host, realm);

    verify(mockApi)
        .onReceivedHttpAuthRequest(
            eq(instance), eq(webView), eq(handler), eq(host), eq(realm), any());
  }
}
