// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PlaneProxyFlutterApi;

/**
 * Flutter API implementation for {@link ImageProxy.PlaneProxy}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class PlaneProxyFlutterApiImpl {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private PlaneProxyFlutterApi api;

  /**
   * Constructs a {@link PlaneProxyFlutterApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public PlaneProxyFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    api = new PlaneProxyFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link ImageProxy.PlaneProxy} instance and notifies Dart to create and store a new
   * {@link ImageProxy.PlaneProxy} instance that is attached to this one. If {@code instance} has
   * already been added, this method does nothing.
   */
  public void create(
      @NonNull ImageProxy.PlaneProxy instance,
      @NonNull byte[] bytes,
      @NonNull Long pixelStride,
      @NonNull Long rowStride,
      @NonNull PlaneProxyFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      api.create(
          instanceManager.addHostCreatedInstance(instance),
          bytes,
          pixelStride,
          rowStride,
          callback);
    }
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull PlaneProxyFlutterApi api) {
    this.api = api;
  }
}
