// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraState;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveCameraStateHostApi;
import java.util.Objects;

public class LiveCameraStateHostApiImpl implements LiveCameraStateHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private LifecycleOwner lifecycleOwner;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  public LiveCameraStateHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  /** Sets {@link LifecycleOwner} used to observe the camera state if so requested. */
  public void setLifecycleOwner(LifecycleOwner lifecycleOwner) {
    this.lifecycleOwner = lifecycleOwner;
  }

  /**
   * Adds an observer to the {@link LiveData} of the {@link CameraState} that is represented by the
   * specified identifier.
   *
   * <p>This observer is created with {@link
   * LiveCameraStateHostApiImpl#getCameraStateErrorDescription(int)}, and it will only observe
   * within the lifetime of the {@link LiveCameraStateHostApiImpl#lifecycleOwner}.
   */
  @Override
  public void addObserver(@NonNull Long identifier) {
    @SuppressWarnings("unchecked")
    LiveData<CameraState> liveCameraState =
        (LiveData<CameraState>) Objects.requireNonNull(instanceManager.getInstance(identifier));
    liveCameraState.observe(lifecycleOwner, createCameraStateObserver());
  }

  /**
   * Creates an {@link Observer} of the different {@link CameraState}s that a camera may
   * encountered.
   *
   * <p>This observer notifies the Dart side when the camera is closing with an instance of {@link
   * LiveCameraStateFlutterApiImpl}, and notifies the Dart side when the camera encounters a error
   * when transitioning between states with an intance of {@link SystemServicesFlutterApiImpl}.
   */
  private Observer<CameraState> createCameraStateObserver() {
    return new Observer<CameraState>() {
      @Override
      public void onChanged(@NonNull CameraState cameraState) {
        if (cameraState.getType() == CameraState.Type.CLOSING) {
          LiveCameraStateFlutterApiImpl liveCameraStateFlutterApiImpl =
              cameraXProxy.createLiveCameraStateFlutterApiImpl(binaryMessenger, instanceManager);
          liveCameraStateFlutterApiImpl.sendCameraClosingEvent(reply -> {});
        }
        CameraState.StateError cameraStateError = cameraState.getError();
        if (cameraStateError != null) {
          SystemServicesFlutterApiImpl systemServicesFlutterApiImpl =
              cameraXProxy.createSystemServicesFlutterApiImpl(binaryMessenger);
          systemServicesFlutterApiImpl.sendCameraError(
              getCameraStateErrorDescription(cameraStateError), reply -> {});
        }
      }
    };
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
   * Removes any observers of the {@link LiveData} of the {@link CameraState} that is represented by
   * the specified identifier within the lifetime of the {@link
   * LiveCameraStateHostApiImpl#lifecycleOwner}.
   */
  @Override
  @SuppressWarnings("unchecked")
  public void removeObservers(@NonNull Long identifier) {
    LiveData<CameraState> liveCameraState =
        (LiveData<CameraState>) Objects.requireNonNull(instanceManager.getInstance(identifier));
    liveCameraState.removeObservers(lifecycleOwner);
  }
}
