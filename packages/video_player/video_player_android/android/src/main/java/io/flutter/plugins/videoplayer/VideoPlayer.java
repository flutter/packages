// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static androidx.media3.common.Player.REPEAT_MODE_ALL;
import static androidx.media3.common.Player.REPEAT_MODE_OFF;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.DefaultLoadControl;
import androidx.media3.exoplayer.LoadControl;
import io.flutter.view.TextureRegistry.SurfaceProducer;

/**
 * A class responsible for managing video playback using {@link ExoPlayer}.
 *
 * <p>It provides methods to control playback, adjust volume, and handle seeking.
 */
public abstract class VideoPlayer {
  @NonNull private final ExoPlayerProvider exoPlayerProvider;
  @NonNull private final MediaItem mediaItem;
  @NonNull private final VideoPlayerOptions options;
  @NonNull protected final VideoPlayerCallbacks videoPlayerEvents;
  @Nullable protected final SurfaceProducer surfaceProducer;
  @NonNull protected ExoPlayer exoPlayer;
  
  // Add a throttling mechanism for buffering updates to prevent excessive UI updates
  private static final long BUFFER_UPDATE_INTERVAL_MS = 250;
  private long lastBufferUpdateTime = 0;

  /** A closure-compatible signature since {@link java.util.function.Supplier} is API level 24. */
  public interface ExoPlayerProvider {
    /**
     * Returns a new {@link ExoPlayer}.
     *
     * @return new instance.
     */
    @NonNull
    ExoPlayer get();
  }

  public VideoPlayer(
      @NonNull VideoPlayerCallbacks events,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options,
      @Nullable SurfaceProducer surfaceProducer,
      @NonNull ExoPlayerProvider exoPlayerProvider) {
    this.videoPlayerEvents = events;
    this.mediaItem = mediaItem;
    this.options = options;
    this.exoPlayerProvider = exoPlayerProvider;
    this.surfaceProducer = surfaceProducer;
    this.exoPlayer = createVideoPlayer();
  }

  @NonNull
  protected ExoPlayer createVideoPlayer() {
    ExoPlayer exoPlayer = exoPlayerProvider.get();
    
    // Set media item
    exoPlayer.setMediaItem(mediaItem);
    
    // Configure buffering parameters for smoother playback
    // Increase buffer size to reduce buffering during playback
    exoPlayer.setVideoBufferSize(20 * 1024 * 1024); // 20MB buffer
    
    // Configure buffering parameters for smoother performance
    exoPlayer.setBackBuffer(10000, true); // 10 seconds back buffer
    exoPlayer.setBufferSize(10 * 1024 * 1024); // 10MB buffer
    
    // Set low rebuffer time to prevent long loading times
    exoPlayer.setMinBufferSize(2 * 1024 * 1024); // 2MB minimum buffer
    
    // Set preferred buffering parameters for smoother playback
    exoPlayer.setLoadControl(
        new androidx.media3.exoplayer.DefaultLoadControl.Builder()
            .setBufferDurationsMs(
                2000, // Min buffer duration in ms
                15000, // Max buffer duration in ms
                1000, // Min playback start buffer in ms
                2000) // Min rebuffer duration in ms
            .setPrioritizeTimeOverSizeThresholds(true)
            .build());
    
    // Prepare the player
    exoPlayer.prepare();
    
    // Add listener and set audio attributes
    exoPlayer.addListener(createExoPlayerEventListener(exoPlayer, surfaceProducer));
    setAudioAttributes(exoPlayer, options.mixWithOthers);

    return exoPlayer;
  }

  @NonNull
  protected abstract ExoPlayerEventListener createExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @Nullable SurfaceProducer surfaceProducer);

  void sendBufferingUpdate() {
    // Throttle buffer updates to prevent excessive UI updates and reduce flickering
    long currentTimeMs = System.currentTimeMillis();
    if (currentTimeMs - lastBufferUpdateTime >= BUFFER_UPDATE_INTERVAL_MS) {
      videoPlayerEvents.onBufferingUpdate(exoPlayer.getBufferedPosition());
      lastBufferUpdateTime = currentTimeMs;
    }
  }

  private static void setAudioAttributes(ExoPlayer exoPlayer, boolean isMixMode) {
    exoPlayer.setAudioAttributes(
        new AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(),
        !isMixMode);
  }

  void play() {
    exoPlayer.play();
  }

  void pause() {
    exoPlayer.pause();
  }

  void setLooping(boolean value) {
    exoPlayer.setRepeatMode(value ? REPEAT_MODE_ALL : REPEAT_MODE_OFF);
  }

  void setVolume(double value) {
    float bracketedValue = (float) Math.max(0.0, Math.min(1.0, value));
    exoPlayer.setVolume(bracketedValue);
  }

  void setPlaybackSpeed(double value) {
    // We do not need to consider pitch and skipSilence for now as we do not handle them and
    // therefore never diverge from the default values.
    final PlaybackParameters playbackParameters = new PlaybackParameters(((float) value));

    exoPlayer.setPlaybackParameters(playbackParameters);
  }

  void seekTo(int location) {
    exoPlayer.seekTo(location);
  }

  long getPosition() {
    return exoPlayer.getCurrentPosition();
  }

  @NonNull
  public ExoPlayer getExoPlayer() {
    return exoPlayer;
  }

  public void dispose() {
    exoPlayer.release();
  }
}
