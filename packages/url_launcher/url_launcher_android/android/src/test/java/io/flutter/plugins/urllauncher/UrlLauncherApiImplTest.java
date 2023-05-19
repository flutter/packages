// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Browser;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugins.urllauncher.Messages.LaunchStatus;
import io.flutter.plugins.urllauncher.Messages.LaunchStatusWrapper;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class UrlLauncherApiImplTest {
  private static final String CHANNEL_NAME = "plugins.flutter.io/url_launcher_android";
  private UrlLauncher urlLauncher;
  private UrlLauncherApiImpl api;

  @Before
  public void setUp() {
    urlLauncher = new UrlLauncher(ApplicationProvider.getApplicationContext(), /*activity=*/ null);
    api = new UrlLauncherApiImpl(urlLauncher);
  }

  @Test
  public void canLaunch_returnsTrue() {
    urlLauncher = mock(UrlLauncher.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    Uri url = Uri.parse("https://flutter.dev");
    when(urlLauncher.getViewerComponentName(url)).thenReturn("some.component");

    Boolean result = api.canLaunchUrl(url.toString());

    assertTrue(result);
  }

  @Test
  public void canLaunch_returnsFalse() {
    urlLauncher = mock(UrlLauncher.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    Uri url = Uri.parse("https://flutter.dev");
    when(urlLauncher.getViewerComponentName(url)).thenReturn(null);

    Boolean result = api.canLaunchUrl(url.toString());

    assertFalse(result);
  }

  @Test
  public void canLaunch_returnsFalseForEmulatorFallbackComponent() {
    urlLauncher = mock(UrlLauncher.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    Uri url = Uri.parse("https://flutter.dev");
    when(urlLauncher.getViewerComponentName(url))
        .thenReturn("{com.android.fallback/com.android.fallback.Fallback}");

    Boolean result = api.canLaunchUrl(url.toString());

    assertFalse(result);
  }

  @Test
  public void launch_returnsNoCurrentActivity() {
    urlLauncher.setActivity(null);
    String url = "https://flutter.dev";

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.NO_CURRENT_ACTIVITY, result.getValue());
  }

  @Test
  public void launch_returnsNoHandlingActivity() {
    Activity activity = mock(Activity.class);
    String url = "https://flutter.dev";
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(activity);
    doThrow(new ActivityNotFoundException()).when(activity).startActivity(any());

    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(LaunchStatus.NO_HANDLING_ACTIVITY, result.getValue());
    assertEquals(intentCaptor.getValue().getData().toString(), url);
  }

  @Test
  public void launch_returnsTrue() {
    Activity activity = mock(Activity.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(activity);
    String url = "https://flutter.dev";

    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(LaunchStatus.SUCCESS, result.getValue());
    assertEquals(intentCaptor.getValue().getData().toString(), url);
  }

  @Test
  public void openWebView_opensUrl() {
    Activity activity = mock(Activity.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(activity);
    String url = "https://flutter.dev";
    boolean enableJavaScript = false;
    boolean enableDomStorage = false;

    LaunchStatusWrapper result =
        api.openUrlInWebView(
            url,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(enableJavaScript)
                .setEnableDomStorage(enableDomStorage)
                .setHeaders(new HashMap<>())
                .build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(LaunchStatus.SUCCESS, result.getValue());
    assertEquals(intentCaptor.getValue().getExtras().getString(WebViewActivity.URL_EXTRA), url);
    assertEquals(
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_JS_EXTRA),
        enableJavaScript);
    assertEquals(
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_DOM_EXTRA),
        enableDomStorage);
  }

  @Test
  public void openWebView_handlesEnableJavaScript() {
    Activity activity = mock(Activity.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(activity);
    boolean enableJavaScript = true;

    LaunchStatusWrapper result =
        api.openUrlInWebView(
            "https://flutter.dev",
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(enableJavaScript)
                .setEnableDomStorage(false)
                .setHeaders(new HashMap<>())
                .build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_JS_EXTRA),
        enableJavaScript);
  }

  @Test
  public void openWebView_handlesHeaders() {
    Activity activity = mock(Activity.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(activity);
    HashMap<String, String> headers = new HashMap<>();
    final String key1 = "key";
    final String key2 = "key2";
    headers.put(key1, "value");
    headers.put(key2, "value2");

    LaunchStatusWrapper result =
        api.openUrlInWebView(
            "https://flutter.dev",
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(headers)
                .build());

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
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(activity);
    boolean enableDomStorage = true;

    LaunchStatusWrapper result =
        api.openUrlInWebView(
            "https://flutter.dev",
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(enableDomStorage)
                .setHeaders(new HashMap<>())
                .build());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(
        intentCaptor.getValue().getExtras().getBoolean(WebViewActivity.ENABLE_DOM_EXTRA),
        enableDomStorage);
  }

  @Test
  public void openWebView_returnsNoCurrentActivity() {
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(null);
    String url = "https://flutter.dev";

    LaunchStatusWrapper result =
        api.openUrlInWebView(
            "https://flutter.dev",
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(new HashMap<>())
                .build());

    assertEquals(LaunchStatus.NO_CURRENT_ACTIVITY, result.getValue());
  }

  @Test
  public void openWebView_returnsNoHandlingActivity() {
    Activity activity = mock(Activity.class);
    String url = "https://flutter.dev";
    api = new UrlLauncherApiImpl(urlLauncher);
    api.setActivity(activity);
    doThrow(new ActivityNotFoundException()).when(activity).startActivity(any());

    LaunchStatusWrapper result =
        api.openUrlInWebView(
            "https://flutter.dev",
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(false)
                .setEnableDomStorage(false)
                .setHeaders(new HashMap<>())
                .build());

    assertEquals(LaunchStatus.NO_HANDLING_ACTIVITY, result.getValue());
  }

  @Test
  public void closeWebView_closes() {
    urlLauncher = mock(UrlLauncher.class);
    api = new UrlLauncherApiImpl(urlLauncher);

    api.closeWebView();

    verify(urlLauncher, times(1)).closeWebView();
  }
}
