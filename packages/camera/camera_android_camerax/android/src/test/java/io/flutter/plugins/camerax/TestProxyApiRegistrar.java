// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.Mockito.mock;

import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;
import org.checkerframework.checker.nullness.qual.NonNull;

/**
 * Test implementation of `ProxyApiRegistrar` that provides mocks, instantly runs callbacks instead
 * of posting them, and makes all SDK checks pass by default.
 */
public class TestProxyApiRegistrar extends ProxyApiRegistrar {
  public TestProxyApiRegistrar() {
    super(mock(BinaryMessenger.class), mock(Context.class), mock(TextureRegistry.class));
  }

  @Override
  void runOnMainThread(@NonNull FlutterMethodRunnable runnable) {
    runnable.run();
  }

  @Override
  boolean sdkIsAtLeast(int version) {
    return true;
  }
}
