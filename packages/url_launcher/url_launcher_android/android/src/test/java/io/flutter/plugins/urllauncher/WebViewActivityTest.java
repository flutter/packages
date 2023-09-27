// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import android.content.Context;
import android.content.Intent;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import java.util.Collections;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.Mockito;

@RunWith(JUnit4.class)
public class WebViewActivityTest {

  private WebView webView;
  private Context context;
  private WebResourceRequest webResourceRequest;

  @Before
  public void setUp() {
    webView = Mockito.mock(WebView.class);
    context = Mockito.mock(Context.class);
    webResourceRequest = Mockito.mock(WebResourceRequest.class);
    Mockito.when(webView.getContext()).thenReturn(context);
    Mockito.when(webView.getWebViewClient()).thenReturn(new FlutterWebViewClient());
  }

  @Test
  public void extractHeaders_returnsEmptyMapWhenHeadersBundleNull() {
    assertEquals(WebViewActivity.extractHeaders(null), Collections.emptyMap());
  }

  @Test
  public void httpRequest_doesNotStartActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "http://www.flutter.dev/");

    verify(context, times(0)).startActivity(any(Intent.class));
    assertFalse(result);
  }

  @Test
  public void httpsRequest_doesNotStartActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "https://www.flutter.dev/");

    verify(context, times(0)).startActivity(any(Intent.class));
    assertFalse(result);
  }

  @Test
  public void smsLink_startsActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "sms:1234567890");

    verify(context, times(1)).startActivity(any(Intent.class));
    assertTrue(result);
  }

  @Test
  public void telLink_startsActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "tel:1234567890");

    verify(context, times(1)).startActivity(any(Intent.class));
    assertTrue(result);
  }

  @Test
  public void geoLink_startsActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "geo:34.090335,-84.255769");

    verify(context, times(1)).startActivity(any(Intent.class));
    assertTrue(result);
  }

  @Test
  public void marketLink_startsActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "market://details?id=com.example.test");

    verify(context, times(1)).startActivity(any(Intent.class));
    assertTrue(result);
  }

  @Test
  public void contentLink_startsActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "content://media/external/images/media/");

    verify(context, times(1)).startActivity(any(Intent.class));
    assertTrue(result);
  }

  @Test
  public void fileLink_startsActivity() {
    boolean result = FlutterWebViewClient.urlShouldRunActivity(webView, "file:///sdcard/download/example.jpg");

    verify(context, times(1)).startActivity(any(Intent.class));
    assertTrue(result);
  }

  @Test
  public void onLoadResource_allowsWebPageLoad() {
    String url = "https://www.flutter.dev/";
    webView.getWebViewClient().onLoadResource(webView, url);

    verify(context, times(0)).startActivity(any(Intent.class));
    assertFalse(FlutterWebViewClient.resourceShouldOpenDocument(webView, url));
  }

  @Test
  public void onLoadResource_loadsPdf() {
    String url = "https://www.flutter.dev/test.pdf";
    webView.getWebViewClient().onLoadResource(webView, url);

    verify(context, times(1)).startActivity(any(Intent.class));
    assertTrue(FlutterWebViewClient.resourceShouldOpenDocument(webView, url));
  }
}
