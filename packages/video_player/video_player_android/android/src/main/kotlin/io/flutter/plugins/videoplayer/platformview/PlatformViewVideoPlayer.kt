// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer.platformview

import android.content.Context
import androidx.annotation.VisibleForTesting
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import io.flutter.plugins.videoplayer.ExoPlayerEventListener
import io.flutter.plugins.videoplayer.VideoAsset
import io.flutter.plugins.videoplayer.VideoPlayer
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks
import io.flutter.plugins.videoplayer.VideoPlayerOptions
import io.flutter.view.TextureRegistry.SurfaceProducer
import kotlin.math.min

/**
 * A subclass of [VideoPlayer] that adds functionality related to platform view as a way of
 * displaying the video in the app.
 */
class PlatformViewVideoPlayer // TODO: Migrate to stable API, see
// https://github.com/flutter/flutter/issues/147039.
@UnstableApi
@VisibleForTesting
constructor(
    events: VideoPlayerCallbacks,
    mediaItem: MediaItem,
    options: VideoPlayerOptions,
    exoPlayerProvider: () -> ExoPlayer
) : VideoPlayer(events, mediaItem, options, /* surfaceProducer */ null, exoPlayerProvider) {
  override fun createExoPlayerEventListener(
      exoPlayer: ExoPlayer,
      surfaceProducer: SurfaceProducer?
  ): ExoPlayerEventListener {
    return PlatformViewExoPlayerEventListener(exoPlayer, videoPlayerEvents)
  }

  companion object {
    /**
     * Creates a platform view video player.
     *
     * @param context application context.
     * @param events event callbacks.
     * @param asset asset to play.
     * @param options options for playback.
     * @return a video player instance.
     */
    // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
    @JvmStatic
    @UnstableApi
    fun create(
        context: Context,
        events: VideoPlayerCallbacks,
        asset: VideoAsset,
        options: VideoPlayerOptions
    ): PlatformViewVideoPlayer {
      return PlatformViewVideoPlayer(
          events,
          asset.mediaItem,
          options,
          {
            val builder = ExoPlayer.Builder(context)
            if (options.backBufferDurationMs != null) {
              require(options.backBufferDurationMs!! >= 0) {
                "backBufferDurationMs must be at least 0"
              }
              if (options.backBufferDurationMs!! > 0) {
                // Clamp the value to ensure it fits within the int range expected by
                // DefaultLoadControl.
                val backBufferInt =
                    min(options.backBufferDurationMs!!, Int.MAX_VALUE.toLong()).toInt()
                val loadControl =
                    DefaultLoadControl.Builder()
                        .setBackBuffer(backBufferInt, /* retainBackBufferFromKeyframe= */ true)
                        .build()
                builder.setLoadControl(loadControl)
              }
            }
            val trackSelector = DefaultTrackSelector(context)
            builder
                .setTrackSelector(trackSelector)
                .setMediaSourceFactory(asset.getMediaSourceFactory(context))
            builder.build()
          })
    }
  }
}
