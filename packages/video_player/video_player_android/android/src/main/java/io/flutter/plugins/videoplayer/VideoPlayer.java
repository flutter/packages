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
import androidx.media3.common.Format;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.TrackGroup;
import androidx.media3.common.TrackSelectionOverride;
import androidx.media3.common.Tracks;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import io.flutter.view.TextureRegistry.SurfaceProducer;
import java.util.ArrayList;
import java.util.List;

/**
 * A class responsible for managing video playback using {@link ExoPlayer}.
 *
 * <p>It provides methods to control playback, adjust volume, and handle seeking.
 */
public abstract class VideoPlayer implements Messages.VideoPlayerInstanceApi {
  @NonNull protected final VideoPlayerCallbacks videoPlayerEvents;
  @Nullable protected final SurfaceProducer surfaceProducer;
  @Nullable private DisposeHandler disposeHandler;
  @NonNull protected ExoPlayer exoPlayer;
  @UnstableApi @Nullable protected DefaultTrackSelector trackSelector;

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

  @UnstableApi
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
  public void setLooping(@NonNull Boolean looping) {
    exoPlayer.setRepeatMode(looping ? REPEAT_MODE_ALL : REPEAT_MODE_OFF);
  }

  @Override
  public void setVolume(@NonNull Double volume) {
    float bracketedValue = (float) Math.max(0.0, Math.min(1.0, volume));
    exoPlayer.setVolume(bracketedValue);
  }

  @Override
  public void setPlaybackSpeed(@NonNull Double speed) {
    // We do not need to consider pitch and skipSilence for now as we do not handle them and
    // therefore never diverge from the default values.
    final PlaybackParameters playbackParameters = new PlaybackParameters(speed.floatValue());

    exoPlayer.setPlaybackParameters(playbackParameters);
  }

  @Override
  public @NonNull Messages.PlaybackState getPlaybackState() {
    return new Messages.PlaybackState.Builder()
        .setPlayPosition(exoPlayer.getCurrentPosition())
        .setBufferPosition(exoPlayer.getBufferedPosition())
        .build();
  }

  @Override
  public void seekTo(@NonNull Long position) {
    exoPlayer.seekTo(position);
  }

  @NonNull
  public ExoPlayer getExoPlayer() {
    return exoPlayer;
  }

  @UnstableApi
  @Override
  public @NonNull Messages.NativeAudioTrackData getAudioTracks() {
    List<Messages.ExoPlayerAudioTrackData> audioTracks = new ArrayList<>();

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

          // Create AudioTrackMessage with metadata
          Messages.ExoPlayerAudioTrackData audioTrack =
              new Messages.ExoPlayerAudioTrackData.Builder()
                  .setTrackId(groupIndex + "_" + trackIndex)
                  .setLabel(format.label != null ? format.label : "Audio Track " + (trackIndex + 1))
                  .setLanguage(format.language != null ? format.language : "und")
                  .setIsSelected(isSelected)
                  .setBitrate(format.bitrate != Format.NO_VALUE ? (long) format.bitrate : null)
                  .setSampleRate(
                      format.sampleRate != Format.NO_VALUE ? (long) format.sampleRate : null)
                  .setChannelCount(
                      format.channelCount != Format.NO_VALUE ? (long) format.channelCount : null)
                  .setCodec(format.codecs != null ? format.codecs : null)
                  .build();

          audioTracks.add(audioTrack);
        }
      }
    }

    return new Messages.NativeAudioTrackData.Builder().setExoPlayerTracks(audioTracks).build();
  }

  @UnstableApi
  @Override
  public void selectAudioTrack(@NonNull String trackId) {
    if (trackSelector == null) {
      return;
    }

    try {
      // Parse the trackId (format: "groupIndex_trackIndex")
      String[] parts = trackId.split("_");
      if (parts.length != 2) {
        return;
      }

      int groupIndex = Integer.parseInt(parts[0]);
      int trackIndex = Integer.parseInt(parts[1]);

      // Get current tracks
      Tracks tracks = exoPlayer.getCurrentTracks();

      if (groupIndex >= tracks.getGroups().size()) {
        return;
      }

      Tracks.Group group = tracks.getGroups().get(groupIndex);

      // Verify it's an audio track and the track index is valid
      if (group.getType() != C.TRACK_TYPE_AUDIO || trackIndex >= group.length) {
        return;
      }

      // Get the track group and create a selection override
      TrackGroup trackGroup = group.getMediaTrackGroup();
      TrackSelectionOverride override = new TrackSelectionOverride(trackGroup, trackIndex);

      // Apply the track selection override
      trackSelector.setParameters(
          trackSelector.buildUponParameters().setOverrideForType(override).build());

    } catch (NumberFormatException | ArrayIndexOutOfBoundsException e) {
      // Invalid trackId format, ignore
    }
  }

  public void dispose() {
    if (disposeHandler != null) {
      disposeHandler.onDispose();
    }
    exoPlayer.release();
  }
}
