package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;

public class CameraPermissionsErrorData {
  @NonNull
  private final String errorCode;
  @NonNull
  private final String description;

  CameraPermissionsErrorData(@NonNull String errorCode, @NonNull String description) {
    this.errorCode = errorCode;
    this.description = description;
  }

  @NonNull
  public String getErrorCode() {
    return errorCode;
  }

  @NonNull
  public String getDescription() {
    return description;
  }
}
