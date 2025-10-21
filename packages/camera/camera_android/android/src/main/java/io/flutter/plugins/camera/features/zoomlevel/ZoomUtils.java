// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.zoomlevel;

import android.graphics.Rect;
import androidx.annotation.NonNull;
import androidx.core.math.MathUtils;

/**
 * Utility class containing methods that assist with zoom features in the {@link
 * android.hardware.camera2} API.
 */
final class ZoomUtils {

  /**
   * Computes an image sensor area based on the supplied zoom settings.
   *
   * <p>The returned image sensor area can be applied to the {@link android.hardware.camera2} API in
   * order to control zoom levels. This method of zoom should only be used for Android versions <=
   * 11 as past that, the newer {@link #computeZoomRatio()} functional can be used.
   *
   * @param zoom The desired zoom level.
   * @param sensorArraySize The current area of the image sensor.
   * @param minimumZoomLevel The minimum supported zoom level.
   * @param maximumZoomLevel The maximim supported zoom level.
   * @return An image sensor area based on the supplied zoom settings
   */
  static Rect computeZoomRect(
      float zoom, @NonNull Rect sensorArraySize, float minimumZoomLevel, float maximumZoomLevel) {
    final float newZoom = computeZoomRatio(zoom, minimumZoomLevel, maximumZoomLevel);

    final int centerX = sensorArraySize.width() / 2;
    final int centerY = sensorArraySize.height() / 2;
    final int deltaX = (int) ((0.5f * sensorArraySize.width()) / newZoom);
    final int deltaY = (int) ((0.5f * sensorArraySize.height()) / newZoom);

    return new Rect(centerX - deltaX, centerY - deltaY, centerX + deltaX, centerY + deltaY);
  }

  static Float computeZoomRatio(float zoom, float minimumZoomLevel, float maximumZoomLevel) {
    return MathUtils.clamp(zoom, minimumZoomLevel, maximumZoomLevel);
  }
}
