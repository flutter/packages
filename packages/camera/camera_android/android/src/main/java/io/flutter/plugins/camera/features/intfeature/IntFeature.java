// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.intfeature;

import android.annotation.SuppressLint;
import android.hardware.camera2.CaptureRequest;
import androidx.annotation.Nullable;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/**
 * Used to control the fps, videoBitrate and audioBitrate configuration on the {@link
 * android.hardware.camera2} API.
 */
public class IntFeature extends CameraFeature<Integer> {

  private Integer currentValue;

  public IntFeature(CameraProperties cameraProperties, Integer value) {
    super(cameraProperties);
    currentValue = value;
  }

  @Override
  public String getDebugName() {
    return "IntFeature";
  }

  @SuppressLint("KotlinPropertyAccess")
  @Nullable
  @Override
  public Integer getValue() {
    return currentValue;
  }

  @Override
  public void setValue(Integer value) {
    currentValue = value;
  }

  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {}
}
