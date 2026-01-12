// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.io.File;
import java.io.IOException;

/** Utility class used to access system services not provided by the camerax library. */
public abstract class SystemServicesManager {
  @NonNull private final CameraPermissionsManager cameraPermissionsManager;

  /** Handles result of a permissions request. */
  public interface PermissionsResultListener {
    void onResult(boolean isSuccessful, @Nullable CameraPermissionsError error);
  }

  protected SystemServicesManager(@NonNull CameraPermissionsManager cameraPermissionsManager) {
    this.cameraPermissionsManager = cameraPermissionsManager;
  }

  abstract void onCameraError(@NonNull String description);

  @NonNull
  abstract Context getContext();

  @Nullable
  abstract CameraPermissionsManager.PermissionsRegistry getPermissionsRegistry();

  /**
   * Requests camera permissions using an instance of a {@link CameraPermissionsManager}.
   *
   * <p>Will result with {@code null} if permissions were approved or there were no errors;
   * otherwise, it will result with the error data explaining what went wrong.
   */
  public void requestCameraPermissions(
      @NonNull Boolean enableAudio, @NonNull PermissionsResultListener listener) {
    if (!(getContext() instanceof Activity)) {
      throw new IllegalStateException("Activity must be set to request camera permissions.");
    }

    cameraPermissionsManager.requestPermissions(
        (Activity) getContext(),
        getPermissionsRegistry(),
        enableAudio,
        (CameraPermissionsError error) -> listener.onResult(error == null, error));
  }

  /** Returns a path to be used to create a temp file in the current cache directory. */
  @NonNull
  public String getTempFilePath(@NonNull String prefix, @NonNull String suffix) throws IOException {
    final File path = File.createTempFile(prefix, suffix, getContext().getCacheDir());
    return path.toString();
  }
}
