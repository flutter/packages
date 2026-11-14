// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.urllauncher

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Browser
import android.util.Log
import androidx.annotation.VisibleForTesting
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent

/** Implements the Pigeon-defined interface for calls from Dart. */
internal class UrlLauncher
/**
 * Creates an instance that uses `intentResolver` to look up the handler for intents. This is to
 * allow injecting an alternate resolver for unit testing.
 */
@VisibleForTesting
constructor(private val applicationContext: Context, private val intentResolver: IntentResolver) :
    UrlLauncherApi {
  @VisibleForTesting
  internal interface IntentResolver {
    fun getHandlerComponentName(intent: Intent): String?
  }

  private var activity: Activity? = null

  constructor(
      context: Context
  ) : this(
      context,
      IntentResolver { intent: Intent ->
        val componentName = intent.resolveActivity(context.getPackageManager())
        if (componentName == null) null else componentName.toShortString()
      })

  fun setActivity(activity: Activity?) {
    this.activity = activity
  }

  override fun canLaunchUrl(url: String): Boolean {
    val launchIntent = Intent(Intent.ACTION_VIEW)
    launchIntent.setData(Uri.parse(url))
    val componentName = intentResolver.getHandlerComponentName(launchIntent)
    if (BuildConfig.DEBUG) {
      Log.i(TAG, "component name for " + url + " is " + componentName)
    }
    if (componentName == null) {
      return false
    } else {
      // Ignore the emulator fallback activity.
      return "{com.android.fallback/com.android.fallback.Fallback}" != componentName
    }
  }

  override fun launchUrl(
      url: String,
      headers: MutableMap<String, String?>,
      requireNonBrowser: Boolean
  ): Boolean {
    ensureActivity()
    checkNotNull(activity)

    val launchIntent: Intent =
        Intent(Intent.ACTION_VIEW)
            .setData(Uri.parse(url))
            .putExtra(Browser.EXTRA_HEADERS, extractBundle(headers))
    if (requireNonBrowser && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      launchIntent.addFlags(Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER)
    }
    try {
      activity!!.startActivity(launchIntent)
    } catch (e: ActivityNotFoundException) {
      return false
    }

    return true
  }

  override fun openUrlInApp(
      url: String,
      allowCustomTab: Boolean,
      webViewOptions: WebViewOptions,
      browserOptions: BrowserOptions
  ): Boolean {
    ensureActivity()
    checkNotNull(activity)

    val headersBundle: Bundle = Companion.extractBundle(webViewOptions.headers)

    // Try to launch using Custom Tabs if they have the necessary functionality, unless the caller
    // specifically requested a web view.
    if (allowCustomTab && !Companion.containsRestrictedHeader(webViewOptions.headers)) {
      val uri = Uri.parse(url)
      if (Companion.openCustomTab(activity!!, uri, headersBundle, browserOptions)) {
        return true
      }
    }

    // Fall back to a web view if necessary.
    val launchIntent =
        WebViewActivity.createIntent(
            activity!!,
            url,
            webViewOptions.enableJavaScript,
            webViewOptions.enableDomStorage,
            headersBundle)
    try {
      activity!!.startActivity(launchIntent)
    } catch (e: ActivityNotFoundException) {
      return false
    }

    return true
  }

  override fun closeWebView() {
    applicationContext.sendBroadcast(Intent(WebViewActivity.ACTION_CLOSE))
  }

  override fun supportsCustomTabs(): Boolean {
    return CustomTabsClient.getPackageName(applicationContext, mutableListOf<String?>()) != null
  }

  private fun ensureActivity() {
    if (activity == null) {
      throw FlutterError("NO_ACTIVITY", "Launching a URL requires a foreground activity.", null)
    }
  }

  companion object {
    private const val TAG = "UrlLauncher"

    private fun openCustomTab(
        context: Context,
        uri: Uri,
        headersBundle: Bundle,
        options: BrowserOptions
    ): Boolean {
      val customTabsIntent = CustomTabsIntent.Builder().setShowTitle(options.showTitle).build()
      customTabsIntent.intent.putExtra(Browser.EXTRA_HEADERS, headersBundle)

      try {
        customTabsIntent.launchUrl(context, uri)
      } catch (ex: ActivityNotFoundException) {
        return false
      }
      return true
    }

    // Checks if headers contains a CORS restricted header.
    //  https://developer.mozilla.org/en-US/docs/Glossary/CORS-safelisted_request_header
    private fun containsRestrictedHeader(headersMap: MutableMap<String, String?>): Boolean {
      for (key in headersMap.keys) {
        when (key.lowercase()) {
          "accept",
          "accept-language",
          "content-language",
          "content-type" -> continue
          else -> return true
        }
      }
      return false
    }

    private fun extractBundle(headersMap: MutableMap<String, String?>): Bundle {
      val headersBundle = Bundle()
      for (key in headersMap.keys) {
        val value = headersMap.get(key)
        headersBundle.putString(key, value)
      }
      return headersBundle
    }
  }
}
