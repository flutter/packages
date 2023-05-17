// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageProxyFlutterApi;

/**
 * Flutter API implementation for {@link ImageProxy}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class ImageProxyFlutterApiImpl {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private ImageProxyFlutterApi api;

  /**
   * Constructs a {@link ImageProxyFlutterApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public ImageProxyFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    api = new ImageProxyFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link ImageProxy} instance and notifies Dart to create and store a new {@link
   * ImageProxy} instance that is attached to this one. If {@code instance} has already been added,
   * this method does nothing.
   */
  public void create(
      @NonNull ImageProxy instance,
      @NonNull Long imageFormat,
      @NonNull Long imageHeight,
      @NonNull Long imageWidth,
      @NonNull ImageProxyFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      api.create(
          instanceManager.addHostCreatedInstance(instance),
          imageFormat,
          imageHeight,
          imageWidth,
          callback);
    }
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull ImageProxyFlutterApi api) {
    this.api = api;
  }
}
