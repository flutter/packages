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
          SystemServicesFlutterApiImpl systemServicesFlutterApi =
              cameraXProxy.createSystemServicesFlutterApiImpl(binaryMessenger);
          systemServicesFlutterApi.sendCameraError(
              getCameraStateErrorDescription(cameraStateError), reply -> {});
        }
      }
    };
  }

  /** Returns an error message corresponding to the specified {@link CameraState.StateError}. */
  private String getCameraStateErrorDescription(@NonNull CameraState.StateError cameraStateError) {
    return cameraStateError.getCode() + ": " + cameraStateError.getCause().getMessage();
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
