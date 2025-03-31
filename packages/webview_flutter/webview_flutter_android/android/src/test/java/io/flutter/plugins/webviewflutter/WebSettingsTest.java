// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.webkit.WebSettings;
import org.junit.Test;

public class WebSettingsTest {
  @Test
  public void setDomStorageEnabled() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean flag = true;
    api.setDomStorageEnabled(instance, flag);

    verify(instance).setDomStorageEnabled(flag);
  }

  @Test
  public void setJavaScriptCanOpenWindowsAutomatically() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean flag = true;
    api.setJavaScriptCanOpenWindowsAutomatically(instance, flag);

    verify(instance).setJavaScriptCanOpenWindowsAutomatically(flag);
  }

  @Test
  public void setSupportMultipleWindows() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean support = true;
    api.setSupportMultipleWindows(instance, support);

    verify(instance).setSupportMultipleWindows(support);
  }

  @Test
  public void setJavaScriptEnabled() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean flag = true;
    api.setJavaScriptEnabled(instance, flag);

    verify(instance).setJavaScriptEnabled(flag);
  }

  @Test
  public void setUserAgentString() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final String userAgentString = "myString";
    api.setUserAgentString(instance, userAgentString);

    verify(instance).setUserAgentString(userAgentString);
  }

  @Test
  public void setMediaPlaybackRequiresUserGesture() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean require = true;
    api.setMediaPlaybackRequiresUserGesture(instance, require);

    verify(instance).setMediaPlaybackRequiresUserGesture(require);
  }

  @Test
  public void setSupportZoom() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean support = true;
    api.setSupportZoom(instance, support);

    verify(instance).setSupportZoom(support);
  }

  @Test
  public void setLoadWithOverviewMode() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean overview = true;
    api.setLoadWithOverviewMode(instance, overview);

    verify(instance).setLoadWithOverviewMode(overview);
  }

  @Test
  public void setUseWideViewPort() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean use = true;
    api.setUseWideViewPort(instance, use);

    verify(instance).setUseWideViewPort(use);
  }

  @Test
  public void setDisplayZoomControls() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean enabled = true;
    api.setDisplayZoomControls(instance, enabled);

    verify(instance).setDisplayZoomControls(enabled);
  }

  @Test
  public void setBuiltInZoomControls() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean enabled = true;
    api.setBuiltInZoomControls(instance, enabled);

    verify(instance).setBuiltInZoomControls(enabled);
  }

  @Test
  public void setAllowFileAccess() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final boolean enabled = true;
    api.setAllowFileAccess(instance, enabled);

    verify(instance).setAllowFileAccess(enabled);
  }

  @Test
  public void setTextZoom() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final long textZoom = 0L;
    api.setTextZoom(instance, textZoom);

    verify(instance).setTextZoom((int) textZoom);
  }

  @Test
  public void getUserAgentString() {
    final PigeonApiWebSettings api = new TestProxyApiRegistrar().getPigeonApiWebSettings();

    final WebSettings instance = mock(WebSettings.class);
    final String value = "myString";
    when(instance.getUserAgentString()).thenReturn(value);

    assertEquals(value, api.getUserAgentString(instance));
  }
}
