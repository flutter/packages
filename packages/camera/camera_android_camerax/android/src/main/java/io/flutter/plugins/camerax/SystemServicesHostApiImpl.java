// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.CameraPermissionsManager.PermissionsRegistry;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraPermissionsErrorData;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Result;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesHostApi;
import java.io.File;
import java.io.IOException;

public class SystemServicesHostApiImpl implements SystemServicesHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private Context context;

  @VisibleForTesting public @NonNull CameraXProxy cameraXProxy = new CameraXProxy();
  @VisibleForTesting public @Nullable DeviceOrientationManager deviceOrientationManager;
  @VisibleForTesting public @NonNull SystemServicesFlutterApiImpl systemServicesFlutterApi;

  private Activity activity;
  private PermissionsRegistry permissionsRegistry;

  public SystemServicesHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
    this.systemServicesFlutterApi = new SystemServicesFlutterApiImpl(binaryMessenger);
  }

  /** Sets the context, which is used to get the cache directory. */
  public void setContext(@NonNull Context context) {
    this.context = context;
  }

  public void setActivity(@NonNull Activity activity) {
    this.activity = activity;
  }

  public void setPermissionsRegistry(@NonNull PermissionsRegistry permissionsRegistry) {
    this.permissionsRegistry = permissionsRegistry;
  }

  /**
   * Requests camera permissions using an instance of a {@link CameraPermissionsManager}.
   *
   * <p>Will result with {@code null} if permissions were approved or there were no errors;
   * otherwise, it will result with the error data explaining what went wrong.
   */
  @Override
  public void requestCameraPermissions(
      @NonNull Boolean enableAudio, @NonNull Result<CameraPermissionsErrorData> result) {
    CameraPermissionsManager cameraPermissionsManager =
        cameraXProxy.createCameraPermissionsManager();
    cameraPermissionsManager.requestPermissions(
        activity,
        permissionsRegistry,
        enableAudio,
        (String errorCode, String description) -> {
          if (errorCode == null) {
            result.success(null);
          } else {
            // If permissions are ongoing or denied, error data will be sent to be handled.
            CameraPermissionsErrorData errorData =
                new CameraPermissionsErrorData.Builder()
                    .setErrorCode(errorCode)
                    .setDescription(description)
                    .build();
            result.success(errorData);
          }
        });
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
              systemServicesFlutterApi.sendDeviceOrientationChangedEvent(
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

  /** Returns a path to be used to create a temp file in the current cache directory. */
  @Override
  @NonNull
  public String getTempFilePath(@NonNull String prefix, @NonNull String suffix) {
    try {
      File path = File.createTempFile(prefix, suffix, context.getCacheDir());
      return path.toString();
    } catch (IOException | SecurityException e) {
      throw new GeneratedCameraXLibrary.FlutterError(
          "getTempFilePath_failure",
          "SystemServicesHostApiImpl.getTempFilePath encountered an exception: " + e.toString(),
          null);
    }
  }
}
