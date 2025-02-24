// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;

// FIXME Public temporarily (?)
/** Functional interface for providing a VideoPlayer instance based on the player ID. */
@FunctionalInterface
public interface VideoPlayerProvider {
  /**
   * Retrieves a VideoPlayer instance based on the provided player ID.
   *
   * @param playerId The unique identifier for the video player.
   * @return A VideoPlayer instance associated with the given player ID.
   */
  @NonNull
  VideoPlayer getVideoPlayer(@NonNull Long playerId);
}
