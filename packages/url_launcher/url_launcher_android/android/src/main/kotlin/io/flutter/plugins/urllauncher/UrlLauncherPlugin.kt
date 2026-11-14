// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.urllauncher

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugins.urllauncher.UrlLauncherApi.Companion.setUp

/**
 * Plugin implementation that uses the new `io.flutter.embedding` package.
 *
 * Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
class UrlLauncherPlugin : FlutterPlugin, ActivityAware {
  private var urlLauncher: UrlLauncher? = null

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    urlLauncher = UrlLauncher(binding.applicationContext)
    setUp(binding.binaryMessenger, urlLauncher)
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    if (urlLauncher == null) {
      Log.wtf(TAG, "Already detached from the engine.")
      return
    }

    setUp(binding.binaryMessenger, null)
    urlLauncher = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    val launcher =
        urlLauncher
            ?: run {
              Log.wtf(TAG, "urlLauncher was never set.")
              return
            }
    launcher.setActivity(binding.activity)
  }

  override fun onDetachedFromActivity() {
    val launcher =
        urlLauncher
            ?: run {
              Log.wtf(TAG, "urlLauncher was never set.")
              return
            }
    launcher.setActivity(null)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  companion object {
    private const val TAG = "UrlLauncherPlugin"
  }
}
