// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.webkit.ConsoleMessage;
import org.junit.Test;

public class ConsoleMessageTest {
  @Test
  public void lineNumber() {
    final PigeonApiConsoleMessage api = new TestProxyApiRegistrar().getPigeonApiConsoleMessage();

    final ConsoleMessage instance = mock(ConsoleMessage.class);
    final Long value = 0L;
    when(instance.lineNumber()).thenReturn(value.intValue());

    assertEquals(value, (Long) api.lineNumber(instance));
  }

  @Test
  public void message() {
    final PigeonApiConsoleMessage api = new TestProxyApiRegistrar().getPigeonApiConsoleMessage();

    final ConsoleMessage instance = mock(ConsoleMessage.class);
    final String value = "myString";
    when(instance.message()).thenReturn(value);

    assertEquals(value, api.message(instance));
  }

  @Test
  public void level() {
    final PigeonApiConsoleMessage api = new TestProxyApiRegistrar().getPigeonApiConsoleMessage();

    final ConsoleMessage instance = mock(ConsoleMessage.class);
    final ConsoleMessageLevel value = io.flutter.plugins.webviewflutter.ConsoleMessageLevel.DEBUG;
    when(instance.messageLevel()).thenReturn(ConsoleMessage.MessageLevel.DEBUG);

    assertEquals(value, api.level(instance));
  }

  @Test
  public void sourceId() {
    final PigeonApiConsoleMessage api = new TestProxyApiRegistrar().getPigeonApiConsoleMessage();

    final ConsoleMessage instance = mock(ConsoleMessage.class);
    final String value = "myString";
    when(instance.sourceId()).thenReturn(value);

    assertEquals(value, api.sourceId(instance));
  }
}
