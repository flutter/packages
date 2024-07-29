// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.core.content.pm.ShortcutManagerCompat;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.plugins.quickactions.Messages.AndroidQuickActionsFlutterApi;

/** QuickActionsPlugin */
public class QuickActionsPlugin implements FlutterPlugin, ActivityAware, NewIntentListener {
  private static final String TAG = "QuickActionsAndroid";

  private QuickActions quickActions;
  private AndroidQuickActionsFlutterApi quickActionsFlutterApi;
  private final @NonNull AndroidSdkChecker sdkChecker;

  // Interface for an injectable SDK version checker.
  @VisibleForTesting
  interface AndroidSdkChecker {
    @ChecksSdkIntAtLeast(parameter = 0)
    boolean sdkIsAtLeast(int version);
  }

  public QuickActionsPlugin() {
    this((int version) -> Build.VERSION.SDK_INT >= version);
  }

  @VisibleForTesting
  QuickActionsPlugin(@NonNull AndroidSdkChecker capabilityChecker) {
    this.sdkChecker = capabilityChecker;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    this.quickActions = new QuickActions(binding.getApplicationContext());
    Messages.AndroidQuickActionsApi.setup(binding.getBinaryMessenger(), quickActions);
    this.quickActionsFlutterApi = new AndroidQuickActionsFlutterApi(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Messages.AndroidQuickActionsApi.setup(binding.getBinaryMessenger(), null);
    this.quickActions = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    if (this.quickActions == null) {
      Log.wtf(TAG, "quickActions was never set.");
      return;
    }

    Activity activity = binding.getActivity();
    this.quickActions.setActivity(activity);
    binding.addOnNewIntentListener(this);
    onNewIntent(activity.getIntent());
  }

  @Override
  public void onDetachedFromActivity() {
    quickActions.setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    binding.removeOnNewIntentListener(this);
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public boolean onNewIntent(@NonNull Intent intent) {
    // Do nothing for anything lower than API 25 as the functionality isn't supported.
    if (!sdkChecker.sdkIsAtLeast(Build.VERSION_CODES.N_MR1)) {
      return false;
    }
    Activity activity = this.quickActions.getActivity();
    // Notify the Dart side if the launch intent has the intent extra relevant to quick actions.
    if (intent.hasExtra(QuickActions.EXTRA_ACTION) && activity != null) {
      Context context = activity.getApplicationContext();
      String shortcutId = intent.getStringExtra(QuickActions.EXTRA_ACTION);
      quickActionsFlutterApi.launchAction(
          shortcutId,
          value -> {
            // noop
          });
      ShortcutManagerCompat.reportShortcutUsed(context, shortcutId);
    }
    return false;
  }
}
