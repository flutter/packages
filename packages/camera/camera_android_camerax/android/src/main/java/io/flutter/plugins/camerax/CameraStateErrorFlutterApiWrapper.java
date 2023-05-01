// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateErrorFlutterApi;

/**
 * Flutter API implementation for {@link CameraStateError}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class CameraStateErrorFlutterApiWrapper {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private CameraStateErrorFlutterApi cameraStateErrorFlutterApi;

  /**
   * Constructs a {@link CameraStateErrorFlutterApiWrapper}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public CameraStateErrorFlutterApiWrapper(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    cameraStateErrorFlutterApi = new CameraStateErrorFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link CameraStateError} instance and notifies Dart to create and store a new {@link
   * CameraStateError} instance that is attached to this one. If {@code instance} has already been
   * added, this method does nothing.
   */
  public void create(
      @NonNull CameraState.StateError instance,
      @NonNull Long code,
      @NonNull CameraStateErrorFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      cameraStateErrorFlutterApi.create(
          instanceManager.addHostCreatedInstance(instance), code, callback);
    }
  }

  /** Sets the Flutter API used to send messages to Dart. */
  @VisibleForTesting
  void setApi(@NonNull CameraStateErrorFlutterApi api) {
    this.cameraStateErrorFlutterApi = api;
  }
}
