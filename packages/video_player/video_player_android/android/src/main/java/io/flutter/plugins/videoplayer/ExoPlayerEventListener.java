// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.os.CountDownTimer;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.C;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.Player.PositionInfo;
import androidx.media3.common.Tracks;
import androidx.media3.exoplayer.ExoPlayer;

public abstract class ExoPlayerEventListener implements Player.Listener {
  private boolean isInitialized = false;
  private boolean isLoadingNewAsset = false;
  private CountDownTimer timeoutCountdown;
  protected final ExoPlayer exoPlayer;
  protected final VideoPlayerCallbacks events;
  @Nullable private Runnable onLoopCallback;

  protected enum RotationDegrees {
    ROTATE_0(0),
    ROTATE_90(90),
    ROTATE_180(180),
    ROTATE_270(270);

    private final int degrees;

    RotationDegrees(int degrees) {
      this.degrees = degrees;
    }

    public static RotationDegrees fromDegrees(int degrees) {
      for (RotationDegrees rotationDegrees : RotationDegrees.values()) {
        if (rotationDegrees.degrees == degrees) {
          return rotationDegrees;
        }
      }
      throw new IllegalArgumentException("Invalid rotation degrees specified: " + degrees);
    }

    public int getDegrees() {
      return this.degrees;
    }
  }

  public ExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @NonNull VideoPlayerCallbacks events) {
    this.exoPlayer = exoPlayer;
    this.events = events;
  }

  public void setOnLoopCallback(@Nullable Runnable callback) {
    this.onLoopCallback = callback;
  }

  protected abstract void sendInitialized();

  protected abstract void sendReloadingEnd();

  @Override
  public void onPlaybackStateChanged(final int playbackState) {
    PlatformPlaybackState platformState = PlatformPlaybackState.UNKNOWN;
    switch (playbackState) {
      case Player.STATE_BUFFERING:
        platformState = PlatformPlaybackState.BUFFERING;
        break;
      case Player.STATE_READY:
        if (timeoutCountdown != null) {
          timeoutCountdown.cancel();
        }
        platformState = PlatformPlaybackState.READY;
        if (!isInitialized) {
          isInitialized = true;
          sendInitialized();
        } else if (isLoadingNewAsset) {
          isLoadingNewAsset = false;
          sendReloadingEnd();
        }
        break;
      case Player.STATE_ENDED:
        platformState = PlatformPlaybackState.ENDED;
        break;
      case Player.STATE_IDLE:
        platformState = PlatformPlaybackState.IDLE;
        break;
    }
    events.onPlaybackStateChanged(platformState);
  }

  @Override
  public void onPlayerError(@NonNull final PlaybackException error) {
    if (error.errorCode == PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW) {
      // See
      // https://exoplayer.dev/live-streaming.html#behindlivewindowexception-and-error_code_behind_live_window
      exoPlayer.seekToDefaultPosition();
      exoPlayer.prepare();
    } else {
      events.onError("VideoError", "Video player had error " + error, null);
    }
  }

  @Override
  public void onRenderedFirstFrame() {
    // Fired again for every new surface and every new stream, so a recycled
    // player re-announces after loadAsset rather than only on first creation.
    events.onRenderedFirstFrame();
  }

  @Override
  public void onIsPlayingChanged(boolean isPlaying) {
    events.onIsPlayingStateUpdate(isPlaying);
  }

  @Override
  public void onPositionDiscontinuity(
      @NonNull PositionInfo oldPosition,
      @NonNull PositionInfo newPosition,
      int reason) {
    if (reason == Player.DISCONTINUITY_REASON_AUTO_TRANSITION && onLoopCallback != null) {
      onLoopCallback.run();
    }
  }

  @Override
  public void onTracksChanged(@NonNull Tracks tracks) {
    // Find the currently selected audio track and notify
    String selectedTrackId = findSelectedAudioTrackId(tracks);
    events.onAudioTrackChanged(selectedTrackId);
  }

  /**
   * Finds the ID of the currently selected audio track.
   *
   * @param tracks The current tracks
   * @return The track ID in format "groupIndex_trackIndex", or null if no audio track is selected
   */
  @Nullable
  private String findSelectedAudioTrackId(@NonNull Tracks tracks) {
    int groupIndex = 0;
    for (Tracks.Group group : tracks.getGroups()) {
      if (group.getType() == C.TRACK_TYPE_AUDIO && group.isSelected()) {
        // Find the selected track within this group
        for (int i = 0; i < group.length; i++) {
          if (group.isTrackSelected(i)) {
            return groupIndex + "_" + i;
          }
        }
      }
      groupIndex++;
    }
    return null;
  }

  public void onReloadingStart() {
    startTimeoutCountdown();
    isLoadingNewAsset = true;
    events.onReloadingStart();
  }

  private void startTimeoutCountdown() {
      if (timeoutCountdown != null) {
          timeoutCountdown.cancel();
      }
      timeoutCountdown = new CountDownTimer(8000, 8000) {

          public void onTick(long millisUntilFinished) {}

          public void onFinish() {
              events.onError("VideoError", "Video player timed out, no events", null);
          }
      }.start();
  }
}
