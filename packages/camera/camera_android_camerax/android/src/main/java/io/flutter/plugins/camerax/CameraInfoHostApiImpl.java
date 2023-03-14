// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraState;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraInfoHostApi;
import java.util.Objects;

public class CameraInfoHostApiImpl implements CameraInfoHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private LifecycleOwner lifecycleOwner;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  public CameraInfoHostApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  /** Sets {@link LifecycleOwner} used to observe the camera state if so requested. */
  public void setLifecycleOwner(LifecycleOwner lifecycleOwner) {
    this.lifecycleOwner = lifecycleOwner;
  }

  @Override
  public Long getSensorRotationDegrees(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    return Long.valueOf(cameraInfo.getSensorRotationDegrees());
  }

  @Override
  public void startListeningForCameraClosing(@NonNull Long identifier) {
    CameraInfo cameraInfo =
        (CameraInfo) Objects.requireNonNull(instanceManager.getInstance(identifier));
    LiveData<CameraState> liveCameraState = cameraInfo.getCameraState();
    liveCameraState.observe(lifecycleOwner, createCameraStateObserver(identifier));
  }

  private Observer<CameraState> createCameraStateObserver(Long identifier) {
    return new Observer<CameraState>() {
      @Override
      public void onChanged(@NonNull CameraState cameraState) {
        if (cameraState.getType() == CameraState.Type.CLOSING) {
          CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl =
              new CameraInfoFlutterApiImpl(binaryMessenger, instanceManager);
          cameraInfoFlutterApiImpl.sendCameraClosingEvent(identifier, reply -> {});
        }
        CameraState.StateError cameraStateError = cameraState.getError();
        if (cameraStateError != null) {
          SystemServicesFlutterApiImpl systemServicesFlutterApi =
              cameraXProxy.createSystemServicesFlutterApiImpl(binaryMessenger);
          systemServicesFlutterApi.sendCameraError(
              getCameraStateErrorDescription(cameraStateError.getCode()), reply -> {});
        }
      }
    };
  }

  private String getCameraStateErrorDescription(@NonNull int cameraStateErrorCode) {
    // See CameraState errors: https://developer.android.com/reference/androidx/camera/core/CameraState#constants_1.
    switch (cameraStateErrorCode) {
      case CameraState.ERROR_CAMERA_IN_USE:
        return cameraStateErrorCode
            + ": The camera was already in use, possibly by a higher-priority camera client.";
      case CameraState.ERROR_MAX_CAMERAS_IN_USE:
        return cameraStateErrorCode
            + ": The limit number of open cameras has been reached, and more cameras cannot be opened until other instances are closed.";
      case CameraState.ERROR_OTHER_RECOVERABLE_ERROR:
        return cameraStateErrorCode
            + ": The camera device has encountered a recoverable error. CameraX will attempt to recover from the error.";
      case CameraState.ERROR_STREAM_CONFIG:
        return cameraStateErrorCode + ": Configuring the camera has failed.";
      case CameraState.ERROR_CAMERA_DISABLED:
        return cameraStateErrorCode
            + ": The camera device could not be opened due to a device policy. Thia may be caused by a client from a background process attempting to open the camera.";
      case CameraState.ERROR_CAMERA_FATAL_ERROR:
        return cameraStateErrorCode
            + ": The camera was closed due to a fatal error. This may require the Android device be shut down and restarted to restore camera function or may indicate a persistent camera hardware problem.";
      case CameraState.ERROR_DO_NOT_DISTURB_MODE_ENABLED:
        return cameraStateErrorCode
            + ": The camera could not be opened because 'Do Not Disturb' mode is enabled. Please disable this mode, and try opening the camera again.";
      default:
        return "There was an undefined issue with the camera state.";
    }
  }
}
