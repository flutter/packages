// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.webkit.WebResourceResponse;
import org.junit.Test;

public class WebResourceResponseTest {
  @Test
  public void statusCode() {
    final PigeonApiWebResourceResponse api =
        new TestProxyApiRegistrar().getPigeonApiWebResourceResponse();

    final WebResourceResponse instance = mock(WebResourceResponse.class);
    final Long value = 0L;
    when(instance.getStatusCode()).thenReturn(value.intValue());

    assertEquals(value, (Long) api.statusCode(instance));
  }
}
