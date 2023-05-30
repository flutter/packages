// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public final class UrlLauncherPlugin implements FlutterPlugin, ActivityAware {
  private static final String TAG = "UrlLauncherPlugin";
  @Nullable private UrlLauncher urlLauncher;

  /**
   * Registers a plugin implementation that uses the stable {@code io.flutter.plugin.common}
   * package.
   *
   * <p>Calling this automatically initializes the plugin. However plugins initialized this way
   * won't react to changes in activity or context, unlike {@link UrlLauncherPlugin}.
   */
  @SuppressWarnings("deprecation")
  public static void registerWith(
      @NonNull io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    UrlLauncher handler = new UrlLauncher(registrar.context());
    handler.setActivity(registrar.activity());
    Messages.UrlLauncherApi.setup(registrar.messenger(), handler);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    urlLauncher = new UrlLauncher(binding.getApplicationContext());
    Messages.UrlLauncherApi.setup(binding.getBinaryMessenger(), urlLauncher);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (urlLauncher == null) {
      Log.wtf(TAG, "Already detached from the engine.");
      return;
    }

    Messages.UrlLauncherApi.setup(binding.getBinaryMessenger(), null);
    urlLauncher = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    if (urlLauncher == null) {
      Log.wtf(TAG, "urlLauncher was never set.");
      return;
    }
    urlLauncher.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    if (urlLauncher == null) {
      Log.wtf(TAG, "urlLauncher was never set.");
      return;
    }
    urlLauncher.setActivity(null);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }
}
