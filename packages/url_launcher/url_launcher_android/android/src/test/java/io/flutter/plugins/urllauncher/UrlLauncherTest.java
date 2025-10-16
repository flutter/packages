// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Browser;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.test.core.app.ApplicationProvider;
import java.util.HashMap;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class UrlLauncherTest {
  @Test
  public void canLaunch_createsIntentWithPassedUrl() {
    UrlLauncher.IntentResolver resolver = mock(UrlLauncher.IntentResolver.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext(), resolver);
    Uri url = Uri.parse("https://flutter.dev");
    when(resolver.getHandlerComponentName(any())).thenReturn(null);

    api.canLaunchUrl(url.toString());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(resolver).getHandlerComponentName(intentCaptor.capture());
    assertEquals(url, intentCaptor.getValue().getData());
  }

  @Test
  public void canLaunch_returnsTrue() {
    UrlLauncher api =
        new UrlLauncher(ApplicationProvider.getApplicationContext(), intent -> "some.component");

    Boolean result = api.canLaunchUrl("https://flutter.dev");

    assertTrue(result);
  }

  @Test
  public void canLaunch_returnsFalse() {
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext(), intent -> null);

    Boolean result = api.canLaunchUrl("https://flutter.dev");

    assertFalse(result);
  }

  // Integration testing on emulators won't work as expected without the workaround this tests
  // for, since it will be returned even for intentionally bogus schemes.
  @Test
  public void canLaunch_returnsFalseForEmulatorFallbackComponent() {
    UrlLauncher api =
        new UrlLauncher(
            ApplicationProvider.getApplicationContext(),
            intent -> "{com.android.fallback/com.android.fallback.Fallback}");

    Boolean result = api.canLaunchUrl("https://flutter.dev");

    assertFalse(result);
  }

  @Test
  public void launch_throwsForNoCurrentActivity() {
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(null);

    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () -> api.launchUrl("https://flutter.dev", new HashMap<>(), false));
    assertEquals("NO_ACTIVITY", exception.code);
  }

  @Test
  public void launch_createsIntentWithPassedUrl() {
    Activity activity = mock(Activity.class);
    String url = "https://flutter.dev";
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    doThrow(new ActivityNotFoundException()).when(activity).startActivity(any());

    api.launchUrl("https://flutter.dev", new HashMap<>(), false);

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(url, intentCaptor.getValue().getData().toString());
    assertEquals(0, intentCaptor.getValue().getFlags() & Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER);
  }

  @Config(minSdk = 30)
  @Test
  public void launch_setsRequireNonBrowserWhenRequested() {
    Activity activity = mock(Activity.class);
    String url = "https://flutter.dev";
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    doThrow(new ActivityNotFoundException()).when(activity).startActivity(any());

    api.launchUrl("https://flutter.dev", new HashMap<>(), true);

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(
        Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER,
        intentCaptor.getValue().getFlags() & Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER);
  }

  @Test
  public void launch_returnsFalse() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    doThrow(new ActivityNotFoundException()).when(activity).startActivity(any());

    boolean result = api.launchUrl("https://flutter.dev", new HashMap<>(), false);

    assertFalse(result);
  }

  @Test
  public void launch_returnsTrue() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);

    boolean result = api.launchUrl("https://flutter.dev", new HashMap<>(), false);

    assertTrue(result);
  }

  @Test
  public void openUrlInApp_opensUrlInWebViewIfNecessary() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    String url = "https://flutter.dev";
    boolean enableJavaScript = false;
    boolean enableDomStorage = false;
    HashMap<String, String> headers = new HashMap<>();
    headers.put("key", "value");
    boolean showTitle = false;

    boolean result =
        api.openUrlInApp(
            url,
            true,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(enableJavaScript)
                .setEnableDomStorage(enableDomStorage)
                .setHeaders(headers)
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(showTitle).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertTrue(result);
    assertEquals(url, intentCaptor.getValue().getExtras().getString(WebViewActivity.URL_EXTRA));
    assertEquals(
        enableJavaScript,
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_JS_EXTRA));
    assertEquals(
        enableDomStorage,
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_DOM_EXTRA));
  }

  @Test
  public void openWebView_opensUrlInWebViewIfRequested() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    String url = "https://flutter.dev";

    boolean result =
        api.openUrlInApp(
            url,
            false,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(new HashMap<>())
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(true).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertTrue(result);
    assertEquals(url, intentCaptor.getValue().getExtras().getString(WebViewActivity.URL_EXTRA));
  }

  @Test
  public void openWebView_opensUrlInCustomTabs() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    String url = "https://flutter.dev";

    boolean result =
        api.openUrlInApp(
            url,
            true,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(new HashMap<>())
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture(), isNull());
    assertTrue(result);
    assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue().getAction());
    assertNull(intentCaptor.getValue().getComponent());
  }

  @Test
  public void openWebView_opensUrlInCustomTabsWithCORSAllowedHeader() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    String url = "https://flutter.dev";
    HashMap<String, String> headers = new HashMap<>();
    String headerKey = "Content-Type";
    headers.put(headerKey, "text/plain");

    boolean result =
        api.openUrlInApp(
            url,
            true,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(headers)
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture(), isNull());
    assertTrue(result);
    assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue().getAction());
    assertNull(intentCaptor.getValue().getComponent());
    final Bundle passedHeaders =
        intentCaptor.getValue().getExtras().getBundle(Browser.EXTRA_HEADERS);
    assertEquals(headers.get(headerKey), passedHeaders.getString(headerKey));
  }

  @Test
  public void openWebView_opensUrlInCustomTabsWithShowTitle() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    String url = "https://flutter.dev";
    HashMap<String, String> headers = new HashMap<>();

    boolean result =
        api.openUrlInApp(
            url,
            true,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(headers)
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(true).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture(), isNull());
    assertTrue(result);
    assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue().getAction());
    assertNull(intentCaptor.getValue().getComponent());
    assertEquals(
        intentCaptor.getValue().getExtras().getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE),
        CustomTabsIntent.SHOW_PAGE_TITLE);
  }

  @Test
  public void openWebView_opensUrlInCustomTabsWithoutShowTitle() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    String url = "https://flutter.dev";
    HashMap<String, String> headers = new HashMap<>();

    boolean result =
        api.openUrlInApp(
            url,
            true,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(headers)
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture(), isNull());
    assertTrue(result);
    assertEquals(Intent.ACTION_VIEW, intentCaptor.getValue().getAction());
    assertNull(intentCaptor.getValue().getComponent());
    assertEquals(
        intentCaptor.getValue().getExtras().getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE),
        CustomTabsIntent.NO_TITLE);
  }

  @Test
  public void openWebView_fallsBackToWebViewIfCustomTabFails() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    String url = "https://flutter.dev";
    doThrow(new ActivityNotFoundException())
        .when(activity)
        .startActivity(any(), isNull()); // for custom tabs intent

    boolean result =
        api.openUrlInApp(
            url,
            true,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(new HashMap<>())
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertTrue(result);
    assertEquals(url, intentCaptor.getValue().getExtras().getString(WebViewActivity.URL_EXTRA));
    assertEquals(
        false, intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_JS_EXTRA));
    assertEquals(
        false, intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_DOM_EXTRA));
  }

  @Test
  public void openWebView_handlesEnableJavaScript() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    boolean enableJavaScript = true;
    HashMap<String, String> headers = new HashMap<>();
    headers.put("key", "value");

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        new Messages.WebViewOptions.Builder()
            .setEnableJavaScript(enableJavaScript)
            .setEnableDomStorage(false)
            .setHeaders(headers)
            .build(),
        new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(
        enableJavaScript,
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_JS_EXTRA));
  }

  @Test
  public void openWebView_handlesHeaders() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    HashMap<String, String> headers = new HashMap<>();
    final String key1 = "key";
    final String key2 = "key2";
    headers.put(key1, "value");
    headers.put(key2, "value2");

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        new Messages.WebViewOptions.Builder()
            .setEnableJavaScript(false)
            .setEnableDomStorage(false)
            .setHeaders(headers)
            .build(),
        new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    final Bundle passedHeaders =
        intentCaptor.getValue().getExtras().getBundle(Browser.EXTRA_HEADERS);
    assertEquals(headers.size(), passedHeaders.size());
    assertEquals(headers.get(key1), passedHeaders.getString(key1));
    assertEquals(headers.get(key2), passedHeaders.getString(key2));
  }

  @Test
  public void openWebView_handlesEnableDomStorage() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    boolean enableDomStorage = true;
    HashMap<String, String> headers = new HashMap<>();
    headers.put("key", "value");

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        new Messages.WebViewOptions.Builder()
            .setEnableJavaScript(false)
            .setEnableDomStorage(enableDomStorage)
            .setHeaders(headers)
            .build(),
        new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(
        enableDomStorage,
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_DOM_EXTRA));
  }

  @Test
  public void openWebView_handlesEnableShowTitle() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    boolean enableDomStorage = true;
    HashMap<String, String> headers = new HashMap<>();
    boolean showTitle = true;

    api.openUrlInApp(
        "https://flutter.dev",
        true,
        new Messages.WebViewOptions.Builder()
            .setEnableJavaScript(false)
            .setEnableDomStorage(enableDomStorage)
            .setHeaders(headers)
            .build(),
        new Messages.BrowserOptions.Builder().setShowTitle(showTitle).build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture(), isNull());

    assertEquals(
        intentCaptor.getValue().getExtras().getInt(CustomTabsIntent.EXTRA_TITLE_VISIBILITY_STATE),
        CustomTabsIntent.SHOW_PAGE_TITLE);
  }

  @Test
  public void openWebView_throwsForNoCurrentActivity() {
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(null);

    Messages.FlutterError exception =
        assertThrows(
            Messages.FlutterError.class,
            () ->
                api.openUrlInApp(
                    "https://flutter.dev",
                    true,
                    new Messages.WebViewOptions.Builder()
                        .setEnableJavaScript(false)
                        .setEnableDomStorage(false)
                        .setHeaders(new HashMap<>())
                        .build(),
                    new Messages.BrowserOptions.Builder().setShowTitle(false).build()));
    assertEquals("NO_ACTIVITY", exception.code);
  }

  @Test
  public void openWebView_returnsFalse() {
    Activity activity = mock(Activity.class);
    UrlLauncher api = new UrlLauncher(ApplicationProvider.getApplicationContext());
    api.setActivity(activity);
    doThrow(new ActivityNotFoundException())
        .when(activity)
        .startActivity(any(), isNull()); // for custom tabs intent
    doThrow(new ActivityNotFoundException())
        .when(activity)
        .startActivity(any()); // for webview intent

    boolean result =
        api.openUrlInApp(
            "https://flutter.dev",
            true,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(new HashMap<>())
                .build(),
            new Messages.BrowserOptions.Builder().setShowTitle(false).build());

    assertFalse(result);
  }

  @Test
  public void closeWebView_closes() {
    Context context = mock(Context.class);
    UrlLauncher api = new UrlLauncher(context);

    api.closeWebView();

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(context).sendBroadcast(intentCaptor.capture());
    assertEquals(WebViewActivity.ACTION_CLOSE, intentCaptor.getValue().getAction());
  }
}
