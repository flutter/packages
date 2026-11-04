// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.quickactions

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.ChecksSdkIntAtLeast
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

internal class QuickActions(private val context: Context) : AndroidQuickActionsApi {
  var activity: Activity? = null

  @get:ChecksSdkIntAtLeast(api = Build.VERSION_CODES.N_MR1)
  val isVersionAllowed: Boolean
    // Returns true when running on a version of Android that supports quick actions.
    get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1

  override fun setShortcutItems(
      itemsList: List<ShortcutItemMessage>,
      callback: (Result<Unit>) -> Unit
  ) {
    if (!isVersionAllowed) {
      callback(Result.success(Unit))
      return
    }
    val shortcuts = shortcutItemMessageToShortcutInfo(itemsList)
    val executor = ThreadPoolExecutor(0, 1, 1, TimeUnit.SECONDS, LinkedBlockingQueue())

    executor.execute {
      val result =
          try {
            ShortcutManagerCompat.setDynamicShortcuts(context, shortcuts)
            Result.success(Unit)
          } catch (_: Exception) {
            Result.failure(
                FlutterError(
                    "quick_action_setshortcutitems_failure",
                    "Exception thrown when setting dynamic shortcuts",
                    null))
          }
      callback(result)
    }
  }

  override fun clearShortcutItems() {
    if (!isVersionAllowed) {
      return
    }
    ShortcutManagerCompat.removeAllDynamicShortcuts(context)
  }

  override fun getLaunchAction(): String? {
    if (!isVersionAllowed) {
      return null
    }
    val activity = activity
    if (activity == null) {
      // The engine can run without an attached activity, for instance when it is cached and warmed
      // up by a background service. Nothing launched the app in that case, so there is no launch
      // action to report. Any action that arrives later is reported through the plugin's
      // onNewIntent listener once an activity attaches.
      Log.d(TAG, "There is no activity available when getting the launch action.")
      return null
    }
    val intent = activity.intent ?: return null
    val launchAction = intent.getStringExtra(EXTRA_ACTION)
    if (!launchAction.isNullOrEmpty()) {
      ShortcutManagerCompat.reportShortcutUsed(context, launchAction)
      intent.removeExtra(EXTRA_ACTION)
    }
    return launchAction
  }

  @SuppressLint("UseRequiresApi")
  @TargetApi(Build.VERSION_CODES.N_MR1)
  private fun shortcutItemMessageToShortcutInfo(
      shortcuts: List<ShortcutItemMessage>
  ): List<ShortcutInfoCompat> {
    return shortcuts.mapNotNull { shortcut ->
      val type = shortcut.type
      val title = shortcut.localizedTitle
      val intent = getIntentToOpenMainActivity(type)
      if (intent == null) {
        Log.d(TAG, "No intent found for $title")
        return@mapNotNull null
      }

      ShortcutInfoCompat.Builder(context, type)
          .apply {
            val resourceId = loadResourceId(shortcut.icon)
            if (resourceId > 0) {
              setIcon(IconCompat.createWithResource(context, resourceId))
            }
            setLongLabel(title)
            setShortLabel(title)
            setIntent(intent).build()
          }
          .build()
    }
  }

  // This method requires doing dynamic resource lookup, which is a discouraged API.
  @Suppress("DiscouragedApi")
  private fun loadResourceId(icon: String?): Int {
    if (icon == null) {
      return 0
    }
    val packageName = context.packageName
    val res = context.resources
    val resourceId = res.getIdentifier(icon, "drawable", packageName)

    return if (resourceId == 0) {
      res.getIdentifier(icon, "mipmap", packageName)
    } else {
      resourceId
    }
  }

  private fun getIntentToOpenMainActivity(type: String): Intent? {
    val packageName = context.packageName

    return context.packageManager
        .getLaunchIntentForPackage(packageName)
        ?.setAction(Intent.ACTION_RUN)
        ?.putExtra(EXTRA_ACTION, type)
        ?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        ?.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
  }

  companion object {
    private const val TAG = "QuickActionsAndroid"
    const val EXTRA_ACTION = "some unique action key"
  }
}
