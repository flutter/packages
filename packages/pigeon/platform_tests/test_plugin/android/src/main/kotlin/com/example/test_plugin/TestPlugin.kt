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
class TestPlugin: FlutterPlugin, HostIntegrationCoreApi {
  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    HostIntegrationCoreApi.setUp(binding.getBinaryMessenger(), this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  // HostIntegrationCoreApi

  override fun noop() {
  }

  override fun echoAllTypes(everything: AllTypes): AllTypes {
    return everything
  }

  override fun throwError() {
    throw Exception("An error");
  }

  override fun extractNestedString(wrapper: AllTypesWrapper): String? {
    return wrapper.values.aString;
  }

  override fun createNestedString(string: String): AllTypesWrapper {
    return AllTypesWrapper(AllTypes(aString = string))
  }
}
