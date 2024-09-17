// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.WebChromeClient.CustomViewCallback;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import static org.mockito.Mockito.mock;

public class CustomViewCallbackTest {
  @Test
  public void onCustomViewHidden() {
    final PigeonApiCustomViewCallback api = new TestProxyApiRegistrar().getPigeonApiCustomViewCallback();

    final CustomViewCallback instance = mock(CustomViewCallback.class);
    api.onCustomViewHidden(instance );

    verify(instance).onCustomViewHidden();
  }
}
