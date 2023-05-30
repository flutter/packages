// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraStateTypeData;

/**
 * Flutter API implementation for {@link CameraState}.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class CameraStateFlutterApiWrapper {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private CameraStateFlutterApi cameraStateFlutterApi;

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
    cameraStateFlutterApi = new CameraStateFlutterApi(binaryMessenger);
  }

  /**
   * Stores the {@link CameraState} instance and notifies Dart to create and store a new {@link
   * CameraState} instance that is attached to this one. If {@code instance} has already been added,
   * this method does nothing.
   */
  public void create(
      @NonNull CameraState instance,
      @NonNull CameraStateType type,
      @Nullable CameraState.StateError error,
      @NonNull CameraStateFlutterApi.Reply<Void> callback) {
    if (instanceManager.containsInstance(instance)) {
      return;
    }

    if (error != null) {
      // if there is a problem with the current camera state, we need to create a CameraStateError
      // to send to the Dart side.
      new CameraStateErrorFlutterApiWrapper(binaryMessenger, instanceManager)
          .create(error, Long.valueOf(error.getCode()), reply -> {});
    }

    cameraStateFlutterApi.create(
        instanceManager.addHostCreatedInstance(instance),
        new CameraStateTypeData.Builder().setValue(type).build(),
        instanceManager.getIdentifierForStrongReference(error),
        callback);
  }

  /** Converts CameraX CameraState.Type to CameraStateType that the Dart side understands. */
  @NonNull
  public static CameraStateType getCameraStateType(@NonNull CameraState.Type type) {
    CameraStateType cameraStateType = null;
    switch (type) {
      case CLOSED:
        cameraStateType = CameraStateType.CLOSED;
        break;
      case CLOSING:
        cameraStateType = CameraStateType.CLOSING;
        break;
      case OPEN:
        cameraStateType = CameraStateType.OPEN;
        break;
      case OPENING:
        cameraStateType = CameraStateType.OPENING;
        break;
      case PENDING_OPEN:
        cameraStateType = CameraStateType.PENDING_OPEN;
        break;
    }

    if (cameraStateType == null) {
      throw new IllegalArgumentException(
          "The CameraState.Type passed to this method was not recognized.");
    }
    return cameraStateType;
  }

  /** Sets the Flutter API used to send messages to Dart. */
  @VisibleForTesting
  void setApi(@NonNull CameraStateFlutterApi api) {
    this.cameraStateFlutterApi = api;
  }
}
