// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static androidx.media3.common.Player.REPEAT_MODE_ALL;
import static androidx.media3.common.Player.REPEAT_MODE_OFF;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.TrackGroup;
import androidx.media3.common.TrackSelectionOverride;
import androidx.media3.common.Tracks;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import androidx.media3.session.MediaSession;
import io.flutter.view.TextureRegistry.SurfaceProducer;
import java.util.ArrayList;
import java.util.List;

/**
 * A class responsible for managing video playback using {@link ExoPlayer}.
 *
 * <p>It provides methods to control playback, adjust volume, and handle seeking.
 */
public abstract class VideoPlayer implements VideoPlayerInstanceApi {
  private static final String TAG = "VideoPlayer";

  @NonNull protected final VideoPlayerCallbacks videoPlayerEvents;
  @Nullable protected final SurfaceProducer surfaceProducer;
  @Nullable private DisposeHandler disposeHandler;
  @NonNull protected ExoPlayer exoPlayer;
  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @UnstableApi @Nullable protected DefaultTrackSelector trackSelector;

  // Background playback support
  @Nullable protected Context applicationContext;
  @Nullable protected VideoMedia3SessionService mediaSessionService;
  @Nullable protected MediaSession mediaSession;
  protected boolean backgroundPlaybackEnabled = false;
  protected int textureId = -1;
  private boolean serviceBound = false;

  private final ServiceConnection serviceConnection =
      new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
          VideoMedia3SessionService.LocalBinder binder =
              (VideoMedia3SessionService.LocalBinder) service;
          mediaSessionService = binder.getService();
          serviceBound = true;
          Log.d(TAG, "MediaSessionService connected");

          // If background playback was requested before service was connected, set it up now
          if (backgroundPlaybackEnabled && pendingNotificationMetadata != null) {
            createMediaSessionInternal(pendingNotificationMetadata);
            pendingNotificationMetadata = null;
          }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
          mediaSessionService = null;
          serviceBound = false;
          Log.d(TAG, "MediaSessionService disconnected");
        }
      };

  @Nullable private NotificationMetadataMessage pendingNotificationMetadata;

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

  /** A handler to run when dispose is called. */
  public interface DisposeHandler {
    void onDispose();
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @UnstableApi
  // Error thrown for this-escape warning on JDK 21+ due to https://bugs.openjdk.org/browse/JDK-8015831.
  // Keeping behavior as-is and addressing the warning could cause a regression: https://github.com/flutter/packages/pull/10193
  @SuppressWarnings("this-escape")
  public VideoPlayer(
      @NonNull VideoPlayerCallbacks events,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options,
      @Nullable SurfaceProducer surfaceProducer,
      @NonNull ExoPlayerProvider exoPlayerProvider) {
    this.videoPlayerEvents = events;
    this.surfaceProducer = surfaceProducer;
    exoPlayer = exoPlayerProvider.get();

    // Try to get the track selector from the ExoPlayer if it was built with one
    if (exoPlayer.getTrackSelector() instanceof DefaultTrackSelector) {
      trackSelector = (DefaultTrackSelector) exoPlayer.getTrackSelector();
    }

    exoPlayer.setMediaItem(mediaItem);
    exoPlayer.prepare();
    exoPlayer.addListener(createExoPlayerEventListener(exoPlayer, surfaceProducer));
    setAudioAttributes(exoPlayer, options.mixWithOthers);
  }

  public void setDisposeHandler(@Nullable DisposeHandler handler) {
    disposeHandler = handler;
  }

  @NonNull
  protected abstract ExoPlayerEventListener createExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @Nullable SurfaceProducer surfaceProducer);

  private static void setAudioAttributes(ExoPlayer exoPlayer, boolean isMixMode) {
    exoPlayer.setAudioAttributes(
        new AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(),
        !isMixMode);
  }

  @Override
  public void play() {
    exoPlayer.play();
  }

  @Override
  public void pause() {
    exoPlayer.pause();
  }

  @Override
  public void setLooping(boolean looping) {
    exoPlayer.setRepeatMode(looping ? REPEAT_MODE_ALL : REPEAT_MODE_OFF);
  }

  @Override
  public void setVolume(double volume) {
    float bracketedValue = (float) Math.max(0.0, Math.min(1.0, volume));
    exoPlayer.setVolume(bracketedValue);
  }

  @Override
  public void setPlaybackSpeed(double speed) {
    // We do not need to consider pitch and skipSilence for now as we do not handle them and
    // therefore never diverge from the default values.
    final PlaybackParameters playbackParameters = new PlaybackParameters((float) speed);

    exoPlayer.setPlaybackParameters(playbackParameters);
  }

  @Override
  public long getCurrentPosition() {
    return exoPlayer.getCurrentPosition();
  }

  @Override
  public long getBufferedPosition() {
    return exoPlayer.getBufferedPosition();
  }

  @Override
  public void seekTo(long position) {
    exoPlayer.seekTo(position);
  }

  @NonNull
  public ExoPlayer getExoPlayer() {
    return exoPlayer;
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @UnstableApi
  @Override
  public @NonNull NativeAudioTrackData getAudioTracks() {
    List<ExoPlayerAudioTrackData> audioTracks = new ArrayList<>();

    // Get the current tracks from ExoPlayer
    Tracks tracks = exoPlayer.getCurrentTracks();

    // Iterate through all track groups
    for (int groupIndex = 0; groupIndex < tracks.getGroups().size(); groupIndex++) {
      Tracks.Group group = tracks.getGroups().get(groupIndex);

      // Only process audio tracks
      if (group.getType() == C.TRACK_TYPE_AUDIO) {
        for (int trackIndex = 0; trackIndex < group.length; trackIndex++) {
          Format format = group.getTrackFormat(trackIndex);
          boolean isSelected = group.isTrackSelected(trackIndex);

          // Create audio track data with metadata
          ExoPlayerAudioTrackData audioTrack =
              new ExoPlayerAudioTrackData(
                  (long) groupIndex,
                  (long) trackIndex,
                  format.label,
                  format.language,
                  isSelected,
                  format.bitrate != Format.NO_VALUE ? (long) format.bitrate : null,
                  format.sampleRate != Format.NO_VALUE ? (long) format.sampleRate : null,
                  format.channelCount != Format.NO_VALUE ? (long) format.channelCount : null,
                  format.codecs != null ? format.codecs : null);

          audioTracks.add(audioTrack);
        }
      }
    }
    return new NativeAudioTrackData(audioTracks);
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @UnstableApi
  @Override
  public void selectAudioTrack(long groupIndex, long trackIndex) {
    if (trackSelector == null) {
      throw new IllegalStateException("Cannot select audio track: track selector is null");
    }

    // Get current tracks
    Tracks tracks = exoPlayer.getCurrentTracks();

    if (groupIndex < 0 || groupIndex >= tracks.getGroups().size()) {
      throw new IllegalArgumentException(
          "Cannot select audio track: groupIndex "
              + groupIndex
              + " is out of bounds (available groups: "
              + tracks.getGroups().size()
              + ")");
    }

    Tracks.Group group = tracks.getGroups().get((int) groupIndex);

    // Verify it's an audio track
    if (group.getType() != C.TRACK_TYPE_AUDIO) {
      throw new IllegalArgumentException(
          "Cannot select audio track: group at index "
              + groupIndex
              + " is not an audio track (type: "
              + group.getType()
              + ")");
    }

    // Verify the track index is valid
    if (trackIndex < 0 || (int) trackIndex >= group.length) {
      throw new IllegalArgumentException(
          "Cannot select audio track: trackIndex "
              + trackIndex
              + " is out of bounds (available tracks in group: "
              + group.length
              + ")");
    }

    // Get the track group and create a selection override
    TrackGroup trackGroup = group.getMediaTrackGroup();
    TrackSelectionOverride override = new TrackSelectionOverride(trackGroup, (int) trackIndex);

    // Apply the track selection override
    trackSelector.setParameters(
        trackSelector.buildUponParameters().setOverrideForType(override).build());
  }

  /**
   * Sets the application context and texture ID for background playback support. This should be
   * called by the plugin when creating a player.
   */
  public void setBackgroundPlaybackContext(@NonNull Context context, int textureId) {
    this.applicationContext = context.getApplicationContext();
    this.textureId = textureId;
  }

  @Override
  public void setBackgroundPlayback(@NonNull BackgroundPlaybackMessage msg) {
    backgroundPlaybackEnabled = msg.getEnableBackground();

    if (!backgroundPlaybackEnabled) {
      // Disable background playback - remove media session
      removeMediaSession();
      return;
    }

    NotificationMetadataMessage metadata = msg.getNotificationMetadata();
    if (metadata == null) {
      // Background playback without notification - just keep the flag
      Log.d(TAG, "Background playback enabled without notification metadata");
      return;
    }

    // Check if service is already connected
    if (mediaSessionService != null && serviceBound) {
      createMediaSessionInternal(metadata);
    } else {
      // Store metadata and bind to service
      pendingNotificationMetadata = metadata;
      bindMediaSessionService();
    }
  }

  private void bindMediaSessionService() {
    if (applicationContext == null) {
      Log.e(TAG, "Cannot bind to MediaSessionService: no application context");
      return;
    }

    if (serviceBound) {
      return;
    }

    Intent intent = new Intent(applicationContext, VideoMedia3SessionService.class);
    try {
      applicationContext.startService(intent);
      applicationContext.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
      Log.d(TAG, "Binding to MediaSessionService");
    } catch (Exception e) {
      Log.e(TAG, "Failed to bind to MediaSessionService", e);
    }
  }

  private void createMediaSessionInternal(@NonNull NotificationMetadataMessage metadata) {
    if (mediaSessionService == null || textureId < 0) {
      Log.w(TAG, "Cannot create media session: service not available or invalid texture ID");
      return;
    }

    mediaSession = mediaSessionService.createMediaSession(textureId, exoPlayer, metadata);
    if (mediaSession != null) {
      Log.d(TAG, "Media session created for texture: " + textureId);
    }
  }

  private void removeMediaSession() {
    if (mediaSessionService != null && textureId >= 0) {
      mediaSessionService.removeMediaSession(textureId);
      mediaSession = null;
    }
  }

  private void unbindMediaSessionService() {
    if (applicationContext != null && serviceBound) {
      try {
        applicationContext.unbindService(serviceConnection);
        serviceBound = false;
        Log.d(TAG, "Unbound from MediaSessionService");
      } catch (Exception e) {
        Log.e(TAG, "Error unbinding from MediaSessionService", e);
      }
    }
  }

  public void dispose() {
    if (disposeHandler != null) {
      disposeHandler.onDispose();
    }

    // Clean up background playback resources
    removeMediaSession();
    unbindMediaSessionService();

    exoPlayer.release();
  }
}
