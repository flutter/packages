// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.quickactions

import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.ChecksSdkIntAtLeast
import androidx.annotation.VisibleForTesting
import androidx.core.content.pm.ShortcutManagerCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import io.flutter.plugins.quickactions.AndroidQuickActionsApi.Companion.setUp

/** QuickActionsPlugin  */
class QuickActionsPlugin @VisibleForTesting internal constructor(private val sdkChecker: AndroidSdkChecker) :
    FlutterPlugin, ActivityAware, NewIntentListener {
    private var quickActions: QuickActions? = null
    private var quickActionsFlutterApi: AndroidQuickActionsFlutterApi? = null

    // Interface for an injectable SDK version checker.
    @VisibleForTesting
    internal interface AndroidSdkChecker {
        @ChecksSdkIntAtLeast(parameter = 0)
        fun sdkIsAtLeast(version: Int): Boolean
    }

    constructor() : this(AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        this.quickActions = QuickActions(binding.getApplicationContext())
        setUp(binding.getBinaryMessenger(), quickActions)
        this.quickActionsFlutterApi =
            AndroidQuickActionsFlutterApi(binding.getBinaryMessenger(), "")
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        setUp(binding.getBinaryMessenger(), null)
        this.quickActions = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (this.quickActions == null) {
            Log.wtf(TAG, "quickActions was never set.")
            return
        }

        val activity = binding.getActivity()
        this.quickActions!!.activity = activity
        binding.addOnNewIntentListener(this)
        onNewIntent(activity.getIntent())
    }

    override fun onDetachedFromActivity() {
        quickActions!!.activity = null
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
        if (!sdkChecker.sdkIsAtLeast(Build.VERSION_CODES.N_MR1)) {
            return false
        }
        val activity = this.quickActions!!.activity
        // Notify the Dart side if the launch intent has the intent extra relevant to quick actions.
        if (intent.hasExtra(QuickActions.EXTRA_ACTION) && activity != null) {
            val context = activity.getApplicationContext()
            val shortcutId = intent.getStringExtra(QuickActions.EXTRA_ACTION)
            if (shortcutId != null) {
                quickActionsFlutterApi!!.launchAction(
                    shortcutId,
                    ResultCompat.asCompatCallback<Unit> { result: ResultCompat<Unit?>? ->
                        val error = result!!.exceptionOrNull()
                        if (error != null) {
                            Log.e(TAG, "Failed to handle launch action: " + error.message)
                        }
                        Unit
                    })
                ShortcutManagerCompat.reportShortcutUsed(context, shortcutId)
            }
        }
        return false
    }

    companion object {
        private const val TAG = "QuickActionsAndroid"
    }
}
