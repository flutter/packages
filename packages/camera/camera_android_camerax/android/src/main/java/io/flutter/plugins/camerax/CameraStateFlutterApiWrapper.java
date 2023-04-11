
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateTypeData;


/**
 * Flutter API implementation for `CameraState`.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class CameraStateFlutterApiWrapper {

  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private CameraStateFlutterApi api;

  /**
   * Constructs a {@link CameraStateFlutterApiWrapper}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public CameraStateFlutterApiWrapper(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    api = new CameraStateFlutterApi(binaryMessenger);
  }

  /**
   * Stores the `CameraState` instance and notifies Dart to create and store a new `CameraState`
   * instance that is attached to this one. If `instance` has already been added, this method does
   * nothing.
   */
  public void create(
      @NonNull CameraState instance,
      @NonNull CameraState.Type type,
      @Nullable CameraState.StateError error,
      @NonNull CameraStateFlutterApi.Reply<Void> callback) {

    // TODO(camsim99): actually fix this
    CameraStateType cameraStateType;
    switch (type) {
      default:
      cameraStateType = CameraStateType.CLOSED;
    }

    if (error != null) {
      new CameraStateErrorFlutterApiWrapper(binaryMessenger, instanceManager).create(error, Long.valueOf(error.getCode()), "TODO(camsim99)", reply -> {});
    }

    if (!instanceManager.containsInstance(instance)) {
      api.create(
          instanceManager.addHostCreatedInstance(instance),
          new CameraStateTypeData.Builder().setValue(cameraStateType).build(),
          instanceManager.getIdentifierForStrongReference(error),
          callback);
    }
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull CameraStateFlutterApi api) {
    this.api = api;
  }
}
