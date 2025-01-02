// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.CameraPermissionsManager.PermissionsRegistry;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.DeviceOrientationManagerHostApi;

public class DeviceOrientationManagerHostApiImpl implements DeviceOrientationManagerHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting public @NonNull CameraXProxy cameraXProxy = new CameraXProxy();
  @VisibleForTesting public @Nullable DeviceOrientationManager deviceOrientationManager;

  @VisibleForTesting
  public @NonNull DeviceOrientationManagerFlutterApiImpl deviceOrientationManagerFlutterApiImpl;

  private Activity activity;
  private PermissionsRegistry permissionsRegistry;

  public DeviceOrientationManagerHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.deviceOrientationManagerFlutterApiImpl =
        new DeviceOrientationManagerFlutterApiImpl(binaryMessenger);
  }

  public void setActivity(@NonNull Activity activity) {
    this.activity = activity;
  }

  /**
   * Starts listening for device orientation changes using an instance of a {@link
   * DeviceOrientationManager}.
   *
   * <p>Whenever a change in device orientation is detected by the {@code DeviceOrientationManager},
   * the {@link SystemServicesFlutterApi} will be used to notify the Dart side.
   */
  @Override
  public void startListeningForDeviceOrientationChange(
      @NonNull Boolean isFrontFacing, @NonNull Long sensorOrientation) {
    if (activity == null) {
      throw new IllegalStateException(
          "Activity must be set to start listening for device orientation changes.");
    }

    deviceOrientationManager =
        cameraXProxy.createDeviceOrientationManager(
            activity,
            isFrontFacing,
            sensorOrientation.intValue(),
            (DeviceOrientation newOrientation) -> {
              deviceOrientationManagerFlutterApiImpl.sendDeviceOrientationChangedEvent(
                  serializeDeviceOrientation(newOrientation), reply -> {});
            });
    deviceOrientationManager.start();
  }

  /** Serializes {@code DeviceOrientation} into a String that the Dart side is able to recognize. */
  String serializeDeviceOrientation(DeviceOrientation orientation) {
    return orientation.toString();
  }

  /**
   * Tells the {@code deviceOrientationManager} to stop listening for orientation updates.
   *
   * <p>Has no effect if the {@code deviceOrientationManager} was never created to listen for device
   * orientation updates.
   */
  @Override
  public void stopListeningForDeviceOrientationChange() {
    if (deviceOrientationManager != null) {
      deviceOrientationManager.stop();
    }
  }

  /**
   * Gets default capture rotation for CameraX {@code UseCase}s.
   *
   * <p>The default capture rotation for CameraX is the rotation of default {@code Display} at the
   * time that a {@code UseCase} is bound, but the default {@code Display} does not change in this
   * plugin, so this value is {@code Display}-agnostic.
   *
   * <p>See
   * https://developer.android.com/reference/androidx/camera/core/ImageCapture#setTargetRotation(int)
   * for instance for more information on how this default value is used.
   */
  @Override
  @NonNull
  public Long getDefaultDisplayRotation() {
    int defaultRotation;
    try {
      defaultRotation = deviceOrientationManager.getDefaultRotation();
    } catch (NullPointerException e) {
      throw new IllegalStateException(
          "startListeningForDeviceOrientationChange must first be called to subscribe to device orientation changes in order to retrieve default rotation.");
    }

    return Long.valueOf(defaultRotation);
  }

  /** Gets current UI orientation based on the current device orientation and rotation. */
  @Override
  @NonNull
  public String getUiOrientation() {
    return serializeDeviceOrientation(deviceOrientationManager.getUIOrientation());
  }
}
