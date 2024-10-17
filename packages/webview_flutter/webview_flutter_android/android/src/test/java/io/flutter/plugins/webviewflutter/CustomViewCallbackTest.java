// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.WebChromeClient.CustomViewCallback;
import org.junit.Test;

public class CustomViewCallbackTest {
  @Test
  public void onCustomViewHidden() {
    final PigeonApiCustomViewCallback api =
        new TestProxyApiRegistrar().getPigeonApiCustomViewCallback();

    final CustomViewCallback instance = mock(CustomViewCallback.class);
    api.onCustomViewHidden(instance);

    verify(instance).onCustomViewHidden();
  }
}
