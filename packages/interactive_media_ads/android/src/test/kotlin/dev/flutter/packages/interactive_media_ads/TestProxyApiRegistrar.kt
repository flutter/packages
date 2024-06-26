// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import org.mockito.kotlin.mock

/**
 * Test implementation of `ProxyApiRegistrar` that provides mocks and instantly runs callbacks
 * instead of posting them.
 */
class TestProxyApiRegistrar : ProxyApiRegistrar(mock(), mock()) {
  override fun runOnMainThread(callback: Runnable) {
    callback.run()
  }
}
