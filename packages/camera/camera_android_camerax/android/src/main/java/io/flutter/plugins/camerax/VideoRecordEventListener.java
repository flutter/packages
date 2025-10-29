// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.VideoRecordEvent;

public interface VideoRecordEventListener {
  void onEvent(@NonNull VideoRecordEvent event);
}
