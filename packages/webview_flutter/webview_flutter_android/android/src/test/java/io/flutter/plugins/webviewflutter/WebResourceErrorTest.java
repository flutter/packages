// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.net.Uri;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;

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

public class WebResourceErrorTest {
  @Test
  public void errorCode() {
    final PigeonApiWebResourceError api = new TestProxyApiRegistrar().getPigeonApiWebResourceError();

    final WebResourceError instance = mock(WebResourceError.class);
    final Long value = 0L;
    when(instance.getErrorCode()).thenReturn(value.intValue());

    assertEquals(value, (Long) api.errorCode(instance));
  }

  @Test
  public void description() {
    final PigeonApiWebResourceError api = new TestProxyApiRegistrar().getPigeonApiWebResourceError();

    final WebResourceError instance = mock(WebResourceError.class);
    final String value = "myString";
    when(instance.getDescription()).thenReturn(value);

    assertEquals(value, api.description(instance));
  }
}
