// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.RecordingStats;

/** ProxyApi implementation for {@link RecordingStats}. */
class RecordingStatsProxyApi extends PigeonApiRecordingStats {
  RecordingStatsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long recordedDurationNanos(@NonNull RecordingStats pigeonInstance) {
    return pigeonInstance.getRecordedDurationNanos();
  }

  @Override
  public long numBytesRecorded(@NonNull RecordingStats pigeonInstance) {
    return pigeonInstance.getNumBytesRecorded();
  }
}
