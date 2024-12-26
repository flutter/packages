package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.IOException;

public abstract class SystemServicesManager {
  @NonNull
  private final CameraPermissionsManager cameraPermissionsManager;

  interface PermissionsResultListener {
    void onResult(@Nullable CameraPermissionsErrorData data);
  }

  protected SystemServicesManager(@NonNull CameraPermissionsManager cameraPermissionsManager) {
    this.cameraPermissionsManager = cameraPermissionsManager;
  }

  abstract void onCameraError(@NonNull String description);

  @Nullable
  abstract Context getContext();

  @Nullable
  abstract CameraPermissionsManager.PermissionsRegistry getPermissionsRegistry();

  public void requestCameraPermissions(@NonNull Boolean enableAudio, @NonNull PermissionsResultListener listener) {
    if (getContext() == null || !(getContext() instanceof Activity)) {
      throw new IllegalStateException("Activity must be set to request camera permissions.");
    }

    cameraPermissionsManager.requestPermissions(
        (Activity) getContext(),
        getPermissionsRegistry(),
        enableAudio,
        (String errorCode, String description) -> {
          if (errorCode == null) {
            listener.onResult(null);
          } else {
            // If permissions are ongoing or denied, error data will be sent to be handled.
            listener.onResult(new CameraPermissionsErrorData(errorCode, description));
          }
        });
  }

  // TODO: throwing of cameraxerror should be handled by proxyapi impl
  @NonNull
  public String getTempFilePath(@NonNull String prefix, @NonNull String suffix) throws CameraXError {
    if (getContext() == null) {
      throw new IllegalStateException("Context must be set to create a temporary file.");
    }

    try {
      final File path = File.createTempFile(prefix, suffix, getContext().getCacheDir());
      return path.toString();
    } catch (IOException | SecurityException e) {
      throw new CameraXError("getTempFilePath_failure", "SystemServicesHostApiImpl.getTempFilePath encountered an exception: " + e, null);
    }
  }

  @NonNull
  public Boolean isPreviewPreTransformed() {
    return Build.VERSION.SDK_INT < 29;
  }
}
