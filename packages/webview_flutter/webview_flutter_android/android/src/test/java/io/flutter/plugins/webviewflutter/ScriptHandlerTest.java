// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import androidx.webkit.ScriptHandler;
import org.junit.Test;

public class ScriptHandlerTest {
  @Test
  public void remove() {
    final PigeonApiScriptHandler api = new TestProxyApiRegistrar().getPigeonApiScriptHandler();

    final ScriptHandler instance = mock(ScriptHandler.class);
    api.remove(instance);

    verify(instance).remove();
  }
}
