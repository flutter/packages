// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebSettings;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Host api implementation for {@link WebSettings}.
 *
 * <p>Handles creating {@link WebSettings}s that intercommunicate with a paired Dart object.
 */
public class WebSettingsProxyApi extends PigeonApiWebSettings {
  public WebSettingsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void setDomStorageEnabled(@NonNull WebSettings pigeon_instance, boolean flag) {
    pigeon_instance.setDomStorageEnabled(flag);
  }

  @Override
  public void setJavaScriptCanOpenWindowsAutomatically(
      @NonNull WebSettings pigeon_instance, boolean flag) {
    pigeon_instance.setJavaScriptCanOpenWindowsAutomatically(flag);
  }

  @Override
  public void setSupportMultipleWindows(@NonNull WebSettings pigeon_instance, boolean support) {
    pigeon_instance.setSupportMultipleWindows(support);
  }

  @Override
  public void setJavaScriptEnabled(@NonNull WebSettings pigeon_instance, boolean flag) {
    pigeon_instance.setJavaScriptEnabled(flag);
  }

  @Override
  public void setUserAgentString(
      @NonNull WebSettings pigeon_instance, @Nullable String userAgentString) {
    pigeon_instance.setUserAgentString(userAgentString);
  }

  @Override
  public void setMediaPlaybackRequiresUserGesture(
      @NonNull WebSettings pigeon_instance, boolean require) {
    pigeon_instance.setMediaPlaybackRequiresUserGesture(require);
  }

  @Override
  public void setSupportZoom(@NonNull WebSettings pigeon_instance, boolean support) {
    pigeon_instance.setSupportZoom(support);
  }

  @Override
  public void setLoadWithOverviewMode(@NonNull WebSettings pigeon_instance, boolean overview) {
    pigeon_instance.setLoadWithOverviewMode(overview);
  }

  @Override
  public void setUseWideViewPort(@NonNull WebSettings pigeon_instance, boolean use) {
    pigeon_instance.setUseWideViewPort(use);
  }

  @Override
  public void setDisplayZoomControls(@NonNull WebSettings pigeon_instance, boolean enabled) {
    pigeon_instance.setDisplayZoomControls(enabled);
  }

  @Override
  public void setBuiltInZoomControls(@NonNull WebSettings pigeon_instance, boolean enabled) {
    pigeon_instance.setBuiltInZoomControls(enabled);
  }

  @Override
  public void setAllowFileAccess(@NonNull WebSettings pigeon_instance, boolean enabled) {
    pigeon_instance.setAllowFileAccess(enabled);
  }

  @Override
  public void setAllowContentAccess(@NonNull WebSettings pigeon_instance, boolean enabled) {
    pigeon_instance.setAllowContentAccess(enabled);
  }

  @Override
  public void setGeolocationEnabled(@NonNull WebSettings pigeon_instance, boolean enabled) {
    pigeon_instance.setGeolocationEnabled(enabled);
  }

  @Override
  public void setTextZoom(@NonNull WebSettings pigeon_instance, long textZoom) {
    pigeon_instance.setTextZoom((int) textZoom);
  }

  @NonNull
  @Override
  public String getUserAgentString(@NonNull WebSettings pigeon_instance) {
    return pigeon_instance.getUserAgentString();
  }
}
