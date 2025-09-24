// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.fpsrange;

import android.annotation.SuppressLint;
import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.DeviceInfo;
import io.flutter.plugins.camera.features.CameraFeature;

/**
 * Controls the frames per seconds (FPS) range configuration on the {@link android.hardware.camera2}
 * API.
 */
public class FpsRangeFeature extends CameraFeature<Range<Integer>> {
  private static final Range<Integer> MAX_PIXEL4A_RANGE = new Range<>(30, 30);
  @Nullable private Range<Integer> currentSetting;

  /**
   * Creates a new instance of the {@link FpsRangeFeature}.
   *
   * @param cameraProperties Collection of characteristics for the current camera device.
   */
  public FpsRangeFeature(@NonNull CameraProperties cameraProperties) {
    super(cameraProperties);

    if (isPixel4A()) {
      // HACK: There is a bug in the Pixel 4A where it cannot support 60fps modes
      // even though they are reported as supported by
      // `getControlAutoExposureAvailableTargetFpsRanges`.
      // For max device compatibility we will keep FPS under 60 even if they report they are
      // capable of achieving 60 fps. Highest working FPS is 30.
      // https://issuetracker.google.com/issues/189237151
      currentSetting = MAX_PIXEL4A_RANGE;
    } else {
      Range<Integer>[] ranges = cameraProperties.getControlAutoExposureAvailableTargetFpsRanges();

      if (ranges != null) {
        for (Range<Integer> range : ranges) {
          int upper = range.getUpper();

          if (upper >= 10) {
            if (currentSetting == null || upper > currentSetting.getUpper()) {
              currentSetting = range;
            }
          }
        }
      }
    }
  }

  private boolean isPixel4A() {
    String brand = DeviceInfo.getBrand();
    String model = DeviceInfo.getModel();
    return brand != null && brand.equals("google") && model != null && model.equals("Pixel 4a");
  }

  @NonNull
  @Override
  public String getDebugName() {
    return "FpsRangeFeature";
  }

  @SuppressLint("KotlinPropertyAccess")
  @Nullable
  @Override
  public Range<Integer> getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(@NonNull Range<Integer> value) {
    this.currentSetting = value;
  }

  // Always supported
  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(@NonNull CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }

    requestBuilder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, currentSetting);
  }
}
