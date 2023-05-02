// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class CameraCaptureProperties {

  private Float lastLensAperture;
  private Long lastSensorExposureTime;
  private Integer lastSensorSensitivity;

  /**
   * Gets the last known lens aperture. (As f-stop value)
   *
   * @return the last known lens aperture. (As f-stop value)
   */
  @Nullable
  public Float getLastLensAperture() {
    return lastLensAperture;
  }

  /**
   * Sets the last known lens aperture. (As f-stop value)
   *
   * @param lastLensAperture - The last known lens aperture to set. (As f-stop value)
   */
  public void setLastLensAperture(@NonNull Float lastLensAperture) {
    this.lastLensAperture = lastLensAperture;
  }

  /**
   * Gets the last known sensor exposure time in nanoseconds.
   *
   * @return the last known sensor exposure time in nanoseconds.
   */
  @Nullable
  public Long getLastSensorExposureTime() {
    return lastSensorExposureTime;
  }

  /**
   * Sets the last known sensor exposure time in nanoseconds.
   *
   * @param lastSensorExposureTime - The last known sensor exposure time to set, in nanoseconds.
   */
  public void setLastSensorExposureTime(@NonNull Long lastSensorExposureTime) {
    this.lastSensorExposureTime = lastSensorExposureTime;
  }

  /**
   * Gets the last known sensor sensitivity in ISO arithmetic units.
   *
   * @return the last known sensor sensitivity in ISO arithmetic units.
   */
  @Nullable
  public Integer getLastSensorSensitivity() {
    return lastSensorSensitivity;
  }

  /**
   * Sets the last known sensor sensitivity in ISO arithmetic units.
   *
   * @param lastSensorSensitivity - The last known sensor sensitivity to set, in ISO arithmetic
   *     units.
   */
  public void setLastSensorSensitivity(@NonNull Integer lastSensorSensitivity) {
    this.lastSensorSensitivity = lastSensorSensitivity;
  }
}
