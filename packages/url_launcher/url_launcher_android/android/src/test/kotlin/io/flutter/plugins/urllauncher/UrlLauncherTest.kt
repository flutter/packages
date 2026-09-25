// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.urllauncher

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Browser
import androidx.browser.customtabs.CustomTabsIntent
import androidx.test.core.app.ApplicationProvider
import io.flutter.plugins.urllauncher.UrlLauncher.IntentResolver
import org.junit.Assert
import org.junit.Test
import org.junit.function.ThrowingRunnable
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.doThrow
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class UrlLauncherTest {
  @Test
  fun canLaunch_createsIntentWithPassedUrl() {
    val resolver = mock<IntentResolver>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext(), resolver)
    val url = Uri.parse("https://flutter.dev")
    whenever(resolver.getHandlerComponentName(any())).thenReturn(null)

    api.canLaunchUrl(url.toString())

    val intentCaptor = argumentCaptor<Intent>()
    verify(resolver).getHandlerComponentName(intentCaptor.capture())
    Assert.assertEquals(url, intentCaptor.firstValue.data)
  }

  @Test
  fun canLaunch_returnsTrue() {
    val api =
        UrlLauncher(
            ApplicationProvider.getApplicationContext(),
            IntentResolver { intent: Intent? -> "some.component" })

    val result = api.canLaunchUrl("https://flutter.dev")

    Assert.assertTrue(result)
  }

  @Test
  fun canLaunch_returnsFalse() {
    val api =
        UrlLauncher(
            ApplicationProvider.getApplicationContext(), IntentResolver { intent: Intent? -> null })

    val result = api.canLaunchUrl("https://flutter.dev")

    Assert.assertFalse(result)
  }

  // Integration testing on emulators won't work as expected without the workaround this tests
  // for, since it will be returned even for intentionally bogus schemes.
  @Test
  fun canLaunch_returnsFalseForEmulatorFallbackComponent() {
    val api =
        UrlLauncher(
            ApplicationProvider.getApplicationContext(),
            IntentResolver { intent: Intent? ->
              "{com.android.fallback/com.android.fallback.Fallback}"
            })

    val result = api.canLaunchUrl("https://flutter.dev")

    Assert.assertFalse(result)
  }

  @Test
  fun launch_throwsForNoCurrentActivity() {
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(null)

    val exception =
        Assert.assertThrows(
            FlutterError::class.java,
            ThrowingRunnable { api.launchUrl("https://flutter.dev", mapOf(), false) })
    Assert.assertEquals("NO_ACTIVITY", exception.code)
  }

  @Test
  fun launch_createsIntentWithPassedUrl() {
    val activity = mock<Activity>()
    val url = "https://flutter.dev"
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    doThrow(ActivityNotFoundException()).whenever(activity).startActivity(any())

    api.launchUrl("https://flutter.dev", mapOf(), false)

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(url, intentCaptor.firstValue.getData().toString())
    Assert.assertEquals(
        0,
        (intentCaptor.firstValue.getFlags() and Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER).toLong())
  }

  @Config(minSdk = 30)
  @Test
  fun launch_setsRequireNonBrowserWhenRequested() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    doThrow(ActivityNotFoundException()).whenever(activity).startActivity(any())

    api.launchUrl("https://flutter.dev", mapOf(), true)

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(
        Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER.toLong(),
        (intentCaptor.firstValue.getFlags() and Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER).toLong())
  }

  @Test
  fun launch_returnsFalse() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    doThrow(ActivityNotFoundException()).whenever(activity).startActivity(any())

    val result = api.launchUrl("https://flutter.dev", mapOf(), false)

    Assert.assertFalse(result)
  }

  @Test
  fun launch_returnsTrue() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)

    val result = api.launchUrl("https://flutter.dev", mapOf(), false)

    Assert.assertTrue(result)
  }

  @Test
  fun openUrlInApp_opensUrlInWebViewIfNecessary() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val enableJavaScript = false
    val enableDomStorage = false
    val headers = mapOf("key" to "value")
    val showTitle = false

    val result =
        api.openUrlInApp(
            url,
            true,
            WebViewOptions(enableJavaScript, enableDomStorage, headers),
            BrowserOptions(showTitle))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    Assert.assertTrue(result)
    Assert.assertEquals(
        url, intentCaptor.firstValue.getExtras()!!.getString(WebViewActivity.URL_EXTRA))
    Assert.assertEquals(
        enableJavaScript,
        intentCaptor.firstValue.getExtras()!!.getBoolean(WebViewActivity.ENABLE_JS_EXTRA))
    Assert.assertEquals(
        enableDomStorage,
        intentCaptor.firstValue.getExtras()!!.getBoolean(WebViewActivity.ENABLE_DOM_EXTRA))
  }

  @Test
  fun openWebView_opensUrlInWebViewIfRequested() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val url = "https://flutter.dev"

    val result =
        api.openUrlInApp(url, false, WebViewOptions(false, false, mapOf()), BrowserOptions(true))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    Assert.assertTrue(result)
    Assert.assertEquals(
        url, intentCaptor.firstValue.getExtras()!!.getString(WebViewActivity.URL_EXTRA))
  }

  @Test
  fun openWebView_opensUrlInCustomTabs() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val url = "https://flutter.dev"

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, mapOf()), BrowserOptions(false))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture(), any())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.firstValue.getAction())
    Assert.assertNull(intentCaptor.firstValue.getComponent())
  }

  @Test
  fun openWebView_opensUrlInCustomTabsWithCORSAllowedHeader() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val headerKey = "Content-Type"
    val headers = mapOf(headerKey to "text/plain")

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, headers), BrowserOptions(false))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture(), any())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.firstValue.getAction())
    Assert.assertNull(intentCaptor.firstValue.getComponent())
    val passedHeaders = intentCaptor.firstValue.getExtras()!!.getBundle(Browser.EXTRA_HEADERS)
    Assert.assertEquals(headers.get(headerKey), passedHeaders!!.getString(headerKey))
  }

  @Test
  fun openWebView_opensUrlInCustomTabsWithShowTitle() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val headers = mapOf<String, String>()

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, headers), BrowserOptions(true))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture(), any())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.firstValue.getAction())
    Assert.assertNull(intentCaptor.firstValue.getComponent())
    Assert.assertEquals(
        CustomTabsIntent.SHOW_PAGE_TITLE.toLong(),
        intentCaptor.firstValue
            .getExtras()!!
            .getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE)
            .toLong())
  }

  @Test
  fun openWebView_opensUrlInCustomTabsWithoutShowTitle() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val headers = mapOf<String, String>()

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, headers), BrowserOptions(false))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture(), any())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.firstValue.getAction())
    Assert.assertNull(intentCaptor.firstValue.getComponent())
    Assert.assertEquals(
        CustomTabsIntent.NO_TITLE.toLong(),
        intentCaptor.firstValue
            .getExtras()!!
            .getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE)
            .toLong())
  }

  @Test
  fun openWebView_fallsBackToWebViewIfCustomTabFails() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    doThrow(ActivityNotFoundException())
        .whenever(activity)
        .startActivity(any(), any()) // for custom tabs intent

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, mapOf()), BrowserOptions(false))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    Assert.assertTrue(result)
    Assert.assertEquals(
        url, intentCaptor.firstValue.getExtras()!!.getString(WebViewActivity.URL_EXTRA))
    Assert.assertFalse(
        intentCaptor.firstValue.getExtras()!!.getBoolean(WebViewActivity.ENABLE_JS_EXTRA))
    Assert.assertFalse(
        intentCaptor.firstValue.getExtras()!!.getBoolean(WebViewActivity.ENABLE_DOM_EXTRA))
  }

  @Test
  fun openWebView_handlesEnableJavaScript() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val enableJavaScript = true
    val headers = mapOf("key" to "value")

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        WebViewOptions(enableJavaScript, false, headers),
        BrowserOptions(false))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(
        enableJavaScript,
        intentCaptor.firstValue.getExtras()!!.getBoolean(WebViewActivity.ENABLE_JS_EXTRA))
  }

  @Test
  fun openWebView_handlesHeaders() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val key1 = "key"
    val key2 = "key2"
    val headers = mapOf(key1 to "value", key2 to "value2")

    api.openUrlInApp(
        "https://flutter.dev", true, WebViewOptions(false, false, headers), BrowserOptions(false))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    val passedHeaders = intentCaptor.firstValue.getExtras()!!.getBundle(Browser.EXTRA_HEADERS)
    Assert.assertEquals(headers.size.toLong(), passedHeaders!!.size().toLong())
    Assert.assertEquals(headers.get(key1), passedHeaders.getString(key1))
    Assert.assertEquals(headers.get(key2), passedHeaders.getString(key2))
  }

  @Test
  fun openWebView_handlesEnableDomStorage() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val enableDomStorage = true
    val headers = mapOf("key" to "value")

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        WebViewOptions(false, enableDomStorage, headers),
        BrowserOptions(false))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(
        enableDomStorage,
        intentCaptor.firstValue.getExtras()!!.getBoolean(WebViewActivity.ENABLE_DOM_EXTRA))
  }

  @Test
  fun openWebView_handlesEnableShowTitle() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    val enableDomStorage = true
    val headers = mapOf<String, String>()
    val showTitle = true

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        WebViewOptions(false, enableDomStorage, headers),
        BrowserOptions(showTitle))

    val intentCaptor = argumentCaptor<Intent>()
    verify(activity).startActivity(intentCaptor.capture(), any())

    Assert.assertEquals(
        CustomTabsIntent.SHOW_PAGE_TITLE.toLong(),
        intentCaptor.firstValue
            .getExtras()!!
            .getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE)
            .toLong())
  }

  @Test
  fun openWebView_throwsForNoCurrentActivity() {
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(null)

    val exception =
        Assert.assertThrows(
            FlutterError::class.java,
            ThrowingRunnable {
              api.openUrlInApp(
                  "https://flutter.dev",
                  true,
                  WebViewOptions(false, false, mapOf()),
                  BrowserOptions(false))
            })
    Assert.assertEquals("NO_ACTIVITY", exception.code)
  }

  @Test
  fun openWebView_returnsFalse() {
    val activity = mock<Activity>()
    val api = UrlLauncher(ApplicationProvider.getApplicationContext())
    api.setActivity(activity)
    doThrow(ActivityNotFoundException())
        .whenever(activity)
        .startActivity(any(), any()) // for custom tabs intent
    doThrow(ActivityNotFoundException())
        .whenever(activity)
        .startActivity(any()) // for webview intent

    val result =
        api.openUrlInApp(
            "https://flutter.dev",
            true,
            WebViewOptions(false, false, mapOf()),
            BrowserOptions(false))

    Assert.assertFalse(result)
  }

  @Test
  fun closeWebView_closes() {
    val context = mock<Context>()
    val api = UrlLauncher(context)

    api.closeWebView()

    val intentCaptor = argumentCaptor<Intent>()
    verify(context).sendBroadcast(intentCaptor.capture())
    Assert.assertEquals(WebViewActivity.ACTION_CLOSE, intentCaptor.firstValue.getAction())
  }
}
