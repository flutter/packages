// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;

final class ExoPlayerEventListener implements Player.Listener {
  private final ExoPlayer exoPlayer;
  private final VideoPlayerCallbacks events;
  private boolean isBuffering = false;
  private boolean isInitialized = false;

  ExoPlayerEventListener(ExoPlayer exoPlayer, VideoPlayerCallbacks events) {
    this.exoPlayer = exoPlayer;
    this.events = events;
  }

  private void setBuffering(boolean buffering) {
    if (isBuffering == buffering) {
      return;
    }
    isBuffering = buffering;
    if (buffering) {
      events.onBufferingStart();
    } else {
      events.onBufferingEnd();
    }
  }

  @SuppressWarnings("SuspiciousNameCombination")
  private void sendInitialized() {
    if (isInitialized) {
      return;
    }
    isInitialized = true;
    VideoSize videoSize = exoPlayer.getVideoSize();
    int rotationCorrection = 0;
    int width = videoSize.width;
    int height = videoSize.height;
    if (width != 0 && height != 0) {
      int rotationDegrees = videoSize.unappliedRotationDegrees;
      // Switch the width/height if video was taken in portrait mode
      if (rotationDegrees == 90 || rotationDegrees == 270) {
        width = videoSize.height;
        height = videoSize.width;
      }
      // Rotating the video with ExoPlayer does not seem to be possible with a Surface,
      // so inform the Flutter code that the widget needs to be rotated to prevent
      // upside-down playback for videos with rotationDegrees of 180 (other orientations work
      // correctly without correction).
      if (rotationDegrees == 180) {
        rotationCorrection = rotationDegrees;
      }
    }
    events.onInitialized(width, height, exoPlayer.getDuration(), rotationCorrection);
  }

  @Override
  public void onPlaybackStateChanged(final int playbackState) {
    switch (playbackState) {
      case Player.STATE_BUFFERING:
        setBuffering(true);
        events.onBufferingUpdate(exoPlayer.getBufferedPosition());
        break;
      case Player.STATE_READY:
        sendInitialized();
        break;
      case Player.STATE_ENDED:
        events.onCompleted();
        break;
      case Player.STATE_IDLE:
        break;
    }
    if (playbackState != Player.STATE_BUFFERING) {
      setBuffering(false);
    }
  }

  @Override
  public void onPlayerError(@NonNull final PlaybackException error) {
    setBuffering(false);
    if (error.errorCode == PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW) {
      // See https://exoplayer.dev/live-streaming.html#behindlivewindowexception-and-error_code_behind_live_window
      exoPlayer.seekToDefaultPosition();
      exoPlayer.prepare();
    } else {
      events.onError("VideoError", "Video player had error " + error, null);
    }
  }

  @Override
  public void onIsPlayingChanged(boolean isPlaying) {
    events.onIsPlayingStateUpdate(isPlaying);
  }
}
