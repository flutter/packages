// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
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
    when(urlLauncher.getViewerComponentName(url)).thenReturn("{com.android.fallback/com.android.fallback.Fallback}");

    Boolean result = api.canLaunchUrl(url.toString());

    assertFalse(result);
  }

  @Test
  public void launch_returnsNoActivityError() {
    urlLauncher.setActivity(null);
    String url = "foo";

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.NO_CURRENT_ACTIVITY, result.getValue());
  }

  @Test
  public void launch_returnsActivityNotFoundError() {
    Activity activity = mock(Activity.class);
    urlLauncher.setActivity(activity);
    String url = "foo";
    doThrow(new ActivityNotFoundException()).when(activity).startActivity(any());

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(LaunchStatus.NO_HANDLING_ACTIVITY, result.getValue());
    assertEquals(url, intentCaptor.getValue().getData().toString());
  }

  @Test
  public void launch_returnsTrue() {
    Activity activity = mock(Activity.class);
    urlLauncher.setActivity(activity);
    String url = "foo";

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    final ArgumentCaptor<Intent> intentCaptor = ArgumentCaptor.forClass(Intent.class);
    verify(activity).startActivity(intentCaptor.capture());
    assertEquals(LaunchStatus.SUCCESS, result.getValue());
    assertEquals(url, intentCaptor.getValue().getData().toString());
  }

  @Test
  public void openWebView_opens() {
    urlLauncher = mock(UrlLauncher.class);
    String url = "foo";
    boolean enableJavaScript = true;
    boolean enableDomStorage = true;
    when(urlLauncher.openWebView(
            eq(url), any(Bundle.class), eq(enableJavaScript), eq(enableDomStorage)))
        .thenReturn(LaunchStatus.NO_CURRENT_ACTIVITY);

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result =
        api.openUrlInWebView(
            url,
            new Messages.WebViewOptions.Builder()
                .setEnableJavaScript(enableJavaScript)
                .setEnableDomStorage(enableDomStorage)
                .setHeaders(new HashMap<>())
                .build());

    assertEquals(LaunchStatus.NO_CURRENT_ACTIVITY, result.getValue());
  }

  @Test
  public void closeWebView_closes() {
    urlLauncher = mock(UrlLauncher.class);
    api = new UrlLauncherApiImpl(urlLauncher);

    api.closeWebView();

    verify(urlLauncher, times(1)).closeWebView();
  }
}
