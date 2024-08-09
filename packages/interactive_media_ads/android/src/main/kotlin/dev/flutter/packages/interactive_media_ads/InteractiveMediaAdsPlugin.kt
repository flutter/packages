// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.content.Context
import android.view.View
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** InteractiveMediaAdsPlugin */
class InteractiveMediaAdsPlugin : FlutterPlugin, ActivityAware {
  private lateinit var pluginBinding: FlutterPlugin.FlutterPluginBinding
  private lateinit var registrar: ProxyApiRegistrar

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = flutterPluginBinding

    registrar =
        ProxyApiRegistrar(pluginBinding.binaryMessenger, context = pluginBinding.applicationContext)
    registrar.setUp()

    flutterPluginBinding.platformViewRegistry.registerViewFactory(
        "interactive_media_ads.packages.flutter.dev/view",
        FlutterViewFactory(registrar.instanceManager))
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    registrar.ignoreCallsToDart = true
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

internal class FlutterViewFactory(
    private val instanceManager: InteractiveMediaAdsLibraryPigeonInstanceManager
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val identifier =
        args as Int?
            ?: throw IllegalStateException("An identifier is required to retrieve a View instance.")
    val instance: Any? = instanceManager.getInstance(identifier.toLong())
    if (instance is PlatformView) {
      return instance
    } else if (instance is View) {
      return object : PlatformView {
        override fun getView(): View {
          return instance
        }

        override fun dispose() {}
      }
    }
    throw IllegalStateException("Unable to find a PlatformView or View instance: $args, $instance")
  }
}
