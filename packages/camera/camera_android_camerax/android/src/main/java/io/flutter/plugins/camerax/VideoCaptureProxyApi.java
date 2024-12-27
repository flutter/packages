// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
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

  @NonNull
  @Override
  public VideoCapture<?> withOutput(@NonNull VideoOutput videoOutput) {
    return VideoCapture.withOutput(videoOutput);
  }

  @NonNull
  @Override
  public VideoOutput getOutput(VideoCapture<?> pigeon_instance) {
    return pigeon_instance.getOutput();
  }

  @Override
  public void setTargetRotation(VideoCapture<?> pigeon_instance, long rotation) {
    pigeon_instance.setTargetRotation((int) rotation);
  }
}
