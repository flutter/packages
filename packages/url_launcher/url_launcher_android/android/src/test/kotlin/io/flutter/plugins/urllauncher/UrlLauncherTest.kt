// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.urllauncher

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Browser
import androidx.browser.customtabs.CustomTabsIntent
import androidx.test.core.app.ApplicationProvider
import io.flutter.plugins.urllauncher.UrlLauncher.IntentResolver
import org.junit.Assert
import org.junit.Test
import org.junit.function.ThrowingRunnable
import org.junit.runner.RunWith
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class UrlLauncherTest {
  @Test
  fun canLaunch_createsIntentWithPassedUrl() {
    val resolver = Mockito.mock<IntentResolver>(IntentResolver::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>(), resolver)
    val url = Uri.parse("https://flutter.dev")
    Mockito.`when`<String?>(resolver.getHandlerComponentName(ArgumentMatchers.any<Intent?>()))
        .thenReturn(null)

    api.canLaunchUrl(url.toString())

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<IntentResolver?>(resolver).getHandlerComponentName(intentCaptor.capture()!!)
    Assert.assertEquals(url, intentCaptor.getValue()!!.getData())
  }

  @Test
  fun canLaunch_returnsTrue() {
    val api =
        UrlLauncher(
            ApplicationProvider.getApplicationContext<Context?>(),
            IntentResolver { intent: Intent? -> "some.component" })

    val result = api.canLaunchUrl("https://flutter.dev")

    Assert.assertTrue(result)
  }

  @Test
  fun canLaunch_returnsFalse() {
    val api =
        UrlLauncher(
            ApplicationProvider.getApplicationContext<Context?>(),
            IntentResolver { intent: Intent? -> null })

    val result = api.canLaunchUrl("https://flutter.dev")

    Assert.assertFalse(result)
  }

  // Integration testing on emulators won't work as expected without the workaround this tests
  // for, since it will be returned even for intentionally bogus schemes.
  @Test
  fun canLaunch_returnsFalseForEmulatorFallbackComponent() {
    val api =
        UrlLauncher(
            ApplicationProvider.getApplicationContext<Context?>(),
            IntentResolver { intent: Intent? ->
              "{com.android.fallback/com.android.fallback.Fallback}"
            })

    val result = api.canLaunchUrl("https://flutter.dev")

    Assert.assertFalse(result)
  }

  @Test
  fun launch_throwsForNoCurrentActivity() {
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(null)

    val exception =
        Assert.assertThrows<FlutterError>(
            FlutterError::class.java,
            ThrowingRunnable {
              api.launchUrl("https://flutter.dev", HashMap<String?, String?>(), false)
            })
    Assert.assertEquals("NO_ACTIVITY", exception.code)
  }

  @Test
  fun launch_createsIntentWithPassedUrl() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val url = "https://flutter.dev"
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    Mockito.doThrow(ActivityNotFoundException())
        .`when`<Activity?>(activity)
        .startActivity(ArgumentMatchers.any<Intent?>())

    api.launchUrl("https://flutter.dev", HashMap<String?, String?>(), false)

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(url, intentCaptor.getValue()!!.getData().toString())
    Assert.assertEquals(
        0,
        (intentCaptor.getValue()!!.getFlags() and Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER)
            .toLong())
  }

  @Config(minSdk = 30)
  @Test
  fun launch_setsRequireNonBrowserWhenRequested() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    Mockito.doThrow(ActivityNotFoundException())
        .`when`<Activity?>(activity)
        .startActivity(ArgumentMatchers.any<Intent?>())

    api.launchUrl("https://flutter.dev", HashMap<String?, String?>(), true)

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(
        Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER.toLong(),
        (intentCaptor.getValue()!!.getFlags() and Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER)
            .toLong())
  }

  @Test
  fun launch_returnsFalse() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    Mockito.doThrow(ActivityNotFoundException())
        .`when`<Activity?>(activity)
        .startActivity(ArgumentMatchers.any<Intent?>())

    val result = api.launchUrl("https://flutter.dev", HashMap<String?, String?>(), false)

    Assert.assertFalse(result)
  }

  @Test
  fun launch_returnsTrue() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)

    val result = api.launchUrl("https://flutter.dev", HashMap<String?, String?>(), false)

    Assert.assertTrue(result)
  }

  @Test
  fun openUrlInApp_opensUrlInWebViewIfNecessary() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val enableJavaScript = false
    val enableDomStorage = false
    val headers = HashMap<String?, String?>()
    headers.put("key", "value")
    val showTitle = false

    val result =
        api.openUrlInApp(
            url,
            true,
            WebViewOptions(enableJavaScript, enableDomStorage, headers),
            BrowserOptions(showTitle))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    Assert.assertTrue(result)
    Assert.assertEquals(
        url, intentCaptor.getValue()!!.getExtras()!!.getString(WebViewActivity.URL_EXTRA))
    Assert.assertEquals(
        enableJavaScript,
        intentCaptor.getValue()!!.getExtras()!!.getBoolean(WebViewActivity.ENABLE_JS_EXTRA))
    Assert.assertEquals(
        enableDomStorage,
        intentCaptor.getValue()!!.getExtras()!!.getBoolean(WebViewActivity.ENABLE_DOM_EXTRA))
  }

  @Test
  fun openWebView_opensUrlInWebViewIfRequested() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val url = "https://flutter.dev"

    val result =
        api.openUrlInApp(
            url,
            false,
            WebViewOptions(false, false, HashMap<String?, String?>()),
            BrowserOptions(true))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    Assert.assertTrue(result)
    Assert.assertEquals(
        url, intentCaptor.getValue()!!.getExtras()!!.getString(WebViewActivity.URL_EXTRA))
  }

  @Test
  fun openWebView_opensUrlInCustomTabs() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val url = "https://flutter.dev"

    val result =
        api.openUrlInApp(
            url,
            true,
            WebViewOptions(false, false, HashMap<String?, String?>()),
            BrowserOptions(false))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity)
        .startActivity(intentCaptor.capture(), ArgumentMatchers.any<Bundle?>())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue()!!.getAction())
    Assert.assertNull(intentCaptor.getValue()!!.getComponent())
  }

  @Test
  fun openWebView_opensUrlInCustomTabsWithCORSAllowedHeader() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val headers = HashMap<String?, String?>()
    val headerKey = "Content-Type"
    headers.put(headerKey, "text/plain")

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, headers), BrowserOptions(false))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity)
        .startActivity(intentCaptor.capture(), ArgumentMatchers.any<Bundle?>())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue()!!.getAction())
    Assert.assertNull(intentCaptor.getValue()!!.getComponent())
    val passedHeaders = intentCaptor.getValue()!!.getExtras()!!.getBundle(Browser.EXTRA_HEADERS)
    Assert.assertEquals(headers.get(headerKey), passedHeaders!!.getString(headerKey))
  }

  @Test
  fun openWebView_opensUrlInCustomTabsWithShowTitle() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val headers = HashMap<String?, String?>()

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, headers), BrowserOptions(true))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity)
        .startActivity(intentCaptor.capture(), ArgumentMatchers.any<Bundle?>())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue()!!.getAction())
    Assert.assertNull(intentCaptor.getValue()!!.getComponent())
    Assert.assertEquals(
        CustomTabsIntent.SHOW_PAGE_TITLE.toLong(),
        intentCaptor
            .getValue()!!
            .getExtras()!!
            .getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE)
            .toLong())
  }

  @Test
  fun openWebView_opensUrlInCustomTabsWithoutShowTitle() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    val headers = HashMap<String?, String?>()

    val result =
        api.openUrlInApp(url, true, WebViewOptions(false, false, headers), BrowserOptions(false))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity)
        .startActivity(intentCaptor.capture(), ArgumentMatchers.any<Bundle?>())
    Assert.assertTrue(result)
    Assert.assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue()!!.getAction())
    Assert.assertNull(intentCaptor.getValue()!!.getComponent())
    Assert.assertEquals(
        CustomTabsIntent.NO_TITLE.toLong(),
        intentCaptor
            .getValue()!!
            .getExtras()!!
            .getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE)
            .toLong())
  }

  @Test
  fun openWebView_fallsBackToWebViewIfCustomTabFails() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val url = "https://flutter.dev"
    Mockito.doThrow(ActivityNotFoundException())
        .`when`<Activity?>(activity)
        .startActivity(
            ArgumentMatchers.any<Intent?>(),
            ArgumentMatchers.any<Bundle?>()) // for custom tabs intent

    val result =
        api.openUrlInApp(
            url,
            true,
            WebViewOptions(false, false, HashMap<String?, String?>()),
            BrowserOptions(false))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    Assert.assertTrue(result)
    Assert.assertEquals(
        url, intentCaptor.getValue()!!.getExtras()!!.getString(WebViewActivity.URL_EXTRA))
    Assert.assertFalse(
        intentCaptor.getValue()!!.getExtras()!!.getBoolean(WebViewActivity.ENABLE_JS_EXTRA))
    Assert.assertFalse(
        intentCaptor.getValue()!!.getExtras()!!.getBoolean(WebViewActivity.ENABLE_DOM_EXTRA))
  }

  @Test
  fun openWebView_handlesEnableJavaScript() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val enableJavaScript = true
    val headers = HashMap<String?, String?>()
    headers.put("key", "value")

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        WebViewOptions(enableJavaScript, false, headers),
        BrowserOptions(false))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(
        enableJavaScript,
        intentCaptor.getValue()!!.getExtras()!!.getBoolean(WebViewActivity.ENABLE_JS_EXTRA))
  }

  @Test
  fun openWebView_handlesHeaders() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val headers = HashMap<String?, String?>()
    val key1 = "key"
    val key2 = "key2"
    headers.put(key1, "value")
    headers.put(key2, "value2")

    api.openUrlInApp(
        "https://flutter.dev", true, WebViewOptions(false, false, headers), BrowserOptions(false))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    val passedHeaders = intentCaptor.getValue()!!.getExtras()!!.getBundle(Browser.EXTRA_HEADERS)
    Assert.assertEquals(headers.size.toLong(), passedHeaders!!.size().toLong())
    Assert.assertEquals(headers.get(key1), passedHeaders.getString(key1))
    Assert.assertEquals(headers.get(key2), passedHeaders.getString(key2))
  }

  @Test
  fun openWebView_handlesEnableDomStorage() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val enableDomStorage = true
    val headers = HashMap<String?, String?>()
    headers.put("key", "value")

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        WebViewOptions(false, enableDomStorage, headers),
        BrowserOptions(false))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity).startActivity(intentCaptor.capture())
    Assert.assertEquals(
        enableDomStorage,
        intentCaptor.getValue()!!.getExtras()!!.getBoolean(WebViewActivity.ENABLE_DOM_EXTRA))
  }

  @Test
  fun openWebView_handlesEnableShowTitle() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    val enableDomStorage = true
    val headers = HashMap<String?, String?>()
    val showTitle = true

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        WebViewOptions(false, enableDomStorage, headers),
        BrowserOptions(showTitle))

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Activity?>(activity)
        .startActivity(intentCaptor.capture(), ArgumentMatchers.any<Bundle?>())

    Assert.assertEquals(
        CustomTabsIntent.SHOW_PAGE_TITLE.toLong(),
        intentCaptor
            .getValue()!!
            .getExtras()!!
            .getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE)
            .toLong())
  }

  @Test
  fun openWebView_throwsForNoCurrentActivity() {
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(null)

    val exception =
        Assert.assertThrows<FlutterError>(
            FlutterError::class.java,
            ThrowingRunnable {
              api.openUrlInApp(
                  "https://flutter.dev",
                  true,
                  WebViewOptions(false, false, HashMap<String?, String?>()),
                  BrowserOptions(false))
            })
    Assert.assertEquals("NO_ACTIVITY", exception.code)
  }

  @Test
  fun openWebView_returnsFalse() {
    val activity = Mockito.mock<Activity?>(Activity::class.java)
    val api = UrlLauncher(ApplicationProvider.getApplicationContext<Context?>())
    api.setActivity(activity)
    Mockito.doThrow(ActivityNotFoundException())
        .`when`<Activity?>(activity)
        .startActivity(
            ArgumentMatchers.any<Intent?>(),
            ArgumentMatchers.any<Bundle?>()) // for custom tabs intent
    Mockito.doThrow(ActivityNotFoundException())
        .`when`<Activity?>(activity)
        .startActivity(ArgumentMatchers.any<Intent?>()) // for webview intent

    val result =
        api.openUrlInApp(
            "https://flutter.dev",
            true,
            WebViewOptions(false, false, HashMap<String?, String?>()),
            BrowserOptions(false))

    Assert.assertFalse(result)
  }

  @Test
  fun closeWebView_closes() {
    val context = Mockito.mock<Context>(Context::class.java)
    val api = UrlLauncher(context)

    api.closeWebView()

    val intentCaptor = ArgumentCaptor.forClass<Intent?, Intent?>(Intent::class.java)
    Mockito.verify<Context?>(context).sendBroadcast(intentCaptor.capture())
    Assert.assertEquals(WebViewActivity.ACTION_CLOSE, intentCaptor.getValue()!!.getAction())
  }
}
