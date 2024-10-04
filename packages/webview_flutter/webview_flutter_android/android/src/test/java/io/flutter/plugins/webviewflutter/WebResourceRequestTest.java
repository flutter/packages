// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.net.Uri;
import android.webkit.WebResourceRequest;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import org.junit.Test;

public class WebResourceRequestTest {
  @Test
  public void url() {
    final PigeonApiWebResourceRequest api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceRequest();

    final WebResourceRequest instance = mock(WebResourceRequest.class);
    final String value = "myString";
    when(instance.getUrl()).thenReturn(Uri.parse(value));

    assertEquals(value, api.url(instance));
  }

  @Test
  public void isForMainFrame() {
    final PigeonApiWebResourceRequest api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceRequest();

    final WebResourceRequest instance = mock(WebResourceRequest.class);
    final Boolean value = true;
    when(instance.isForMainFrame()).thenReturn(value);

    assertEquals(value, api.isForMainFrame(instance));
  }

  @Test
  public void isRedirect() {
    final PigeonApiWebResourceRequest api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceRequest();

    final WebResourceRequest instance = mock(WebResourceRequest.class);
    final Boolean value = true;
    when(instance.isRedirect()).thenReturn(value);

    assertEquals(value, api.isRedirect(instance));
  }

  @Test
  public void hasGesture() {
    final PigeonApiWebResourceRequest api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceRequest();

    final WebResourceRequest instance = mock(WebResourceRequest.class);
    final Boolean value = true;
    when(instance.hasGesture()).thenReturn(value);

    assertEquals(value, api.hasGesture(instance));
  }

  @Test
  public void method() {
    final PigeonApiWebResourceRequest api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceRequest();

    final WebResourceRequest instance = mock(WebResourceRequest.class);
    final String value = "myString";
    when(instance.getMethod()).thenReturn(value);

    assertEquals(value, api.method(instance));
  }

  @Test
  public void requestHeaders() {
    final PigeonApiWebResourceRequest api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceRequest();

    final WebResourceRequest instance = mock(WebResourceRequest.class);
    final Map<String, String> value =
        new HashMap<String, String>() {
          {
            put("myString", "myString1");
          }
        };
    when(instance.getRequestHeaders()).thenReturn(value);

    assertEquals(value, api.requestHeaders(instance));
  }

  @Test
  public void requestHeadersHandlesNull() {
    final PigeonApiWebResourceRequest api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceRequest();

    final WebResourceRequest instance = mock(WebResourceRequest.class);
    final Map<String, String> value = Collections.emptyMap();
    when(instance.getRequestHeaders()).thenReturn(value);

    assertEquals(value, api.requestHeaders(instance));
  }
}
