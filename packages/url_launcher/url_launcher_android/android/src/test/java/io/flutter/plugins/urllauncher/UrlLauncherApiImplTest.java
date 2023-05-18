// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.os.Bundle;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugins.urllauncher.Messages.LaunchStatus;
import io.flutter.plugins.urllauncher.Messages.LaunchStatusWrapper;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
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
    String url = "foo";
    when(urlLauncher.canLaunch(url)).thenReturn(true);

    Boolean result = api.canLaunchUrl(url);

    assertTrue(result);
  }

  @Test
  public void canLaunch_returnsFalse() {
    urlLauncher = mock(UrlLauncher.class);
    api = new UrlLauncherApiImpl(urlLauncher);
    String url = "foo";
    when(urlLauncher.canLaunch(url)).thenReturn(false);

    Boolean result = api.canLaunchUrl(url);

    assertFalse(result);
  }

  @Test
  public void launch_returnsNoActivityError() {
    // Setup mock objects
    urlLauncher = mock(UrlLauncher.class);
    // Setup expected values
    String url = "foo";
    boolean useWebView = false;
    boolean enableJavaScript = false;
    boolean enableDomStorage = false;
    when(urlLauncher.launch(
            eq(url), any(Bundle.class), eq(useWebView), eq(enableJavaScript), eq(enableDomStorage)))
        .thenReturn(LaunchStatus.NO_CURRENT_ACTIVITY);

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.NO_CURRENT_ACTIVITY, result.getValue());
  }

  @Test
  public void launch_returnsActivityNotFoundError() {
    // Setup mock objects
    urlLauncher = mock(UrlLauncher.class);
    // Setup expected values
    String url = "foo";
    boolean useWebView = false;
    boolean enableJavaScript = false;
    boolean enableDomStorage = false;
    // Mock the launch method on the urlLauncher class
    when(urlLauncher.launch(
            eq(url), any(Bundle.class), eq(useWebView), eq(enableJavaScript), eq(enableDomStorage)))
        .thenReturn(LaunchStatus.NO_HANDLING_ACTIVITY);

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.NO_HANDLING_ACTIVITY, result.getValue());
  }

  @Test
  public void launch_returnsTrue() {
    // Setup mock objects
    urlLauncher = mock(UrlLauncher.class);
    // Setup expected values
    String url = "foo";
    boolean useWebView = false;
    boolean enableJavaScript = false;
    boolean enableDomStorage = false;
    // Mock the launch method on the urlLauncher class
    when(urlLauncher.launch(
            eq(url), any(Bundle.class), eq(useWebView), eq(enableJavaScript), eq(enableDomStorage)))
        .thenReturn(LaunchStatus.SUCCESS);

    api = new UrlLauncherApiImpl(urlLauncher);
    LaunchStatusWrapper result = api.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.SUCCESS, result.getValue());
  }

  @Test
  public void closeWebView_closes() {
    urlLauncher = mock(UrlLauncher.class);
    api = new UrlLauncherApiImpl(urlLauncher);

    api.closeWebView();

    verify(urlLauncher, times(1)).closeWebView();
  }
}
