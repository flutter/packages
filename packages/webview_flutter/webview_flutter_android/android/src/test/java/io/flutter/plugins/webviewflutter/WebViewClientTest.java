// Copyright 2013 The Flutter Authors
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

import android.net.http.SslError;
import android.os.Message;
import android.webkit.ClientCertRequest;
import android.webkit.HttpAuthHandler;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceError;
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
    final android.webkit.WebResourceRequest request = mock(WebResourceRequest.class);
    final android.webkit.WebResourceError error = mock(WebResourceError.class);
    instance.onReceivedError(webView, request, error);

    verify(mockApi)
        .onReceivedRequestError(eq(instance), eq(webView), eq(request), eq(error), any());
  }

  @Test
  public void urlLoading() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final android.webkit.WebResourceRequest request = mock(WebResourceRequest.class);
    instance.shouldOverrideUrlLoading(webView, request);

    verify(mockApi).requestLoading(eq(instance), eq(webView), eq(request), any());
  }

  @Test
  public void urlLoadingForMainFrame() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    instance.setReturnValueForShouldOverrideUrlLoading(false);
    final android.webkit.WebView webView = mock(WebView.class);
    final android.webkit.WebResourceRequest request = mock(WebResourceRequest.class);
    when(request.isForMainFrame()).thenReturn(true);
    instance.shouldOverrideUrlLoading(webView, request);

    verify(mockApi).requestLoading(eq(instance), eq(webView), eq(request), any());
  }

  @Test
  public void urlLoadingForMainFrameWithOverride() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    instance.setReturnValueForShouldOverrideUrlLoading(true);
    final android.webkit.WebView webView = mock(WebView.class);
    final android.webkit.WebResourceRequest request = mock(WebResourceRequest.class);
    when(request.isForMainFrame()).thenReturn(true);

    assertTrue(instance.shouldOverrideUrlLoading(webView, request));
    verify(mockApi).requestLoading(eq(instance), eq(webView), eq(request), any());
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

  @Test
  public void onFormResubmission() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView view = mock(WebView.class);
    final android.os.Message dontResend = mock(Message.class);
    final android.os.Message resend = mock(Message.class);
    instance.onFormResubmission(view, dontResend, resend);

    verify(mockApi).onFormResubmission(eq(instance), eq(view), eq(dontResend), eq(resend), any());
  }

  @Test
  public void onLoadResource() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView view = mock(WebView.class);
    final String url = "myString";
    instance.onLoadResource(view, url);

    verify(mockApi).onLoadResource(eq(instance), eq(view), eq(url), any());
  }

  @Test
  public void onPageCommitVisible() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView view = mock(WebView.class);
    final String url = "myString";
    instance.onPageCommitVisible(view, url);

    verify(mockApi).onPageCommitVisible(eq(instance), eq(view), eq(url), any());
  }

  @Test
  public void onReceivedClientCertRequest() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView view = mock(WebView.class);
    final android.webkit.ClientCertRequest request = mock(ClientCertRequest.class);
    instance.onReceivedClientCertRequest(view, request);

    verify(mockApi).onReceivedClientCertRequest(eq(instance), eq(view), eq(request), any());
  }

  @Test
  public void onReceivedLoginRequest() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView view = mock(WebView.class);
    final String realm = "myString";
    final String account = "myString1";
    final String args = "myString2";
    instance.onReceivedLoginRequest(view, realm, account, args);

    verify(mockApi)
        .onReceivedLoginRequest(eq(instance), eq(view), eq(realm), eq(account), eq(args), any());
  }

  @Test
  public void onReceivedSslError() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView view = mock(WebView.class);
    final android.webkit.SslErrorHandler handler = mock(SslErrorHandler.class);
    final android.net.http.SslError error = mock(SslError.class);
    instance.onReceivedSslError(view, handler, error);

    verify(mockApi).onReceivedSslError(eq(instance), eq(view), eq(handler), eq(error), any());
  }

  @Test
  public void onScaleChanged() {
    final WebViewClientProxyApi mockApi = mock(WebViewClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewClientImpl instance = new WebViewClientImpl(mockApi);
    final android.webkit.WebView view = mock(WebView.class);
    final float oldScale = 1.0f;
    final float newScale = 2.0f;
    instance.onScaleChanged(view, oldScale, newScale);

    verify(mockApi)
        .onScaleChanged(
            eq(instance), eq(view), eq((double) oldScale), eq((double) newScale), any());
  }
}
