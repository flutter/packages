// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Browser;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
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

  private @Nullable Activity activity;
  private final @NonNull Context applicationContext;

  private final @NonNull UrlLauncher urlLauncher;

  /** Forwards all incoming MethodChannel calls to the given {@code urlLauncher}. */
  UrlLauncherApiImpl(@NonNull Context context, @NonNull UrlLauncher urlLauncher) {
    this.applicationContext = context;
    this.urlLauncher = urlLauncher;
  }

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  @Override
  public @NonNull Boolean canLaunchUrl(@NonNull String url) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(url));
    String componentName = urlLauncher.getHandlerComponentName(launchIntent);
    if (BuildConfig.DEBUG) {
      Log.i(TAG, "component name for " + url + " is " + componentName);
    }
    if (componentName == null) {
      return false;
    } else {
      // Ignore the emulator fallback activity.
      return !"{com.android.fallback/com.android.fallback.Fallback}".equals(componentName);
    }
  }

  @Override
  public @NonNull LaunchStatusWrapper launchUrl(
      @NonNull String url, @NonNull Map<String, String> headers) {
    if (activity == null) {
      return wrapLaunchStatus(LaunchStatus.NO_CURRENT_ACTIVITY);
    }

    Intent launchIntent =
        new Intent(Intent.ACTION_VIEW)
            .setData(Uri.parse(url))
            .putExtra(Browser.EXTRA_HEADERS, extractBundle(headers));
    try {
      activity.startActivity(launchIntent);
    } catch (ActivityNotFoundException e) {
      return wrapLaunchStatus(LaunchStatus.NO_HANDLING_ACTIVITY);
    }

    return wrapLaunchStatus(LaunchStatus.SUCCESS);
  }

  @Override
  public @NonNull LaunchStatusWrapper openUrlInWebView(
      @NonNull String url, @NonNull WebViewOptions options) {
    if (activity == null) {
      return wrapLaunchStatus(LaunchStatus.NO_CURRENT_ACTIVITY);
    }

    Intent launchIntent =
        WebViewActivity.createIntent(
            activity,
            url,
            options.getEnableJavaScript(),
            options.getEnableDomStorage(),
            extractBundle(options.getHeaders()));
    try {
      activity.startActivity(launchIntent);
    } catch (ActivityNotFoundException e) {
      return wrapLaunchStatus(LaunchStatus.NO_HANDLING_ACTIVITY);
    }

    return wrapLaunchStatus(LaunchStatus.SUCCESS);
  }

  @Override
  public void closeWebView() {
    applicationContext.sendBroadcast(new Intent(WebViewActivity.ACTION_CLOSE));
    ;
  }

  private static @NonNull Bundle extractBundle(Map<String, String> headersMap) {
    final Bundle headersBundle = new Bundle();
    for (String key : headersMap.keySet()) {
      final String value = headersMap.get(key);
      headersBundle.putString(key, value);
    }
    return headersBundle;
  }

  private LaunchStatusWrapper wrapLaunchStatus(@NonNull LaunchStatus status) {
    return new LaunchStatusWrapper.Builder().setValue(status).build();
  }
}
