// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static androidx.media3.common.Player.REPEAT_MODE_ALL;
import static androidx.media3.common.Player.REPEAT_MODE_OFF;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.annotation.RestrictTo;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.TrackGroup;
import androidx.media3.common.TrackSelectionOverride;
import androidx.media3.common.Tracks;
import androidx.media3.common.util.Assertions;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.common.util.Util;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.source.TrackGroupArray;
import androidx.media3.exoplayer.trackselection.AdaptiveTrackSelection;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import androidx.media3.exoplayer.trackselection.MappingTrackSelector;
import androidx.media3.exoplayer.trackselection.TrackSelectionArray;

import com.google.common.collect.ImmutableList;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import io.flutter.view.TextureRegistry;
import io.github.anilbeesetti.nextlib.media3ext.ffdecoder.NextRenderersFactory;

@UnstableApi
final class VideoPlayer implements TextureRegistry.SurfaceProducer.Callback {
  @NonNull private final ExoPlayerProvider exoPlayerProvider;
  @NonNull private final MediaItem mediaItem;
  @NonNull private final TextureRegistry.SurfaceProducer surfaceProducer;
  @NonNull private final VideoPlayerCallbacks videoPlayerEvents;
  @NonNull private final VideoPlayerOptions options;
  @NonNull private ExoPlayer exoPlayer;
  @Nullable private ExoPlayerState savedStateDuring;
  @SuppressLint("StaticFieldLeak")
  @Nullable static private  DefaultTrackSelector trackSelector;
  @Nullable static private DefaultTrackSelector.Parameters trackSelectorParameters;

  /**
   * Creates a video player.
   *
   * @param context application context.
   * @param events event callbacks.
   * @param surfaceProducer produces a texture to render to.
   * @param asset asset to play.
   * @param options options for playback.
   * @return a video player instance.
   */
  @OptIn(markerClass = UnstableApi.class)
  @NonNull
  static VideoPlayer create(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer,
      @NonNull VideoAsset asset,
      @NonNull VideoPlayerOptions options) {
    return new VideoPlayer(
        () -> {

          AdaptiveTrackSelection.Factory trackSelectionFactory = new AdaptiveTrackSelection.Factory();
          trackSelectorParameters = new DefaultTrackSelector.Parameters.Builder(context).build();

          trackSelector = new DefaultTrackSelector(context, trackSelectionFactory);

          trackSelector.setParameters(trackSelectorParameters);


          final NextRenderersFactory renderersFactory =new NextRenderersFactory(context);
          renderersFactory.setExtensionRendererMode(DefaultRenderersFactory.EXTENSION_RENDERER_MODE_ON);
          renderersFactory.setEnableDecoderFallback(true);


          ExoPlayer.Builder builder = new ExoPlayer.Builder(context)
                  .setMediaSourceFactory(asset.getMediaSourceFactory(context))
                  .setUsePlatformDiagnostics(true)
                  .setRenderersFactory(renderersFactory)
                  .setTrackSelector(trackSelector);
          return builder.build();
        },
        events,
        surfaceProducer,
        asset.getMediaItem(),
        options);
  }

  /** A closure-compatible signature since {@link java.util.function.Supplier} is API level 24. */
  interface ExoPlayerProvider {
    /**
     * Returns a new {@link ExoPlayer}.
     *
     * @return new instance.
     */
    ExoPlayer get();
  }

  @VisibleForTesting
  VideoPlayer(
      @NonNull ExoPlayerProvider exoPlayerProvider,
      @NonNull VideoPlayerCallbacks events,
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options) {
    this.exoPlayerProvider = exoPlayerProvider;
    this.videoPlayerEvents = events;
    this.surfaceProducer = surfaceProducer;
    this.mediaItem = mediaItem;
    this.options = options;
    this.exoPlayer = createVideoPlayer();
    surfaceProducer.setCallback(this);
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  // TODO(matanlurey): https://github.com/flutter/flutter/issues/155131.
  @SuppressWarnings({"deprecation", "removal"})
  public void onSurfaceCreated() {
    if (savedStateDuring != null) {
      exoPlayer = createVideoPlayer();
      savedStateDuring.restore(exoPlayer);
      savedStateDuring = null;
    }
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  public void onSurfaceDestroyed() {
    // Intentionally do not call pause/stop here, because the surface has already been released
    // at this point (see https://github.com/flutter/flutter/issues/156451).
    savedStateDuring = ExoPlayerState.save(exoPlayer);
    exoPlayer.release();
  }

  private ExoPlayer createVideoPlayer() {
    ExoPlayer exoPlayer = exoPlayerProvider.get();
    exoPlayer.setMediaItem(mediaItem);
    exoPlayer.prepare();

    exoPlayer.setVideoSurface(surfaceProducer.getSurface());

    boolean wasInitialized = savedStateDuring != null;
    exoPlayer.addListener(new ExoPlayerEventListener(exoPlayer, videoPlayerEvents, wasInitialized));
    setAudioAttributes(exoPlayer, options.mixWithOthers);

    return exoPlayer;
  }

  void sendBufferingUpdate() {
    videoPlayerEvents.onBufferingUpdate(exoPlayer.getBufferedPosition());
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

  void dispose() {
    exoPlayer.release();
    surfaceProducer.release();

    trackSelectorParameters = null;
    trackSelector = null;

    // TODO(matanlurey): Remove when embedder no longer calls-back once released.
    // https://github.com/flutter/flutter/issues/156434.
    surfaceProducer.setCallback(null);
  }

  @OptIn(markerClass = UnstableApi.class) private void updateTrackSelectorParameters() {
    if (trackSelector != null) {
      trackSelectorParameters = trackSelector.getParameters();
    }
  }


  @UnstableApi public ArrayList<Object> getTrackSelections() {
    System.err.println("xxx : tracks X4 ...");
    ArrayList<Object> trackSelections = new ArrayList<>();
    ArrayList<Integer> autoTrackSelectionTypes = new ArrayList<>();


    MappingTrackSelector.MappedTrackInfo mappedTrackInfo =
            Assertions.checkNotNull(trackSelector.getCurrentMappedTrackInfo());
    for (int rendererIndex = 0;
         rendererIndex < mappedTrackInfo.getRendererCount();
         rendererIndex++) {
      TrackGroupArray trackGroups = mappedTrackInfo.getTrackGroups(rendererIndex);

      if (isSupportedTrackForRenderer(trackGroups, mappedTrackInfo, rendererIndex)) {
        int trackType = mappedTrackInfo.getRendererType(rendererIndex);
        for (int groupIndex = 0; groupIndex < trackGroups.length; groupIndex++) {
          TrackGroup group = trackGroups.get(groupIndex);

          //add auto track for each track selection types
//                    if (!autoTrackSelectionTypes.contains(trackType)) {
//                        autoTrackSelectionTypes.add(trackType);
//                        HashMap<String, Object> autoTrackSelection = new HashMap<>();
//                        autoTrackSelection.put("isUnknown", false);
//                        autoTrackSelection.put("isAuto", true);
//                        autoTrackSelection.put("trackType", trackType);
//                        final boolean isSelected = trackSelectorParameters.getRendererDisabled(rendererIndex);
//
//
//                        Log.d("xxx auto", "isSelected" + " " + trackSelectorParameters.overrides);
//
//                        autoTrackSelection.put(
//                                "isSelected",
//                                isSelected);
//                        autoTrackSelection.put("trackId", Integer.toString(rendererIndex));
//                        trackSelections.add(autoTrackSelection);
//                    }

          //add tracks
          for (int trackIndex = 0; trackIndex < group.length; trackIndex++) {
            HashMap<String, Object> trackSelection = new HashMap<>();
            Format trackFormat = group.getFormat(trackIndex);

            int inferPrimaryTrackType = inferPrimaryTrackType(trackFormat);
            trackSelection.put("isUnknown", false);
            switch (inferPrimaryTrackType) {
              case C.TRACK_TYPE_VIDEO:
                trackSelection.put("rolesFlag", roleIntMap(trackFormat));
                trackSelection.put("width", trackWidth(trackFormat));
                trackSelection.put("height", trackHeight(trackFormat));
                trackSelection.put("bitrate", trackBitrate(trackFormat));
                break;
              case C.TRACK_TYPE_AUDIO:
                trackSelection.put("language", buildLanguageString(trackFormat));
                trackSelection.put("label", buildLabelString(trackFormat));
                trackSelection.put("rolesFlag", roleIntMap(trackFormat));
                trackSelection.put("channelCount", audioChannelCount(trackFormat));
                trackSelection.put("bitrate", trackBitrate(trackFormat));
                break;
              case C.TRACK_TYPE_TEXT:
                trackSelection.put("language", buildLanguageString(trackFormat));
                trackSelection.put("label", buildLabelString(trackFormat));
                trackSelection.put("rolesFlag", roleIntMap(trackFormat));
                break;
              default:
                trackSelection.put("isUnknown", true);
            }


            trackSelection.put("isAuto", false);
            trackSelection.put("trackType", trackType);


            final boolean isTrackSelected = isTrackSelected(trackType, groupIndex, trackIndex);

            trackSelection.put(
                    "isSelected",
                    isTrackSelected);
            trackSelection.put("trackId", getTrackId(rendererIndex, groupIndex, trackIndex));
            trackSelections.add(trackSelection);
          }
        }
      }
    }
    System.err.println(trackSelections.toString());
    return trackSelections;
  }


  boolean isTrackSelected(int trackType, int groupIndex, int trackIndex) {
    final Tracks tracks = exoPlayer.getCurrentTracks();
    final ImmutableList<Tracks.Group> groups = tracks.getGroups();

    final List<Tracks.Group> selectedTypeGroups = new ArrayList<>();
    for (int i = 0; i < groups.size(); i++) {
      final Tracks.Group group = groups.get(i);
      if (group.getType() == trackType) {
        selectedTypeGroups.add(group);
      }
    }

    if (groupIndex < 0 || groupIndex >= selectedTypeGroups.size()) {
      return false;
    }

    final Tracks.Group group = selectedTypeGroups.get(groupIndex);

    return group.isTrackSelected(trackIndex);
  }


  @UnstableApi private Boolean isSupportedTrackForRenderer(
          TrackGroupArray trackGroups,
          MappingTrackSelector.MappedTrackInfo mappedTrackInfo,
          Integer rendererIndex) {
    if (trackGroups.length == 0) {
      return false;
    }
    int trackType = mappedTrackInfo.getRendererType(rendererIndex);
    return isSupportedTrackType(trackType);
  }

  private Boolean isSupportedTrackType(Integer trackType) {
    switch (trackType) {
      case C.TRACK_TYPE_VIDEO:
      case C.TRACK_TYPE_AUDIO:
      case C.TRACK_TYPE_TEXT:
        return true;
      default:
        return false;
    }
  }

  @OptIn(markerClass = UnstableApi.class) private static Integer inferPrimaryTrackType(Format format) {
    int trackType = MimeTypes.getTrackType(format.sampleMimeType);
    if (trackType != C.TRACK_TYPE_UNKNOWN) {
      return trackType;
    }
    if (MimeTypes.getVideoMediaMimeType(format.codecs) != null) {
      return C.TRACK_TYPE_VIDEO;
    }
    if (MimeTypes.getAudioMediaMimeType(format.codecs) != null) {
      return C.TRACK_TYPE_AUDIO;
    }
    if (format.width != Format.NO_VALUE || format.height != Format.NO_VALUE) {
      return C.TRACK_TYPE_VIDEO;
    }
    if (format.channelCount != Format.NO_VALUE || format.sampleRate != Format.NO_VALUE) {
      return C.TRACK_TYPE_AUDIO;
    }
    return C.TRACK_TYPE_UNKNOWN;
  }

  private String buildLabelString(Format format) {
    return TextUtils.isEmpty(format.label) ? "" : format.label;
  }

  @UnstableApi private String buildLanguageString(Format format) {
    String language = format.language;
    if (language == null
            || TextUtils.isEmpty(language)
            || C.LANGUAGE_UNDETERMINED.equals(language)) {
      return "";
    }
    Locale locale = Util.SDK_INT >= 21 ? Locale.forLanguageTag(language) : new Locale(language);
    return locale.getDisplayName();
  }

  private Integer roleIntMap(Format format) {
    if ((format.roleFlags & C.ROLE_FLAG_ALTERNATE) != 0) {
      return 0;
    }
    if ((format.roleFlags & C.ROLE_FLAG_SUPPLEMENTARY) != 0) {
      return 1;
    }
    if ((format.roleFlags & C.ROLE_FLAG_COMMENTARY) != 0) {
      return 2;
    }
    if ((format.roleFlags & (C.ROLE_FLAG_CAPTION | C.ROLE_FLAG_DESCRIBES_MUSIC_AND_SOUND)) != 0) {
      return 3;
    }
    return -1;
  }

  private Integer audioChannelCount(Format format) {
    int channelCount = format.channelCount;
    if (channelCount < 1) {
      return -1;
    }
    return channelCount;
  }

  @OptIn(markerClass = UnstableApi.class) private Integer trackBitrate(Format format) {
    return format.bitrate;
  }

  private Integer trackWidth(Format format) {
    return format.width;
  }

  private Integer trackHeight(Format format) {
    return format.height;
  }


  String getTrackId(Integer rendererIndex, Integer groupIndex, Integer trackIndex) {
    return rendererIndex + ":" + groupIndex + ":" + trackIndex;
  }


  public void setTrackSelection(String trackId, int trackType) {

    final String[] split = trackId.split(":");
    if (split.length != 3) {
      System.err.println("xxx : Invalid trackId " + trackId);
      throw new IllegalStateException("Invalid trackId: " + trackId);
    }
    final int groupIndex = Integer.parseInt(split[1]);
    final int trackIndex = Integer.parseInt(split[2]);

    Tracks tracks = exoPlayer.getCurrentTracks();
    List<Tracks.Group> trackGroups = tracks.getGroups();
    final List<Tracks.Group> selectedTypeGroups = new ArrayList<>();
    for (int i = 0; i < trackGroups.size(); i++) {
      final Tracks.Group group = trackGroups.get(i);
      if (group.getType() == trackType) {
        selectedTypeGroups.add(group);
      }
    }



    if (groupIndex < 0 || groupIndex >= selectedTypeGroups.size()) {
      System.err.println("xxx : Unsupported type " + trackType);

      throw new IllegalStateException("Unsupported type: " + trackType);
    }

    final Tracks.Group trackGroup = selectedTypeGroups.get(groupIndex);

    if (!trackGroup.isTrackSupported(trackIndex)) {
      System.err.println("xxx : Unsupported track Index " + trackIndex);
      throw new IllegalStateException("Unsupported track Index: " + trackIndex);
    }


    final Format format =  trackGroup.getTrackFormat(0);


    exoPlayer.setTrackSelectionParameters(
            exoPlayer.getTrackSelectionParameters()
                    .buildUpon()
                    .setOverrideForType(
                            new TrackSelectionOverride(
                                    trackGroup.getMediaTrackGroup(),
                                    trackIndex))
                    .build());
  }



}
