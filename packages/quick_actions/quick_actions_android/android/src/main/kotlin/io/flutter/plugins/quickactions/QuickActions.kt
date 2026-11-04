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
import kotlin.jvm.functions.Function1

internal class QuickActions(private val context: Context) : AndroidQuickActionsApi {
  var activity: Activity? = null

  @get:ChecksSdkIntAtLeast(api = Build.VERSION_CODES.N_MR1)
  val isVersionAllowed: Boolean
    // Returns true when running on a version of Android that supports quick actions.
    get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1

  override fun setShortcutItems(
      itemsList: MutableList<ShortcutItemMessage>,
      callback: Function1<in Result<Unit>, Unit>
  ) {
    if (!this.isVersionAllowed) {
      callback(Result.success(Unit))
      return
    }
    val shortcuts = shortcutItemMessageToShortcutInfo(itemsList)
    val executor = ThreadPoolExecutor(0, 1, 1, TimeUnit.SECONDS, LinkedBlockingQueue<Runnable?>())

    executor.execute(
        Runnable {
          var dynamicShortcutsSet = false
          try {
            ShortcutManagerCompat.setDynamicShortcuts(context, shortcuts)
            dynamicShortcutsSet = true
          } catch (e: Exception) {
            // Leave dynamicShortcutsSet as false
          }
          if (dynamicShortcutsSet) {
            callback(Result.success(Unit))
          } else {
            callback(
                Result.failure(
                    FlutterError(
                        "quick_action_setshortcutitems_failure",
                        "Exception thrown when setting dynamic shortcuts",
                        null)))
          }
        })
  }

  override fun clearShortcutItems() {
    if (!this.isVersionAllowed) {
      return
    }
    ShortcutManagerCompat.removeAllDynamicShortcuts(context)
  }

  override fun getLaunchAction(): String? {
    if (!this.isVersionAllowed) {
      return null
    }
    if (activity == null) {
      // The engine can run without an attached activity, for instance when it is cached and warmed
      // up by a background service. Nothing launched the app in that case, so there is no launch
      // action to report. Any action that arrives later is reported through the plugin's
      // onNewIntent listener once an activity attaches.
      Log.d(TAG, "There is no activity available when getting the launch action.")
      return null
    }
    val intent = activity!!.getIntent()
    val launchAction = intent.getStringExtra(EXTRA_ACTION)
    if (launchAction != null && !launchAction.isEmpty()) {
      ShortcutManagerCompat.reportShortcutUsed(context, launchAction)
      intent.removeExtra(EXTRA_ACTION)
    }
    return launchAction
  }

  @SuppressLint("UseRequiresApi")
  @TargetApi(Build.VERSION_CODES.N_MR1)
  private fun shortcutItemMessageToShortcutInfo(
      shortcuts: MutableList<ShortcutItemMessage>
  ): MutableList<ShortcutInfoCompat?> {
    val shortcutInfos: MutableList<ShortcutInfoCompat?> = ArrayList<ShortcutInfoCompat?>()

    for (shortcut in shortcuts) {
      val icon = shortcut.icon
      val type = shortcut.type
      val title = shortcut.localizedTitle
      val shortcutBuilder = ShortcutInfoCompat.Builder(context, type)

      val resourceId = loadResourceId(context, icon)
      val intent = getIntentToOpenMainActivity(type)

      if (resourceId > 0) {
        shortcutBuilder.setIcon(IconCompat.createWithResource(context, resourceId))
      }

      val shortcutInfo =
          shortcutBuilder.setLongLabel(title).setShortLabel(title).setIntent(intent).build()
      shortcutInfos.add(shortcutInfo)
    }
    return shortcutInfos
  }

  // This method requires doing dynamic resource lookup, which is a discouraged API.
  private fun loadResourceId(context: Context, icon: String?): Int {
    if (icon == null) {
      return 0
    }
    val packageName = context.getPackageName()
    val res = context.getResources()
    val resourceId = res.getIdentifier(icon, "drawable", packageName)

    if (resourceId == 0) {
      return res.getIdentifier(icon, "mipmap", packageName)
    } else {
      return resourceId
    }
  }

  private fun getIntentToOpenMainActivity(type: String?): Intent {
    val packageName = context.getPackageName()

    return context
        .getPackageManager()
        .getLaunchIntentForPackage(packageName)!!
        .setAction(Intent.ACTION_RUN)
        .putExtra(EXTRA_ACTION, type)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
  }

  companion object {
    private const val TAG = "QuickActionsAndroid"
    const val EXTRA_ACTION: String = "some unique action key"
  }
}
