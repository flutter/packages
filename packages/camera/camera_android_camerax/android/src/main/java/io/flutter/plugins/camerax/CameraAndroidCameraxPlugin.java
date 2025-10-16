// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/** Platform implementation of the camera_plugin implemented with the CameraX library. */
public final class CameraAndroidCameraxPlugin implements FlutterPlugin, ActivityAware {
  private FlutterPluginBinding pluginBinding;
  @VisibleForTesting @Nullable ProxyApiRegistrar proxyApiRegistrar;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code io.flutter.plugins.camera.MainActivity} for an example.
   */
  public CameraAndroidCameraxPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    pluginBinding = binding;

    proxyApiRegistrar =
        new ProxyApiRegistrar(
            binding.getBinaryMessenger(),
            binding.getApplicationContext(),
            binding.getTextureRegistry());
    proxyApiRegistrar.setUp();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (proxyApiRegistrar != null) {
      proxyApiRegistrar.setIgnoreCallsToDart(true);
      proxyApiRegistrar.tearDown();
      proxyApiRegistrar.getInstanceManager().stopFinalizationListener();
      proxyApiRegistrar = null;
    }
  }

  // Activity Lifecycle methods:

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    if (proxyApiRegistrar != null) {
      proxyApiRegistrar.setContext(activityPluginBinding.getActivity());
      proxyApiRegistrar.setPermissionsRegistry(
          activityPluginBinding::addRequestPermissionsResultListener);
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    if (proxyApiRegistrar != null) {
      proxyApiRegistrar.setContext(pluginBinding.getApplicationContext());
      proxyApiRegistrar.setPermissionsRegistry(null);
    }
  }

  @Override
  public void onReattachedToActivityForConfigChanges(
      @NonNull ActivityPluginBinding activityPluginBinding) {
    if (proxyApiRegistrar != null) {
      proxyApiRegistrar.setContext(activityPluginBinding.getActivity());
      proxyApiRegistrar.setPermissionsRegistry(
          activityPluginBinding::addRequestPermissionsResultListener);
    }
  }

  @Override
  public void onDetachedFromActivity() {
    // Clear any references to previously attached `ActivityPluginBinding`/`Activity`.
    if (proxyApiRegistrar != null) {
      proxyApiRegistrar.setContext(pluginBinding.getApplicationContext());
      proxyApiRegistrar.setPermissionsRegistry(null);
    }
  }
}
