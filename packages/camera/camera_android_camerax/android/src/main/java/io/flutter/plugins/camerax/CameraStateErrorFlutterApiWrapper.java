
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateErrorFlutterApi;

/**
 * Flutter API implementation for `CameraStateError`.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class CameraStateErrorFlutterApiWrapper {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private CameraStateErrorFlutterApi api;

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
    api = new CameraStateErrorFlutterApi(binaryMessenger);
  }

  /**
   * Stores the `CameraStateError` instance and notifies Dart to create and store a new
   * `CameraStateError` instance that is attached to this one. If `instance` has already been added,
   * this method does nothing.
   */
  public void create(
      @NonNull CameraState.StateError instance,
      @NonNull Long code,
      @NonNull String description,
      @NonNull CameraStateErrorFlutterApi.Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      api.create(instanceManager.addHostCreatedInstance(instance), code, description, callback);
    }
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull CameraStateErrorFlutterApi api) {
    this.api = api;
  }
}
