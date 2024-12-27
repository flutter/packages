package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.io.File;
import java.io.IOException;

public abstract class SystemServicesManager {
  @NonNull private final CameraPermissionsManager cameraPermissionsManager;

  public interface PermissionsResultListener {
    void onResult(boolean isSuccessful);
  }

  protected SystemServicesManager(@NonNull CameraPermissionsManager cameraPermissionsManager) {
    this.cameraPermissionsManager = cameraPermissionsManager;
  }

  abstract void onCameraError(@NonNull String description);

  @NonNull
  abstract Context getContext();

  @Nullable
  abstract CameraPermissionsManager.PermissionsRegistry getPermissionsRegistry();

  public void requestCameraPermissions(
      @NonNull Boolean enableAudio, @NonNull PermissionsResultListener listener) {
    if (!(getContext() instanceof Activity)) {
      throw new IllegalStateException("Activity must be set to request camera permissions.");
    }

    cameraPermissionsManager.requestPermissions(
        (Activity) getContext(),
        getPermissionsRegistry(),
        enableAudio,
        (String errorCode, String description) -> listener.onResult(errorCode == null));
  }

  @NonNull
  public String getTempFilePath(@NonNull String prefix, @NonNull String suffix) throws IOException {
    final File path = File.createTempFile(prefix, suffix, getContext().getCacheDir());
    return path.toString();
  }

  @NonNull
  public Boolean isPreviewPreTransformed() {
    return Build.VERSION.SDK_INT < 29;
  }
}
