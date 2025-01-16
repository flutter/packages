// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.junit.Test;

public class WebViewPointTest {
  @Test
  public void x() {
    final PigeonApiWebViewPoint api = new TestProxyApiRegistrar().getPigeonApiWebViewPoint();

    final WebViewPoint instance = mock(WebViewPoint.class);
    final Long value = 0L;
    when(instance.getX()).thenReturn(value);

    assertEquals(value, (Long) api.x(instance));
  }

  @Test
  public void y() {
    final PigeonApiWebViewPoint api = new TestProxyApiRegistrar().getPigeonApiWebViewPoint();

    final WebViewPoint instance = mock(WebViewPoint.class);
    final Long value = 0L;
    when(instance.getY()).thenReturn(value);

    assertEquals(value, (Long) api.y(instance));
  }
}
