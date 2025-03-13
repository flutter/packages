// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.net.Uri;
import android.os.Message;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.GeolocationPermissions;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.PermissionRequest;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebView.WebViewTransport;
import android.webkit.WebViewClient;
import io.flutter.plugins.webviewflutter.WebChromeClientProxyApi.WebChromeClientImpl;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class WebChromeClientTest {
  @Test
  public void onProgressChanged() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    final android.webkit.WebView webView = mock(WebView.class);
    final Long progress = 0L;
    instance.onProgressChanged(webView, progress.intValue());

    verify(mockApi).onProgressChanged(eq(instance), eq(webView), eq(progress), any());
  }

  @Test
  public void onCreateWindow() {
    final WebView mockOnCreateWindowWebView = mock(WebView.class);

    // Create a fake message to transport requests to onCreateWindowWebView.
    final Message message = new Message();
    message.obj = mock(WebViewTransport.class);

    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);

    final WebViewClient mockWebViewClient = mock(WebViewClient.class);
    final WebView mockWebView = mock(WebView.class);
    instance.setWebViewClient(mockWebViewClient);
    assertTrue(instance.onCreateWindow(mockWebView, message, mockOnCreateWindowWebView));

    /// Capture the WebViewClient used with onCreateWindow WebView.
    final ArgumentCaptor<WebViewClient> webViewClientCaptor =
        ArgumentCaptor.forClass(WebViewClient.class);
    verify(mockOnCreateWindowWebView).setWebViewClient(webViewClientCaptor.capture());
    final WebViewClient onCreateWindowWebViewClient = webViewClientCaptor.getValue();
    assertNotNull(onCreateWindowWebViewClient);

    /// Create a WebResourceRequest with a Uri.
    final WebResourceRequest mockRequest = mock(WebResourceRequest.class);
    when(mockRequest.getUrl()).thenReturn(mock(Uri.class));
    when(mockRequest.getUrl().toString()).thenReturn("https://www.google.com");

    // Test when the forwarding WebViewClient is overriding all url loading.
    when(mockWebViewClient.shouldOverrideUrlLoading(any(), any(WebResourceRequest.class)))
        .thenReturn(true);
    assertTrue(
        onCreateWindowWebViewClient.shouldOverrideUrlLoading(
            mockOnCreateWindowWebView, mockRequest));
    verify(mockWebView, never()).loadUrl(any());

    // Test when the forwarding WebViewClient is NOT overriding all url loading.
    when(mockWebViewClient.shouldOverrideUrlLoading(any(), any(WebResourceRequest.class)))
        .thenReturn(false);
    assertTrue(
        onCreateWindowWebViewClient.shouldOverrideUrlLoading(
            mockOnCreateWindowWebView, mockRequest));
    verify(mockWebView).loadUrl("https://www.google.com");
  }

  @Test
  public void onPermissionRequest() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    final android.webkit.PermissionRequest request = mock(PermissionRequest.class);
    instance.onPermissionRequest(request);

    verify(mockApi).onPermissionRequest(eq(instance), eq(request), any());
  }

  @Test
  public void onShowCustomView() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    final android.view.View view = mock(View.class);
    final android.webkit.WebChromeClient.CustomViewCallback callback =
        mock(WebChromeClient.CustomViewCallback.class);
    instance.onShowCustomView(view, callback);

    verify(mockApi).onShowCustomView(eq(instance), eq(view), eq(callback), any());
  }

  @Test
  public void onHideCustomView() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    instance.onHideCustomView();

    verify(mockApi).onHideCustomView(eq(instance), any());
  }

  @Test
  public void onGeolocationPermissionsShowPrompt() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    final String origin = "myString";
    final android.webkit.GeolocationPermissions.Callback callback =
        mock(GeolocationPermissions.Callback.class);
    instance.onGeolocationPermissionsShowPrompt(origin, callback);

    verify(mockApi)
        .onGeolocationPermissionsShowPrompt(eq(instance), eq(origin), eq(callback), any());
  }

  @Test
  public void onGeolocationPermissionsHidePrompt() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    instance.onGeolocationPermissionsHidePrompt();

    verify(mockApi).onGeolocationPermissionsHidePrompt(eq(instance), any());
  }

  @Test
  public void onConsoleMessage() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    instance.setReturnValueForOnConsoleMessage(true);
    final android.webkit.ConsoleMessage message = mock(ConsoleMessage.class);
    instance.onConsoleMessage(message);

    verify(mockApi).onConsoleMessage(eq(instance), eq(message), any());
  }

  @Test
  public void onJsAlert() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    instance.setReturnValueForOnJsAlert(true);
    final android.webkit.WebView webView = mock(WebView.class);
    final String url = "myString";
    final String message = "myString";
    final JsResult mockJsResult = mock(JsResult.class);
    instance.onJsAlert(webView, url, message, mockJsResult);

    verify(mockApi).onJsAlert(eq(instance), eq(webView), eq(url), eq(message), any());
  }

  @Test
  public void onJsConfirm() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    instance.setReturnValueForOnJsConfirm(true);
    final android.webkit.WebView webView = mock(WebView.class);
    final String url = "myString";
    final String message = "myString";
    final JsResult mockJsResult = mock(JsResult.class);
    instance.onJsConfirm(webView, url, message, mockJsResult);

    verify(mockApi).onJsConfirm(eq(instance), eq(webView), eq(url), eq(message), any());
  }

  @Test
  public void onJsPrompt() {
    final WebChromeClientProxyApi mockApi = mock(WebChromeClientProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebChromeClientImpl instance = new WebChromeClientImpl(mockApi);
    instance.setReturnValueForOnJsPrompt(true);
    final android.webkit.WebView webView = mock(WebView.class);
    final String url = "myString";
    final String message = "myString";
    final String defaultValue = "myString";
    final JsPromptResult mockJsPromptResult = mock(JsPromptResult.class);
    instance.onJsPrompt(webView, url, message, defaultValue, mockJsPromptResult);

    verify(mockApi)
        .onJsPrompt(eq(instance), eq(webView), eq(url), eq(message), eq(defaultValue), any());
  }
}
