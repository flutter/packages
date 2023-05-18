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
public class MethodCallHandlerImplTest {
  private static final String CHANNEL_NAME = "plugins.flutter.io/url_launcher_android";
  private UrlLauncher urlLauncher;
  private MethodCallHandlerImpl methodCallHandler;

  @Before
  public void setUp() {
    urlLauncher = new UrlLauncher(ApplicationProvider.getApplicationContext(), /*activity=*/ null);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
  }

  @Test
  public void onMethodCall_canLaunchReturnsTrue() {
    urlLauncher = mock(UrlLauncher.class);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    String url = "foo";
    when(urlLauncher.canLaunch(url)).thenReturn(true);

    Boolean result = methodCallHandler.canLaunchUrl(url);

    assertTrue(result);
  }

  @Test
  public void onMethodCall_canLaunchReturnsFalse() {
    urlLauncher = mock(UrlLauncher.class);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    String url = "foo";
    when(urlLauncher.canLaunch(url)).thenReturn(false);

    Boolean result = methodCallHandler.canLaunchUrl(url);

    assertFalse(result);
  }

  @Test
  public void onMethodCall_launchReturnsNoActivityError() {
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

    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    LaunchStatusWrapper result = methodCallHandler.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.NO_CURRENT_ACTIVITY, result.getValue());
  }

  @Test
  public void onMethodCall_launchReturnsActivityNotFoundError() {
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

    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    LaunchStatusWrapper result = methodCallHandler.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.NO_HANDLING_ACTIVITY, result.getValue());
  }

  @Test
  public void onMethodCall_launchReturnsTrue() {
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

    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    LaunchStatusWrapper result = methodCallHandler.launchUrl(url, new HashMap<>());

    assertEquals(LaunchStatus.SUCCESS, result.getValue());
  }

  @Test
  public void onMethodCall_closeWebView() {
    urlLauncher = mock(UrlLauncher.class);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);

    methodCallHandler.closeWebView();

    verify(urlLauncher, times(1)).closeWebView();
  }
}
