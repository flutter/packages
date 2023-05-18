// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.plugins.urllauncher.Messages.LaunchStatus;
import io.flutter.plugins.urllauncher.Messages.LaunchStatusWrapper;
import io.flutter.plugins.urllauncher.Messages.UrlLauncherApi;
import io.flutter.plugins.urllauncher.Messages.WebViewOptions;
import java.util.Map;

/**
 * Translates incoming UrlLauncher MethodCalls into well formed Java function calls for {@link
 * UrlLauncher}.
 */
final class UrlLauncherApiImpl implements UrlLauncherApi {
  private static final String TAG = "UrlLauncher";

  private final UrlLauncher urlLauncher;

  /** Forwards all incoming MethodChannel calls to the given {@code urlLauncher}. */
  UrlLauncherApiImpl(UrlLauncher urlLauncher) {
    this.urlLauncher = urlLauncher;
  }

  @Override
  public @NonNull Boolean canLaunchUrl(@NonNull String url) {
    String componentName = urlLauncher.getViewerComponentName(Uri.parse(url));
    if (BuildConfig.DEBUG) {
      Log.i(TAG, "component name for " + url + " is " + componentName);
    }
    if (componentName == null) {
      return false;
    } else {
      // Ignore the emulator fallback activity.
      return !"{com.android.fallback/com.android.fallback.Fallback}"
              .equals(componentName);
    }
  }

  @Override
  public @NonNull LaunchStatusWrapper launchUrl(
      @NonNull String url, @NonNull Map<String, String> headers) {
    LaunchStatus launchStatus = urlLauncher.launch(url, extractBundle(headers));
    return new LaunchStatusWrapper.Builder().setValue(launchStatus).build();
  }

  @Override
  public @NonNull LaunchStatusWrapper openUrlInWebView(
      @NonNull String url, @NonNull WebViewOptions options) {
    LaunchStatus launchStatus =
        urlLauncher.openWebView(
            url,
            extractBundle(options.getHeaders()),
            options.getEnableJavaScript(),
            options.getEnableDomStorage());
    return new LaunchStatusWrapper.Builder().setValue(launchStatus).build();
  }

  @Override
  public void closeWebView() {
    urlLauncher.closeWebView();
  }

  private static @NonNull Bundle extractBundle(Map<String, String> headersMap) {
    final Bundle headersBundle = new Bundle();
    for (String key : headersMap.keySet()) {
      final String value = headersMap.get(key);
      headersBundle.putString(key, value);
    }
    return headersBundle;
  }
}
