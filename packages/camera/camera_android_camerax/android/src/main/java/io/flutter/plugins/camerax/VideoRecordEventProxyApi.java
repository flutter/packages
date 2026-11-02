// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.RecordingStats;
import androidx.camera.video.VideoRecordEvent;

/** ProxyApi implementation for {@link VideoRecordEvent}. */
class VideoRecordEventProxyApi extends PigeonApiVideoRecordEvent {
  VideoRecordEventProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public RecordingStats getRecordingStats(@NonNull VideoRecordEvent pigeonInstance) {
    return pigeonInstance.getRecordingStats();
  }
}
