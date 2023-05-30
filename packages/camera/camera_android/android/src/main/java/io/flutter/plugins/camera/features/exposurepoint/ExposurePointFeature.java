// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.exposurepoint;

import android.annotation.SuppressLint;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.CameraRegionUtils;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.sensororientation.SensorOrientationFeature;
// <-- add this import statement

/** Exposure point controls where in the frame exposure metering will come from. */
public class ExposurePointFeature extends CameraFeature<Point> {

  private Size cameraBoundaries;
  @Nullable private Point exposurePoint;
  private MeteringRectangle exposureRectangle;
  private MeteringRectangle[] defaultExposureRectangle;
  @NonNull private final SensorOrientationFeature sensorOrientationFeature;

  /**
   * Creates a new instance of the {@link ExposurePointFeature}.
   *
   * @param cameraProperties Collection of the characteristics for the current camera device.
   */
  public ExposurePointFeature(
      @NonNull CameraProperties cameraProperties,
      @NonNull SensorOrientationFeature sensorOrientationFeature) {
    super(cameraProperties);
    this.sensorOrientationFeature = sensorOrientationFeature;
    this.defaultExposureRectangle = createDefaultExposureRectangle();
  }

  /**
   * Sets the camera boundaries that are required for the exposure point feature to function.
   *
   * @param cameraBoundaries - The camera boundaries to set.
   */
  public void setCameraBoundaries(@NonNull Size cameraBoundaries) {
    this.cameraBoundaries = cameraBoundaries;
    this.buildExposureRectangle();
  }

  @NonNull
  @Override
  public String getDebugName() {
    return "ExposurePointFeature";
  }

  @SuppressLint("KotlinPropertyAccess")
  @Nullable
  @Override
  public Point getValue() {
    return exposurePoint;
  }

  @Override
  public void setValue(@Nullable Point value) {
    this.exposurePoint = (value == null || value.x == null || value.y == null) ? null : value;
    this.buildExposureRectangle();
  }

  // Whether or not this camera can set the exposure point.
  @Override
  public boolean checkIsSupported() {
    Integer supportedRegions = cameraProperties.getControlMaxRegionsAutoExposure();
    return supportedRegions != null && supportedRegions > 0;
  }

  @Override
  public void updateBuilder(@NonNull CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }

    if (exposureRectangle != null) {
      requestBuilder.set(
          CaptureRequest.CONTROL_AE_REGIONS, new MeteringRectangle[] {exposureRectangle});
    } else if (shouldReset(requestBuilder)) {
      requestBuilder.set(CaptureRequest.CONTROL_AE_REGIONS, defaultExposureRectangle);
    }
  }

  private void buildExposureRectangle() {
    if (this.cameraBoundaries == null) {
      throw new AssertionError(
          "The cameraBoundaries should be set (using `ExposurePointFeature.setCameraBoundaries(Size)`) before updating the exposure point.");
    }
    if (this.exposurePoint == null) {
      this.exposureRectangle = null;
    } else {
      PlatformChannel.DeviceOrientation orientation =
          this.sensorOrientationFeature.getLockedCaptureOrientation();
      if (orientation == null) {
        orientation =
            this.sensorOrientationFeature.getDeviceOrientationManager().getLastUIOrientation();
      }
      this.exposureRectangle =
          CameraRegionUtils.convertPointToMeteringRectangle(
              this.cameraBoundaries, this.exposurePoint.x, this.exposurePoint.y, orientation);
    }
  }

  /**
   * Determines whether the exposure rectangle should be reset based on the current state of the
   * {@link CaptureRequest.Builder} and the previously set exposure rectangle.
   *
   * @param requestBuilder the current {@link CaptureRequest.Builder}
   * @return true if the exposure rectangle should be reset, false otherwise
   */
  public boolean shouldReset(@NonNull CaptureRequest.Builder requestBuilder) {
    MeteringRectangle[] currentRectangles = requestBuilder.get(CaptureRequest.CONTROL_AE_REGIONS);

    if (currentRectangles == null || currentRectangles.length == 0) {
      return true;
    }

    if (exposureRectangle == null) {
      // If exposureRectangle is null, reset if any rectangles are currently set
      return true;
    }

    for (MeteringRectangle rect : currentRectangles) {
      if (rect.equals(exposureRectangle)) {
        return false;
      }
    }

    return true;
  }

  /**
   * Returns the default exposure rectangle(s).
   *
   * @return An array of default MeteringRectangle objects.
   */
  @Nullable
  public MeteringRectangle[] createDefaultExposureRectangle() {
    try {
      // Create and return your desired default exposure rectangles here
      // Example: a single default rectangle covering the entire image
      if (cameraBoundaries != null) {
        int left = 0;
        int top = 0;
        int right = cameraBoundaries.getWidth();
        int bottom = cameraBoundaries.getHeight();
        return new MeteringRectangle[] {new MeteringRectangle(left, top, right, bottom, 0)};
      }
    } catch (Exception e) {
      throw new AssertionError(
          "Failed to create default exposure rectangle(s) for the ExposurePointFeature.");
    }

    return null;
  }
}
