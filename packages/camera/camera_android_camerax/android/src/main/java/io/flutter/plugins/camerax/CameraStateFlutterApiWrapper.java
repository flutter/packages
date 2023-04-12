
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

    CameraStateType cameraStateType;
    switch (type) {
      case CameraState.Type.CLOSED:
        cameraStateType = CameraState.Type.CLOSED;
        break;
      case CameraState.Type.CLOSING:
        cameraStateType = CameraState.Type.CLOSING;
        break;
      case CameraState.Type.OPEN:
        cameraStateType = CameraState.Type.CLOSED;
        break;
      case CameraState.Type.OPENING:
        cameraStateType = CameraState.Type.CLOSED;
        break;
      case CameraState.Type.PENDING_OPEN:
        cameraStateType = CameraState.Type.CLOSED;
        break;
    }

    if (error != null) {
      new CameraStateErrorFlutterApiWrapper(binaryMessenger, instanceManager).create(error, Long.valueOf(error.getCode()), getCameraStateErrorDescription(error), reply -> {});
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
        return "There was an undefined issue with the camera state.";
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
