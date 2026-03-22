// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.media.Image;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * Pairs a still JPEG {@link Image} with the {@link TotalCaptureResult} for that exposure using
 * matching timestamps ({@link Image#getTimestamp()} and {@link CaptureResult#SENSOR_TIMESTAMP}).
 *
 * <p>Camera2 does not define an ordering between {@code onImageAvailable} and {@code
 * onCaptureCompleted}; this class buffers whichever arrives first until the other is available.
 */
final class StillCaptureExposurePairing {

  @FunctionalInterface
  interface SaveSink {
    void save(@NonNull Image image, @Nullable Long exposureTimeNs);
  }

  private final Map<Long, TotalCaptureResult> resultsByTimestamp = new HashMap<>();
  private final Map<Long, Image> imagesPendingResult = new HashMap<>();
  @Nullable private Long fallbackExposureTimeNs;

  void reset() {
    for (Image image : imagesPendingResult.values()) {
      image.close();
    }
    imagesPendingResult.clear();
    resultsByTimestamp.clear();
    fallbackExposureTimeNs = null;
  }

  void onTotalCaptureResult(@NonNull TotalCaptureResult result, @NonNull SaveSink saveSink) {
    Long timestamp = result.get(CaptureResult.SENSOR_TIMESTAMP);
    if (timestamp != null) {
      Image pendingImage = imagesPendingResult.remove(timestamp);
      if (pendingImage != null) {
        saveSink.save(pendingImage, result.get(CaptureResult.SENSOR_EXPOSURE_TIME));
      } else {
        resultsByTimestamp.put(timestamp, result);
      }
    } else {
      fallbackExposureTimeNs = result.get(CaptureResult.SENSOR_EXPOSURE_TIME);
      drainSinglePendingImageWithFallback(saveSink);
    }
  }

  void onImageAvailable(@NonNull Image image, @NonNull SaveSink saveSink) {
    long timestamp = image.getTimestamp();
    if (timestamp != 0) {
      TotalCaptureResult result = resultsByTimestamp.remove(timestamp);
      if (result != null) {
        saveSink.save(image, result.get(CaptureResult.SENSOR_EXPOSURE_TIME));
        return;
      }
      if (fallbackExposureTimeNs != null) {
        Long exposure = fallbackExposureTimeNs;
        fallbackExposureTimeNs = null;
        saveSink.save(image, exposure);
        return;
      }
      imagesPendingResult.put(timestamp, image);
      return;
    }
    Long exposure = fallbackExposureTimeNs;
    fallbackExposureTimeNs = null;
    saveSink.save(image, exposure);
  }

  private void drainSinglePendingImageWithFallback(@NonNull SaveSink saveSink) {
    if (imagesPendingResult.isEmpty()) {
      return;
    }
    Iterator<Map.Entry<Long, Image>> iterator = imagesPendingResult.entrySet().iterator();
    Map.Entry<Long, Image> entry = iterator.next();
    iterator.remove();
    saveSink.save(entry.getValue(), fallbackExposureTimeNs);
    fallbackExposureTimeNs = null;
  }
}
