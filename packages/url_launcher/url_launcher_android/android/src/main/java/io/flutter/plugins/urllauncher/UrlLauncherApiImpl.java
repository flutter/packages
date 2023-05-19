// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Browser;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugins.urllauncher.Messages.LaunchStatus;
import io.flutter.plugins.urllauncher.Messages.LaunchStatusWrapper;
import io.flutter.plugins.urllauncher.Messages.UrlLauncherApi;
import io.flutter.plugins.urllauncher.Messages.WebViewOptions;
import java.util.Map;

/** Implements the Pigeon-defined interface for calls from Dart. */
final class UrlLauncherApiImpl implements UrlLauncherApi {
  @VisibleForTesting
  interface IntentResolver {
    String getHandlerComponentName(@NonNull Intent intent);
  }

  private static final String TAG = "UrlLauncher";

  private final @NonNull Context applicationContext;

  private final @NonNull IntentResolver intentResolver;

  private @Nullable Activity activity;

  /**
   * Creates an instance that uses {@code intentResolver} to look up the handler for intents. This
   * is to allow injecting an alternate resolver for unit testing.
   */
  @VisibleForTesting
  UrlLauncherApiImpl(@NonNull Context context, @NonNull IntentResolver intentResolver) {
    this.applicationContext = context;
    this.intentResolver = intentResolver;
  }

  UrlLauncherApiImpl(@NonNull Context context) {
    this(
        context,
        intent -> {
          ComponentName componentName = intent.resolveActivity(context.getPackageManager());
          return componentName == null ? null : componentName.toShortString();
        });
  }

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  @Override
  public @NonNull Boolean canLaunchUrl(@NonNull String url) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(url));
    String componentName = intentResolver.getHandlerComponentName(launchIntent);
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
