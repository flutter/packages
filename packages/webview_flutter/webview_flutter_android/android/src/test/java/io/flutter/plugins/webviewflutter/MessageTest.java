// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.os.Message;
import android.webkit.PermissionRequest;
import java.util.Collections;
import java.util.List;
import org.junit.Test;

public class MessageTest {
  @Test
  public void sendToTarget() {
    final PigeonApiAndroidMessage api =
        new TestProxyApiRegistrar().getPigeonApiAndroidMessage();

    final Message instance = mock(Message.class);
    api.sendToTarget(instance);

    verify(instance).sendToTarget();
  }
}
