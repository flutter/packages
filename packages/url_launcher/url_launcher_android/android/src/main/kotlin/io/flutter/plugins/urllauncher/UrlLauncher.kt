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
import androidx.core.net.toUri
import java.util.Locale

/** Implements the Pigeon-defined interface for calls from Dart. */
internal class UrlLauncher
/**
 * Creates an instance that uses `intentResolver` to look up the handler for intents. This is to
 * allow injecting an alternate resolver for unit testing.
 */
@VisibleForTesting
constructor(
    private val applicationContext: Context,
    private val getHandlerComponentName: (Intent) -> String?
) : UrlLauncherApi {

  private var activity: Activity? = null

  constructor(
      context: Context
  ) : this(context, { intent -> intent.resolveActivity(context.packageManager)?.toShortString() })

  fun setActivity(activity: Activity?) {
    this.activity = activity
  }

  override fun canLaunchUrl(url: String): Boolean {
    val launchIntent = Intent(Intent.ACTION_VIEW, url.toUri())
    val componentName = getHandlerComponentName(launchIntent)
    if (BuildConfig.DEBUG) {
      Log.i(TAG, "component name for $url is $componentName")
    }
    return componentName != null &&
        // Ignore the emulator fallback activity.
        componentName != "{com.android.fallback/com.android.fallback.Fallback}"
  }

  override fun launchUrl(
      url: String,
      headers: Map<String, String>,
      requireNonBrowser: Boolean
  ): Boolean {
    val activity = ensureActivity()

    val launchIntent: Intent =
        Intent(Intent.ACTION_VIEW, url.toUri()).apply {
          putExtra(Browser.EXTRA_HEADERS, extractBundle(headers))
          if (requireNonBrowser && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            addFlags(Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER)
          }
        }
    return try {
      activity.startActivity(launchIntent)
      true
    } catch (_: ActivityNotFoundException) {
      false
    }
  }

  override fun openUrlInApp(
      url: String,
      allowCustomTab: Boolean,
      webViewOptions: WebViewOptions,
      browserOptions: BrowserOptions
  ): Boolean {
    val activity = ensureActivity()

    val headersBundle: Bundle = extractBundle(webViewOptions.headers)

    // Try to launch using Custom Tabs if they have the necessary functionality, unless the caller
    // specifically requested a web view.
    if (allowCustomTab && !containsRestrictedHeader(webViewOptions.headers)) {
      if (openCustomTab(activity, url.toUri(), headersBundle, browserOptions)) {
        return true
      }
    }

    // Fall back to a web view if necessary.
    val launchIntent =
        WebViewActivity.createIntent(
            activity,
            url,
            webViewOptions.enableJavaScript,
            webViewOptions.enableDomStorage,
            headersBundle)
    try {
      activity.startActivity(launchIntent)
    } catch (_: ActivityNotFoundException) {
      return false
    }

    return true
  }

  override fun closeWebView() {
    applicationContext.sendBroadcast(Intent(WebViewActivity.ACTION_CLOSE))
  }

  override fun supportsCustomTabs(): Boolean {
    return CustomTabsClient.getPackageName(applicationContext, emptyList()) != null
  }

  private fun ensureActivity(): Activity {
    return activity
        ?: throw FlutterError(
            "NO_ACTIVITY", "Launching a URL requires a foreground activity.", null)
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
      } catch (_: ActivityNotFoundException) {
        return false
      }
      return true
    }

    private val CORS_SAFELISTED_HEADERS =
        setOf("accept", "accept-language", "content-language", "content-type")

    // Checks if headers contains a CORS restricted header.
    //  https://developer.mozilla.org/en-US/docs/Glossary/CORS-safelisted_request_header
    private fun containsRestrictedHeader(headersMap: Map<String, String>): Boolean {
      return headersMap.keys.any { it.lowercase(Locale.US) !in CORS_SAFELISTED_HEADERS }
    }

    private fun extractBundle(headersMap: Map<String, String>): Bundle {
      return Bundle().apply { headersMap.forEach { (key, value) -> putString(key, value) } }
    }
  }
}
