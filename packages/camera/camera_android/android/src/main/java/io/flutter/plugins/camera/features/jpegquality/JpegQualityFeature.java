// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.jpegquality;

import android.annotation.SuppressLint;
import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/** Controls the JPEG compression quality on the {@link android.hardware.camera2} API. */
public class JpegQualityFeature extends CameraFeature<Integer> {
  private int currentSetting = 100;

  /**
   * Creates a new instance of the {@link JpegQualityFeature}.
   *
   * @param cameraProperties Collection of characteristics for the current camera device.
   */
  public JpegQualityFeature(@NonNull CameraProperties cameraProperties) {
    super(cameraProperties);
  }

  @NonNull
  @Override
  public String getDebugName() {
    return "JpegQualityFeature";
  }

  @SuppressLint("KotlinPropertyAccess")
  @NonNull
  @Override
  public Integer getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(@NonNull Integer value) {
    this.currentSetting = value;
  }

  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(@NonNull CaptureRequest.Builder requestBuilder) {
    requestBuilder.set(CaptureRequest.JPEG_QUALITY, (byte) currentSetting);
  }
}
