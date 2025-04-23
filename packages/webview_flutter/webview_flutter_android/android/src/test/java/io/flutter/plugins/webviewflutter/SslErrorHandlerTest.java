// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.SslErrorHandler;
import org.junit.Test;

public class SslErrorHandlerTest {
  @Test
  public void cancel() {
    final PigeonApiSslErrorHandler api = new TestProxyApiRegistrar().getPigeonApiSslErrorHandler();

    final SslErrorHandler instance = mock(SslErrorHandler.class);
    api.cancel(instance);

    verify(instance).cancel();
  }

  @Test
  public void proceed() {
    final PigeonApiSslErrorHandler api = new TestProxyApiRegistrar().getPigeonApiSslErrorHandler();

    final SslErrorHandler instance = mock(SslErrorHandler.class);
    api.proceed(instance);

    verify(instance).proceed();
  }
}
