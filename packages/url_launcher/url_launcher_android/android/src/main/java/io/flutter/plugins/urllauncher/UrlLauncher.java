// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Encapsulates the Android-specific parts of the launch logic, to allow unit testing higher-level
 * code.
 */
class UrlLauncher {
  private final Context applicationContext;

  /**
   * Uses the given {@code applicationContext} for launching intents.
   *
   * <p>It may be null initially, but should be set before calling {@link #launch}.
   */
  UrlLauncher(Context applicationContext) {
    this.applicationContext = applicationContext;
  }

  /** Returns the component name that {@code url} resolves to for viewing, if any. */
  @Nullable
  String getViewerComponentName(@NonNull Uri url) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(url);
    ComponentName componentName =
        launchIntent.resolveActivity(applicationContext.getPackageManager());
    return componentName == null ? null : componentName.toShortString();
  }

  /** Closes any activities started with {@link #openWebView}. */
  void closeWebView() {
    applicationContext.sendBroadcast(new Intent(WebViewActivity.ACTION_CLOSE));
  }
}
