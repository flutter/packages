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
      @NonNull CameraState.Type type,
      @Nullable CameraState.StateError error,
      @NonNull CameraStateFlutterApi.Reply<Void> callback) {

    // Convert CameraX CameraState.Type to CameraStateType that the Dart side understands.
    CameraStateType cameraStateType = CameraStateType.CLOSED;
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

    if (error != null) {
      // We need to create a CameraStateError if there is a problem with the current camera
      // state to send to the Dart side.
      new CameraStateErrorFlutterApiWrapper(binaryMessenger, instanceManager)
          .create(
              error,
              Long.valueOf(error.getCode()),
              getCameraStateErrorDescription(error),
              reply -> {});
    }

    if (!instanceManager.containsInstance(instance)) {
      cameraStateFlutterApi.create(
          instanceManager.addHostCreatedInstance(instance),
          new CameraStateTypeData.Builder().setValue(cameraStateType).build(),
          instanceManager.getIdentifierForStrongReference(error),
          callback);
    }
  }

  /**
   * Returns an error message corresponding to the specified {@link CameraState.StateError}.
   *
   * <p>See https://developer.android.com/reference/androidx/camera/core/CameraState#constants_1 for
   * more information on the different {@link CameraState.StateError} types.
   */
  private String getCameraStateErrorDescription(@NonNull CameraState.StateError cameraStateError) {
    final int cameraStateErrorCode = cameraStateError.getCode();
    final String cameraStateErrorDescription = cameraStateErrorCode + ": ";
    switch (cameraStateErrorCode) {
      case CameraState.ERROR_CAMERA_IN_USE:
        return cameraStateErrorDescription
            + "The camera was already in use, possibly by a higher-priority camera client.";
      case CameraState.ERROR_MAX_CAMERAS_IN_USE:
        return cameraStateErrorDescription
            + "The limit number of open cameras has been reached, and more cameras cannot be opened until other instances are closed.";
      case CameraState.ERROR_OTHER_RECOVERABLE_ERROR:
        return cameraStateErrorDescription
            + "The camera device has encountered a recoverable error. CameraX will attempt to recover from the error.";
      case CameraState.ERROR_STREAM_CONFIG:
        return cameraStateErrorDescription + "Configuring the camera has failed.";
      case CameraState.ERROR_CAMERA_DISABLED:
        return cameraStateErrorDescription
            + "The camera device could not be opened due to a device policy. Thia may be caused by a client from a background process attempting to open the camera.";
      case CameraState.ERROR_CAMERA_FATAL_ERROR:
        return cameraStateErrorDescription
            + "The camera was closed due to a fatal error. This may require the Android device be shut down and restarted to restore camera function or may indicate a persistent camera hardware problem.";
      case CameraState.ERROR_DO_NOT_DISTURB_MODE_ENABLED:
        return cameraStateErrorDescription
            + "The camera could not be opened because 'Do Not Disturb' mode is enabled. Please disable this mode, and try opening the camera again.";
      default:
        return cameraStateErrorDescription + "There was an unspecified issue with the current camera state.";
    }
  }

  /**
   * Sets the Flutter API used to send messages to Dart.
   *
   * <p>This is only visible for testing.
   */
  @VisibleForTesting
  void setApi(@NonNull CameraStateFlutterApi api) {
    this.cameraStateFlutterApi = api;
  }
}
