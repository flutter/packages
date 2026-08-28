// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class VideoPlayerOptions {
  public boolean mixWithOthers;

  /**
   * The duration of the back buffer in milliseconds, used to configure ExoPlayer's load control.
   */
  @Nullable public Long backBufferDurationMs;

  public VideoPlayerOptions() {}

  /** Copy constructor to ensure all options are reliably copied. */
  public VideoPlayerOptions(@NonNull VideoPlayerOptions other) {
    this.mixWithOthers = other.mixWithOthers;
    this.backBufferDurationMs = other.backBufferDurationMs;
  }
}
