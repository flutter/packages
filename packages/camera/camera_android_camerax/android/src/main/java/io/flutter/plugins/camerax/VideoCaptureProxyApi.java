// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.camera.camera2.interop.Camera2Interop;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.video.VideoCapture;
import androidx.camera.video.VideoOutput;

/**
 * ProxyApi implementation for {@link VideoCapture}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class VideoCaptureProxyApi extends PigeonApiVideoCapture {
  VideoCaptureProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  // Range<?> is defined as Range<Integer> in pigeon.
  @SuppressWarnings("unchecked")
  @OptIn(markerClass = ExperimentalCamera2Interop.class)
  @NonNull
  @Override
  public VideoCapture<?> withOutput(
      @NonNull VideoOutput videoOutput, @Nullable Range<?> targetFpsRange) {
    VideoCapture.Builder<VideoOutput> builder = new VideoCapture.Builder<>(videoOutput);

    if (targetFpsRange != null) {
      Camera2Interop.Extender<VideoCapture<VideoOutput>> extender =
          new Camera2Interop.Extender<>(builder);
      extender.setCaptureRequestOption(
          CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, (Range<Integer>) targetFpsRange);
    }

    return builder.build();
  }

  @NonNull
  @Override
  public VideoOutput getOutput(VideoCapture<?> pigeonInstance) {
    return pigeonInstance.getOutput();
  }

  @Override
  public void setTargetRotation(VideoCapture<?> pigeonInstance, long rotation) {
    pigeonInstance.setTargetRotation((int) rotation);
  }
}
