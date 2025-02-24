// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.CameraPermissionsManager.PermissionsRegistry;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraPermissionsErrorData;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Result;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesHostApi;
import java.io.File;
import java.io.IOException;

public class SystemServicesHostApiImpl implements SystemServicesHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  @Nullable private Context context;

  @VisibleForTesting public @NonNull CameraXProxy cameraXProxy = new CameraXProxy();
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

  public void setPermissionsRegistry(@Nullable PermissionsRegistry permissionsRegistry) {
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
    if (activity == null) {
      throw new IllegalStateException("Activity must be set to request camera permissions.");
    }

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

  /** Returns a path to be used to create a temp file in the current cache directory. */
  @Override
  @NonNull
  public String getTempFilePath(@NonNull String prefix, @NonNull String suffix) {
    if (context == null) {
      throw new IllegalStateException("Context must be set to create a temporary file.");
    }

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
