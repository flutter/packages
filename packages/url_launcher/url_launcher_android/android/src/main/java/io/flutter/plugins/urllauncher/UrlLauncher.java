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
import io.flutter.plugins.urllauncher.Messages.LaunchStatus;

/** Launches components for URLs. */
class UrlLauncher {
  private static final String TAG = "UrlLauncher";
  private final Context applicationContext;

  @Nullable private Activity activity;

  /**
   * Uses the given {@code applicationContext} for launching intents.
   *
   * <p>It may be null initially, but should be set before calling {@link #launch}.
   */
  UrlLauncher(Context applicationContext, @Nullable Activity activity) {
    this.applicationContext = applicationContext;
    this.activity = activity;
  }

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  /** Returns whether the given {@code url} resolves into an existing component. */
  boolean canLaunch(@NonNull String url) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(url));
    ComponentName componentName =
        launchIntent.resolveActivity(applicationContext.getPackageManager());

    if (componentName == null) {
      Log.i(TAG, "component name for " + url + " is null");
      return false;
    } else {
      Log.i(TAG, "component name for " + url + " is " + componentName.toShortString());
      return !"{com.android.fallback/com.android.fallback.Fallback}"
          .equals(componentName.toShortString());
    }
  }

  /**
   * Attempts to launch the given {@code url}.
   *
   * @param headersBundle forwarded to the intent as {@code Browser.EXTRA_HEADERS}.
   * @return {@link LaunchStatus#NO_CURRENT_ACTIVITY} if there's no available {@code
   *     applicationContext}. {@link LaunchStatus#NO_HANDLING_ACTIVITY} if there's no activity found
   *     to handle {@code launchIntent}. {@link LaunchStatus#SUCCESS} otherwise.
   */
  LaunchStatus launch(@NonNull String url, @NonNull Bundle headersBundle) {
    if (activity == null) {
      return LaunchStatus.NO_CURRENT_ACTIVITY;
    }

    Intent launchIntent =
        new Intent(Intent.ACTION_VIEW)
            .setData(Uri.parse(url))
            .putExtra(Browser.EXTRA_HEADERS, headersBundle);
    try {
      activity.startActivity(launchIntent);
    } catch (ActivityNotFoundException e) {
      return LaunchStatus.NO_HANDLING_ACTIVITY;
    }

    return LaunchStatus.SUCCESS;
  }

  /**
   * Attempts to open the given {@code url} in a WebView.
   *
   * @param headersBundle forwarded to the intent as {@code Browser.EXTRA_HEADERS}.
   * @param enableJavaScript Only used if {@param useWebView} is true. Enables JS in the WebView.
   * @param enableDomStorage Only used if {@param useWebView} is true. Enables DOM storage in the
   * @return {@link LaunchStatus#NO_CURRENT_ACTIVITY} if there's no available {@code
   *     applicationContext}. {@link LaunchStatus#NO_HANDLING_ACTIVITY} if there's no activity found
   *     to handle {@code launchIntent}. {@link LaunchStatus#SUCCESS} otherwise.
   */
  LaunchStatus openWebView(
      @NonNull String url,
      @NonNull Bundle headersBundle,
      boolean enableJavaScript,
      boolean enableDomStorage) {
    if (activity == null) {
      return LaunchStatus.NO_CURRENT_ACTIVITY;
    }

    Intent launchIntent =
        WebViewActivity.createIntent(
            activity, url, enableJavaScript, enableDomStorage, headersBundle);
    try {
      activity.startActivity(launchIntent);
    } catch (ActivityNotFoundException e) {
      return LaunchStatus.NO_HANDLING_ACTIVITY;
    }

    return LaunchStatus.SUCCESS;
  }

  /** Closes any activities started with {@link #launch} {@code useWebView=true}. */
  void closeWebView() {
    applicationContext.sendBroadcast(new Intent(WebViewActivity.ACTION_CLOSE));
  }
}
