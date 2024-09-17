// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import androidx.webkit.WebResourceErrorCompat;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import static org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class WebResourceErrorCompatTest {
  @Test
  public void errorCode() {
    final PigeonApiWebResourceErrorCompat api = new TestProxyApiRegistrar().getPigeonApiWebResourceErrorCompat();

    final WebResourceErrorCompat instance = mock(WebResourceErrorCompat.class);
    final Long value = 0L;
    when(instance.getErrorCode()).thenReturn(value.intValue());

    assertEquals(value, (Long) api.errorCode(instance));
  }

  @Test
  public void description() {
    final PigeonApiWebResourceErrorCompat api = new TestProxyApiRegistrar().getPigeonApiWebResourceErrorCompat();

    final WebResourceErrorCompat instance = mock(WebResourceErrorCompat.class);
    final String value = "myString";
    when(instance.getDescription()).thenReturn(value);

    assertEquals(value, api.description(instance));
  }
}