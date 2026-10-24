// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.VideoRecordEvent;

/** ProxyApi implementation for {@link VideoRecordEvent.Finalize}. */
class VideoRecordEventFinalizeProxyApi extends PigeonApiVideoRecordEventFinalize {
  VideoRecordEventFinalizeProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long getError(@NonNull VideoRecordEvent.Finalize pigeonInstance) {
    return (long) pigeonInstance.getError();
  }

  @Override
  public boolean hasError(@NonNull VideoRecordEvent.Finalize pigeonInstance) {
    return pigeonInstance.hasError();
  }
}
