// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.quickactions

import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.VisibleForTesting
import androidx.core.content.pm.ShortcutManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import io.flutter.plugins.quickactions.AndroidQuickActionsApi.Companion.setUp

/** QuickActionsPlugin */
class QuickActionsPlugin
@VisibleForTesting
internal constructor(private val sdkIsAtLeast: (Int) -> Boolean) :
    FlutterPlugin, ActivityAware, NewIntentListener {
  private var quickActions: QuickActions? = null
  private var quickActionsFlutterApi: AndroidQuickActionsFlutterApi? = null

  constructor() : this(sdkIsAtLeast = { version: Int -> Build.VERSION.SDK_INT >= version })

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    quickActions = QuickActions(binding.applicationContext)
    setUp(binding.binaryMessenger, quickActions)
    quickActionsFlutterApi = AndroidQuickActionsFlutterApi(binding.binaryMessenger, "")
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    setUp(binding.binaryMessenger, null)
    quickActions = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    if (quickActions == null) {
      Log.wtf(TAG, "quickActions was never set.")
      return
    }

    val activity = binding.activity
    quickActions?.activity = activity
    binding.addOnNewIntentListener(this)
    onNewIntent(activity.intent)
  }

  override fun onDetachedFromActivity() {
    quickActions?.activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    binding.removeOnNewIntentListener(this)
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onNewIntent(intent: Intent): Boolean {
    // Do nothing for anything lower than API 25 as the functionality isn't supported.
    if (!sdkIsAtLeast(Build.VERSION_CODES.N_MR1)) {
      return false
    }
    val activity = quickActions?.activity
    // Notify the Dart side if the launch intent has the intent extra relevant to quick actions.
    if (intent.hasExtra(QuickActions.EXTRA_ACTION) && activity != null) {
      val context = activity.applicationContext
      val shortcutId = intent.getStringExtra(QuickActions.EXTRA_ACTION)
      if (shortcutId != null) {
        quickActionsFlutterApi?.launchAction(shortcutId) { result ->
          val error = result.exceptionOrNull()
          if (error != null) {
            Log.e(TAG, "Failed to handle launch action: " + error.message)
          }
        }
        ShortcutManagerCompat.reportShortcutUsed(context, shortcutId)
      }
    }
    return false
  }

  companion object {
    private const val TAG = "QuickActionsAndroid"
  }
}
