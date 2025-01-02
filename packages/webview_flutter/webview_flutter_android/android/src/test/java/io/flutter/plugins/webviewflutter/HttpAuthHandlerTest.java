// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.webkit.HttpAuthHandler;
import org.junit.Test;

public class HttpAuthHandlerTest {
  @Test
  public void proceed() {
    final PigeonApiHttpAuthHandler api = new TestProxyApiRegistrar().getPigeonApiHttpAuthHandler();

    final HttpAuthHandler instance = mock(HttpAuthHandler.class);
    final String username = "myString";
    final String password = "myString1";
    api.proceed(instance, username, password);

    verify(instance).proceed(username, password);
  }

  @Test
  public void cancel() {
    final PigeonApiHttpAuthHandler api = new TestProxyApiRegistrar().getPigeonApiHttpAuthHandler();

    final HttpAuthHandler instance = mock(HttpAuthHandler.class);
    api.cancel(instance);

    verify(instance).cancel();
  }

  @Test
  public void useHttpAuthUsernamePassword() {
    final PigeonApiHttpAuthHandler api = new TestProxyApiRegistrar().getPigeonApiHttpAuthHandler();

    final HttpAuthHandler instance = mock(HttpAuthHandler.class);
    final Boolean value = true;
    when(instance.useHttpAuthUsernamePassword()).thenReturn(value);

    assertEquals(value, api.useHttpAuthUsernamePassword(instance));
  }
}
