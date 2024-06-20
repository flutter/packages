// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static androidx.media3.common.Player.REPEAT_MODE_ALL;
import static androidx.media3.common.Player.REPEAT_MODE_OFF;

import android.content.Context;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import io.flutter.view.TextureRegistry;
import java.util.Map;

final class VideoPlayer {
  private static final String FORMAT_SS = "ss";
  private static final String FORMAT_DASH = "dash";
  private static final String FORMAT_HLS = "hls";
  private static final String FORMAT_OTHER = "other";

  private ExoPlayer exoPlayer;

  private Surface surface;

  private final TextureRegistry.SurfaceTextureEntry textureEntry;

  private final VideoPlayerCallbacks videoPlayerEvents;

  private static final String USER_AGENT = "User-Agent";

  private final VideoPlayerOptions options;

  private final DefaultHttpDataSource.Factory httpDataSourceFactory;

  VideoPlayer(
      Context context,
      VideoPlayerCallbacks events,
      TextureRegistry.SurfaceTextureEntry textureEntry,
      String dataSource,
      String formatHint,
      @NonNull Map<String, String> httpHeaders,
      VideoPlayerOptions options) {
    this.videoPlayerEvents = events;
    this.textureEntry = textureEntry;
    this.options = options;

    MediaItem mediaItem =
        new MediaItem.Builder()
            .setUri(dataSource)
            .setMimeType(mimeFromFormatHint(formatHint))
            .build();

    httpDataSourceFactory = new DefaultHttpDataSource.Factory();
    configureHttpDataSourceFactory(httpHeaders);

    ExoPlayer exoPlayer = buildExoPlayer(context, httpDataSourceFactory);

    exoPlayer.setMediaItem(mediaItem);
    exoPlayer.prepare();

    setUpVideoPlayer(exoPlayer);
  }

  // Constructor used to directly test members of this class.
  @VisibleForTesting
  VideoPlayer(
      ExoPlayer exoPlayer,
      VideoPlayerCallbacks events,
      TextureRegistry.SurfaceTextureEntry textureEntry,
      VideoPlayerOptions options,
      DefaultHttpDataSource.Factory httpDataSourceFactory) {
    this.videoPlayerEvents = events;
    this.textureEntry = textureEntry;
    this.options = options;
    this.httpDataSourceFactory = httpDataSourceFactory;

    setUpVideoPlayer(exoPlayer);
  }

  @VisibleForTesting
  public void configureHttpDataSourceFactory(@NonNull Map<String, String> httpHeaders) {
    final boolean httpHeadersNotEmpty = !httpHeaders.isEmpty();
    final String userAgent =
        httpHeadersNotEmpty && httpHeaders.containsKey(USER_AGENT)
            ? httpHeaders.get(USER_AGENT)
            : "ExoPlayer";

    unstableUpdateDataSourceFactory(
        httpDataSourceFactory, httpHeaders, userAgent, httpHeadersNotEmpty);
  }

  private void setUpVideoPlayer(ExoPlayer exoPlayer) {
    this.exoPlayer = exoPlayer;

    surface = new Surface(textureEntry.surfaceTexture());
    exoPlayer.setVideoSurface(surface);
    setAudioAttributes(exoPlayer, options.mixWithOthers);
    exoPlayer.addListener(new ExoPlayerEventListener(exoPlayer, videoPlayerEvents));
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
    exoPlayer.setPlayWhenReady(true);
  }

  void pause() {
    exoPlayer.setPlayWhenReady(false);
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
    textureEntry.release();
    if (surface != null) {
      surface.release();
    }
    if (exoPlayer != null) {
      exoPlayer.release();
    }
  }

  @NonNull
  private static ExoPlayer buildExoPlayer(
      Context context, DataSource.Factory baseDataSourceFactory) {
    DataSource.Factory dataSourceFactory =
        new DefaultDataSource.Factory(context, baseDataSourceFactory);
    DefaultMediaSourceFactory mediaSourceFactory =
        new DefaultMediaSourceFactory(context).setDataSourceFactory(dataSourceFactory);
    return new ExoPlayer.Builder(context).setMediaSourceFactory(mediaSourceFactory).build();
  }

  @Nullable
  private static String mimeFromFormatHint(@Nullable String formatHint) {
    if (formatHint == null) {
      return null;
    }
    switch (formatHint) {
      case FORMAT_SS:
        return MimeTypes.APPLICATION_SS;
      case FORMAT_DASH:
        return MimeTypes.APPLICATION_MPD;
      case FORMAT_HLS:
        return MimeTypes.APPLICATION_M3U8;
      case FORMAT_OTHER:
      default:
        return null;
    }
  }

  // TODO: migrate to stable API, see https://github.com/flutter/flutter/issues/147039
  @OptIn(markerClass = UnstableApi.class)
  private static void unstableUpdateDataSourceFactory(
      DefaultHttpDataSource.Factory factory,
      @NonNull Map<String, String> httpHeaders,
      String userAgent,
      boolean httpHeadersNotEmpty) {
    factory.setUserAgent(userAgent).setAllowCrossProtocolRedirects(true);

    if (httpHeadersNotEmpty) {
      factory.setDefaultRequestProperties(httpHeaders);
    }
  }
}
