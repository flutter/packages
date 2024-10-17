// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.Test;

public class JavaScriptChannelTest {
  @Test
  public void postMessage() {
    final JavaScriptChannelProxyApi mockApi = mock(JavaScriptChannelProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final JavaScriptChannel instance = new JavaScriptChannel("channel", mockApi);
    final String message = "myString";
    instance.postMessage(message);

    verify(mockApi).postMessage(eq(instance), eq(message), any());
  }
}
