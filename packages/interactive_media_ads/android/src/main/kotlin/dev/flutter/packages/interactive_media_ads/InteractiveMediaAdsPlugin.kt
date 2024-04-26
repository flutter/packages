// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** InteractiveMediaAdsPlugin */
class InteractiveMediaAdsPlugin : FlutterPlugin, ActivityAware {
  private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding
  private lateinit var registrar: ProxyApiRegistrar

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = flutterPluginBinding
    registrar =
        ProxyApiRegistrar(pluginBinding.binaryMessenger, context = pluginBinding.applicationContext)
    registrar.setUp()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    registrar.tearDown()
    registrar.instanceManager.clear()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    registrar.context = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    registrar.context = pluginBinding.applicationContext
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    registrar.context = binding.activity
  }

  override fun onDetachedFromActivity() {
    registrar.context = pluginBinding.applicationContext
  }
}
