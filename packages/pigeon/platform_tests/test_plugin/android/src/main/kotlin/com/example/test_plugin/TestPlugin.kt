// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * This plugin handles the native side of the integration tests in
 * example/integration_test/.
 */
class TestPlugin: FlutterPlugin, AllVoidHostApi, HostEverything {
  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    AllVoidHostApi.setUp(binding.getBinaryMessenger(), this)
    HostEverything.setUp(binding.getBinaryMessenger(), this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  // AllVoidHostApi

  override fun doit() {
    // No-op.
  }

  // HostEverything

  override fun giveMeEverything(): Everything {
    // Currently unused in integration tests, so just return an empty object.
    return Everything()
  }

  override fun echo(everything: Everything): Everything {
    return everything
  }
}
