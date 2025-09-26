// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.os.Message;
import org.junit.Test;

public class MessageTest {
  @Test
  public void sendToTarget() {
    final PigeonApiAndroidMessage api = new TestProxyApiRegistrar().getPigeonApiAndroidMessage();

    final Message instance = mock(Message.class);
    api.sendToTarget(instance);

    verify(instance).sendToTarget();
  }
}
