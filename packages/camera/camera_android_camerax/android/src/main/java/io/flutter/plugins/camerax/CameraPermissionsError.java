// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.Objects;

/** Contains data when an attempt to retrieve camera permissions fails. */
public class CameraPermissionsError {
  private final String errorCode;
  private final String description;

  public CameraPermissionsError(@NonNull String errorCode, @NonNull String description) {
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

  @Override
  public boolean equals(@Nullable Object obj) {
    if (obj instanceof CameraPermissionsError) {
      return Objects.equals(((CameraPermissionsError) obj).errorCode, errorCode)
          && Objects.equals(((CameraPermissionsError) obj).description, description);
    }

    return false;
  }

  @Override
  public int hashCode() {
    return Objects.hash(errorCode, description);
  }
}
