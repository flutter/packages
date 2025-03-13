// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.embedding.android.FlutterView;
import java.util.HashMap;
import java.util.Map;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class WebViewTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    assertTrue(api.pigeon_defaultConstructor() instanceof WebViewProxyApi.WebViewPlatformView);
  }

  @Test
  public void loadData() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String data = "VGhpcyBkYXRhIGlzIGJhc2U2NCBlbmNvZGVkLg==";
    final String mimeType = "text/plain";
    final String encoding = "base64";
    api.loadData(instance, data, mimeType, encoding);

    verify(instance).loadData(data, mimeType, encoding);
  }

  @Test
  public void loadDataWithNullValues() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String data = "VGhpcyBkYXRhIGlzIGJhc2U2NCBlbmNvZGVkLg==";
    final String mimeType = null;
    final String encoding = null;
    api.loadData(instance, data, mimeType, encoding);

    verify(instance).loadData(data, mimeType, encoding);
  }

  @Test
  public void loadDataWithBaseUrl() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String baseUrl = "myString";
    final String data = "myString1";
    final String mimeType = "myString2";
    final String encoding = "myString3";
    final String historyUrl = "myString4";
    api.loadDataWithBaseUrl(instance, baseUrl, data, mimeType, encoding, historyUrl);

    verify(instance).loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
  }

  @Test
  public void loadDataWithBaseUrlAndNullValues() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String baseUrl = null;
    final String data = "myString1";
    final String mimeType = null;
    final String encoding = null;
    final String historyUrl = null;
    api.loadDataWithBaseUrl(instance, baseUrl, data, mimeType, encoding, historyUrl);

    verify(instance).loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
  }

  @Test
  public void loadUrl() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String url = "myString";
    final Map<String, String> headers =
        new HashMap<String, String>() {
          {
            put("myString", "myString");
          }
        };
    api.loadUrl(instance, url, headers);

    verify(instance).loadUrl(url, headers);
  }

  @Test
  public void postUrl() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String url = "myString";
    final byte[] data = {(byte) 0xA1};
    api.postUrl(instance, url, data);

    verify(instance).postUrl(url, data);
  }

  @Test
  public void getUrl() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String value = "myString";
    when(instance.getUrl()).thenReturn(value);

    assertEquals(value, api.getUrl(instance));
  }

  @Test
  public void canGoBack() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final Boolean value = true;
    when(instance.canGoBack()).thenReturn(value);

    assertEquals(value, api.canGoBack(instance));
  }

  @Test
  public void canGoForward() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final Boolean value = true;
    when(instance.canGoForward()).thenReturn(value);

    assertEquals(value, api.canGoForward(instance));
  }

  @Test
  public void goBack() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    api.goBack(instance);

    verify(instance).goBack();
  }

  @Test
  public void goForward() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    api.goForward(instance);

    verify(instance).goForward();
  }

  @Test
  public void reload() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    api.reload(instance);

    verify(instance).reload();
  }

  @Test
  public void clearCache() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final boolean includeDiskFiles = true;
    api.clearCache(instance, includeDiskFiles);

    verify(instance).clearCache(includeDiskFiles);
  }

  @Test
  public void evaluateJavaScript() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String script = "2 + 2";
    final String[] resultValue = new String[1];
    api.evaluateJavascript(
        instance,
        script,
        ResultCompat.asCompatCallback(
            reply -> {
              resultValue[0] = reply.getOrNull();
              return null;
            }));

    @SuppressWarnings("unchecked")
    final ArgumentCaptor<ValueCallback<String>> callbackCaptor =
        ArgumentCaptor.forClass(ValueCallback.class);
    verify(instance).evaluateJavascript(eq(script), callbackCaptor.capture());

    final String result = "resultValue";
    callbackCaptor.getValue().onReceiveValue(result);
    assertEquals(resultValue[0], result);
  }

  @Test
  public void getTitle() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String value = "myString";
    when(instance.getTitle()).thenReturn(value);

    assertEquals(value, api.getTitle(instance));
  }

  @Test
  public void setWebViewClient() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final android.webkit.WebViewClient client = mock(WebViewClient.class);
    api.setWebViewClient(instance, client);

    verify(instance).setWebViewClient(client);
  }

  @Test
  public void addJavaScriptChannel() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final JavaScriptChannel channel = mock(JavaScriptChannel.class);
    api.addJavaScriptChannel(instance, channel);

    verify(instance).addJavascriptInterface(channel, channel.javaScriptChannelName);
  }

  @Test
  public void removeJavaScriptChannel() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final String name = "myString";
    api.removeJavaScriptChannel(instance, name);

    verify(instance).removeJavascriptInterface(name);
  }

  @Test
  public void setDownloadListener() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final android.webkit.DownloadListener listener = mock(DownloadListener.class);
    api.setDownloadListener(instance, listener);

    verify(instance).setDownloadListener(listener);
  }

  @Test
  public void setWebChromeClient() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final io.flutter.plugins.webviewflutter.WebChromeClientProxyApi.WebChromeClientImpl client =
        mock(WebChromeClientProxyApi.WebChromeClientImpl.class);
    api.setWebChromeClient(instance, client);

    verify(instance).setWebChromeClient(client);
  }

  @Test
  public void setBackgroundColor() {
    final PigeonApiWebView api = new TestProxyApiRegistrar().getPigeonApiWebView();

    final WebView instance = mock(WebView.class);
    final long color = 0L;
    api.setBackgroundColor(instance, color);

    verify(instance).setBackgroundColor((int) color);
  }

  @Test
  public void defaultWebChromeClientIsSecureWebChromeClient() {
    final WebViewProxyApi mockApi = mock(WebViewProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());
    final WebViewProxyApi.WebViewPlatformView webView =
        new WebViewProxyApi.WebViewPlatformView(mockApi);

    assertTrue(
        webView.getWebChromeClient() instanceof WebChromeClientProxyApi.SecureWebChromeClient);
    assertFalse(
        webView.getWebChromeClient() instanceof WebChromeClientProxyApi.WebChromeClientImpl);
  }

  // This test verifies that WebView.destroy() is called when the Dart instance is garbage collected.
  // This requires adding
  //
  // ```
  // val instance: Any? = getInstance(identifier)
  // if (instance is WebViewProxyApi.WebViewPlatformView) {
  //   instance.destroy()
  // }
  // ```
  //
  // to `AndroidWebkitLibraryPigeonInstanceManager.remove` in the generated code. This is done as a
  // temporary workaround to prevent the transition to the new pigeon ProxyApi generator from being
  // a breaking change. Maintainers should consider whether continuing  to call `destroy` on
  // `WebView` is valuable.
  @Test
  public void destroyWebViewWhenRemovedFromInstanceManager() {
    final WebViewProxyApi.WebViewPlatformView mockWebView =
        mock(WebViewProxyApi.WebViewPlatformView.class);

    final TestProxyApiRegistrar registrar = new TestProxyApiRegistrar();
    registrar.getInstanceManager().addDartCreatedInstance(mockWebView, 0);

    registrar.getInstanceManager().remove(0);
    verify(mockWebView).destroy();
  }

  @Test
  public void setImportantForAutofillForParentFlutterView() {
    final WebViewProxyApi mockApi = mock(WebViewProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());
    final WebViewProxyApi.WebViewPlatformView webView =
        new WebViewProxyApi.WebViewPlatformView(mockApi);

    final WebViewProxyApi.WebViewPlatformView webViewSpy = spy(webView);
    final FlutterView mockFlutterView = mock(FlutterView.class);
    when(webViewSpy.getParent()).thenReturn(mockFlutterView);

    webViewSpy.onAttachedToWindow();

    verify(mockFlutterView).setImportantForAutofill(View.IMPORTANT_FOR_AUTOFILL_YES);
  }

  @Test
  public void onScrollChanged() {
    final WebViewProxyApi mockApi = mock(WebViewProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final WebViewProxyApi.WebViewPlatformView instance =
        new WebViewProxyApi.WebViewPlatformView(mockApi);
    final Long left = 0L;
    final Long top = 0L;
    final Long oldLeft = 0L;
    final Long oldTop = 0L;
    instance.onScrollChanged(
        left.intValue(), top.intValue(), oldLeft.intValue(), oldTop.intValue());

    verify(mockApi)
        .onScrollChanged(eq(instance), eq(left), eq(top), eq(oldLeft), eq(oldTop), any());
  }
}
