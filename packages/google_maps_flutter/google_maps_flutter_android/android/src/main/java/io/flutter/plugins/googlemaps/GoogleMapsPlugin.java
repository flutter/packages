// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;

/**
 * Plugin for controlling a set of GoogleMap views to be shown as overlays on top of the Flutter
 * view. The overlay should be hidden during transformations or while Flutter is rendering on top of
 * the map. A Texture drawn using GoogleMap bitmap snapshots can then be shown instead of the
 * overlay.
 */
public class GoogleMapsPlugin implements FlutterPlugin, ActivityAware {

  @Nullable Lifecycle lifecycle;

  private static final String VIEW_TYPE = "plugins.flutter.dev/google_maps_android";

  public GoogleMapsPlugin() {}

  // FlutterPlugin

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    binding
        .getPlatformViewRegistry()
        .registerViewFactory(
            VIEW_TYPE,
            new GoogleMapFactory(
                binding.getBinaryMessenger(), binding.getApplicationContext(), () -> lifecycle));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  // ActivityAware

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    lifecycle = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }
}
