// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.Tracks;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;

public abstract class ExoPlayerEventListener implements Player.Listener {
  private boolean isInitialized = false;
  protected final ExoPlayer exoPlayer;
  protected final VideoPlayerCallbacks events;

  // Track current video quality for adaptive streaming logging
  private int currentVideoWidth = 0;
  private int currentVideoHeight = 0;
  private int currentVideoBitrate = 0;

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

  protected abstract void sendInitialized();

  @Override
  public void onPlaybackStateChanged(final int playbackState) {
    PlatformPlaybackState platformState = PlatformPlaybackState.UNKNOWN;
    
    switch (playbackState) {
      case Player.STATE_BUFFERING:
        platformState = PlatformPlaybackState.BUFFERING;
        android.util.Log.d("ExoPlayerListener", "State: BUFFERING");
        break;
      case Player.STATE_READY:
        platformState = PlatformPlaybackState.READY;
        if (!isInitialized) {
          isInitialized = true;
          sendInitialized();
          android.util.Log.d("ExoPlayerListener", "State: READY - Video initialized");
        } else {
          android.util.Log.d("ExoPlayerListener", "State: READY");
        }
        break;
      case Player.STATE_ENDED:
        platformState = PlatformPlaybackState.ENDED;
        android.util.Log.d("ExoPlayerListener", "State: ENDED");
        break;
      case Player.STATE_IDLE:
        platformState = PlatformPlaybackState.IDLE;
        android.util.Log.d("ExoPlayerListener", "State: IDLE");
        break;
    }
    events.onPlaybackStateChanged(platformState);
  }

  @Override
  public void onPlayerError(@NonNull final PlaybackException error) {
    String errorMessage = error.getMessage();
    if (errorMessage == null) {
      errorMessage = "Unknown error";
    }
    android.util.Log.e("ExoPlayerListener", "Player error: " + errorMessage, error);
    
    if (error.errorCode == PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW) {
      // See
      // https://exoplayer.dev/live-streaming.html#behindlivewindowexception-and-error_code_behind_live_window
      android.util.Log.d("ExoPlayerListener", "Behind live window - seeking to default position");
      exoPlayer.seekToDefaultPosition();
      exoPlayer.prepare();
    } else {
      events.onError("VideoError", "Video player had error " + errorMessage, null);
    }
  }

  @Override
  public void onIsPlayingChanged(boolean isPlaying) {
    android.util.Log.d("ExoPlayerListener", "Is playing changed: " + isPlaying);
    events.onIsPlayingStateUpdate(isPlaying);
  }

  @Override
  public void onTracksChanged(@NonNull Tracks tracks) {
    // Log adaptive bitrate streaming quality changes
    logCurrentVideoQuality(tracks);
    
    // Find the currently selected audio track and notify
    String selectedTrackId = findSelectedAudioTrackId(tracks);
    android.util.Log.d("ExoPlayerListener", "Tracks changed - Selected audio track: " + selectedTrackId);
    events.onAudioTrackChanged(selectedTrackId);
  }

  @Override
  public void onVideoSizeChanged(@NonNull VideoSize videoSize) {
    // This is called when adaptive bitrate streaming changes the video resolution
    if (currentVideoWidth != videoSize.width || currentVideoHeight != videoSize.height) {
      currentVideoWidth = videoSize.width;
      currentVideoHeight = videoSize.height;
      
      String quality = getQualityLabel(videoSize.height);
      android.util.Log.i("ExoPlayerListener", 
          "📹 ADAPTIVE QUALITY CHANGE: " + quality + " (" + videoSize.width + "x" + videoSize.height + ")");
    }
  }

  /**
   * Logs the current video quality being played (for adaptive streaming monitoring)
   */
  private void logCurrentVideoQuality(@NonNull Tracks tracks) {
    // Find selected video track
    for (Tracks.Group group : tracks.getGroups()) {
      if (group.getType() == C.TRACK_TYPE_VIDEO && group.isSelected()) {
        for (int i = 0; i < group.length; i++) {
          if (group.isTrackSelected(i)) {
            Format format = group.getTrackFormat(i);
            
            // Only log if quality changed
            if (currentVideoBitrate != format.bitrate || 
                currentVideoWidth != format.width || 
                currentVideoHeight != format.height) {
              
              currentVideoBitrate = format.bitrate;
              currentVideoWidth = format.width;
              currentVideoHeight = format.height;
              
              String quality = getQualityLabel(format.height);
              String bitrate = format.bitrate != Format.NO_VALUE ? 
                  String.format("%.2f Mbps", format.bitrate / 1_000_000.0) : "unknown";
              
              android.util.Log.i("ExoPlayerListener", 
                  "🎬 ADAPTIVE STREAMING: Now playing " + quality + " at " + bitrate + 
                  " [" + format.width + "x" + format.height + "]");
            }
            return;
          }
        }
      }
    }
  }

  /**
   * Gets a human-readable quality label based on video height
   */
  private String getQualityLabel(int height) {
    if (height >= 2160) return "4K";
    if (height >= 1440) return "1440p";
    if (height >= 1080) return "1080p";
    if (height >= 720) return "720p";
    if (height >= 480) return "480p";
    if (height >= 360) return "360p";
    if (height >= 240) return "240p";
    return height + "p";
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
}