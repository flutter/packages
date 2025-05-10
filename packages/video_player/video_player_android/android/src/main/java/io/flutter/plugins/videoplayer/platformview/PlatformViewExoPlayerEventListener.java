// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.platformview;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.Player;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;

/**
 * Class for processing ExoPlayer events from a PlatformView.
 */
public final class PlatformViewExoPlayerEventListener extends ExoPlayerEventListener {
  private long lastBufferUpdateTime = 0;
  private static final long BUFFER_UPDATE_INTERVAL_MS = 500; // Limit buffer updates to prevent flicker

  @VisibleForTesting
  public PlatformViewExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @NonNull VideoPlayerCallbacks events) {
    super(exoPlayer, events, false);
  }

  @Override
  protected void sendInitialized() {
    VideoSize videoSize = exoPlayer.getVideoSize();
    // PlatformView automatically handles rotation, so we don't need a rotation correction
    events.onInitialized(
        videoSize.width, videoSize.height, exoPlayer.getDuration(), 0 /* rotationCorrection */);
  }
  
  @Override
  public void onPlaybackStateChanged(final int playbackState) {
    switch (playbackState) {
      case Player.STATE_BUFFERING:
        // Limit buffer updates to prevent flickering
        long currentTime = System.currentTimeMillis();
        if (currentTime - lastBufferUpdateTime > BUFFER_UPDATE_INTERVAL_MS) {
          events.onBufferingUpdate(exoPlayer.getBufferedPosition());
          events.onBufferingStart();
          lastBufferUpdateTime = currentTime;
        }
        break;
      default:
        // Use the parent implementation for other states
        super.onPlaybackStateChanged(playbackState);
        break;
    }
  }
}
