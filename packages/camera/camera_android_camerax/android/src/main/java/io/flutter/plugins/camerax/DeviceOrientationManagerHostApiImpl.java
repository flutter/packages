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

import android.util.Log;

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
    deviceOrientationManager =
        cameraXProxy.createDeviceOrientationManager(
            activity,
            isFrontFacing,
            sensorOrientation.intValue(),
            (DeviceOrientation newOrientation) -> {
              Log.e("CAMILLE HI", serializeDeviceOrientation(newOrientation));
              deviceOrientationManagerFlutterApiImpl.sendDeviceOrientationChangedEvent(
                  serializeDeviceOrientation(newOrientation), reply -> {});
            });
    deviceOrientationManager.start();
  }

  /** Serializes {@code DeviceOrientation} into a String that the Dart side is able to recognize. */
  String serializeDeviceOrientation(DeviceOrientation orientation) {
    return orientation.toString();
  }

  DeviceOrientation deserializeDeviceOrientationString(@Nullable String orientation) {
    if (orientation == null) {
      return null;
    }
    switch(orientation) {
      case "LANDSCAPE_LEFT":
        return DeviceOrientation.LANDSCAPE_LEFT;
      case "LANDSCAPE_RIGHT":
        return DeviceOrientation.LANDSCAPE_RIGHT;
      case "PORTRAIT_DOWN":
        return DeviceOrientation.PORTRAIT_DOWN;
      case "PORTRAIT_UP":
        return DeviceOrientation.PORTRAIT_UP;
      default:
          throw new IllegalArgumentException(
              "Specified device orientation is unspecified.");
    }
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
   * Returns device's photo orientation in degrees based on the sensor orientation and
   * last known UI orientation.
   */
  @Override
  public @NonNull Long getPhotoOrientation(@Nullable String orientation) {
    if (deviceOrientationManager == null) {
      throw new NullPointerException(
          "startListeningForDeviceOrientationChange must first be called to subscribe to device orientation changes in order to retrieve the photo orientation.");
    }
    if (orientation == null) {
      return Long.valueOf(deviceOrientationManager.getPhotoOrientation());
    }
    return Long.valueOf(deviceOrientationManager.getPhotoOrientation(deserializeDeviceOrientationString(orientation)));
  }

  /**
   * Returns device's video orientation in clockwise degrees based on the sensor orientation
   * and last known UI orientation.
  */
  @Override
  public @NonNull Long getVideoOrientation(@Nullable String orientation) {
    if (deviceOrientationManager == null) {
      throw new NullPointerException(
          "startListeningForDeviceOrientationChange must first be called to subscribe to device orientation changes in order to retrieve the video orientation.");
    }
    if (orientation == null) {
      return Long.valueOf(deviceOrientationManager.getVideoOrientation());
    }
    return Long.valueOf(deviceOrientationManager.getVideoOrientation(deserializeDeviceOrientationString(orientation)));
  }

  @Override 
  public @NonNull Long getDefaultRotation() {
        if (deviceOrientationManager == null) {
      throw new NullPointerException(
          "startListeningForDeviceOrientationChange must first be called to subscribe to device orientation changes in order to retrieve the video orientation.");
    }
    return deviceOrientationManager.getDefaultRotation();
  }
}
