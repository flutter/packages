// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.CameraState;
import androidx.camera.core.ZoomState;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedTypeData;
import java.util.Objects;

/**
 * Host API implementation for {@link LiveData}.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class LiveDataHostApiImpl implements LiveDataHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private LifecycleOwner lifecycleOwner;

  /**
   * Constructs a {@link LiveDataHostApiImpl}.
   *
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param instanceManager maintains instances stored to communicate with attached Dart objects
   */
  public LiveDataHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  /** Sets {@link LifecycleOwner} used to observe the camera state if so requested. */
  public void setLifecycleOwner(@NonNull LifecycleOwner lifecycleOwner) {
    this.lifecycleOwner = lifecycleOwner;
  }

  /**
   * Adds an {@link Observer} with the specified identifier to the observers list of this instance
   * within the lifespan of the {@link lifecycleOwner}.
   */
  @Override
  @SuppressWarnings("unchecked")
  public void observe(@NonNull Long identifier, @NonNull Long observerIdentifier) {
    getLiveDataInstance(identifier)
        .observe(
            lifecycleOwner,
            Objects.requireNonNull(instanceManager.getInstance(observerIdentifier)));
  }

  /** Removes all observers of this instance that are tied to the {@link lifecycleOwner}. */
  @Override
  public void removeObservers(@NonNull Long identifier) {
    getLiveDataInstance(identifier).removeObservers(lifecycleOwner);
  }

  @Override
  @Nullable
  public Long getValue(@NonNull Long identifier, @NonNull LiveDataSupportedTypeData type) {
    Object value = getLiveDataInstance(identifier).getValue();
    if (value == null) {
      return null;
    }

    LiveDataSupportedType valueType = type.getValue();
    switch (valueType) {
      case CAMERA_STATE:
        return createCameraState((CameraState) value);
      case ZOOM_STATE:
        return createZoomState((ZoomState) value);
      default:
        throw new IllegalArgumentException(
            "The type of LiveData whose value was requested is not supported.");
    }
  }

  /** Creates a {@link CameraState} on the Dart side and returns its identifier. */
  private Long createCameraState(CameraState cameraState) {
    new CameraStateFlutterApiWrapper(binaryMessenger, instanceManager)
        .create(
            cameraState,
            CameraStateFlutterApiWrapper.getCameraStateType(cameraState.getType()),
            cameraState.getError(),
            reply -> {});
    return instanceManager.getIdentifierForStrongReference(cameraState);
  }

  /** Creates a {@link ZoomState} on the Dart side and returns its identifiers. */
  private Long createZoomState(ZoomState zoomState) {
    new ZoomStateFlutterApiImpl(binaryMessenger, instanceManager).create(zoomState, reply -> {});
    return instanceManager.getIdentifierForStrongReference(zoomState);
  }

  /** Retrieves the {@link LiveData} instance that has the specified identifier. */
  private LiveData<?> getLiveDataInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
