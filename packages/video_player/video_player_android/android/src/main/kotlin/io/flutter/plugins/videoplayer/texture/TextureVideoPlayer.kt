// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer.texture

import android.content.Context
import androidx.annotation.OptIn
import androidx.annotation.RestrictTo
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
 * A subclass of [VideoPlayer] that adds functionality related to texture view as a way of
 * displaying the video in the app.
 *
 * It manages the lifecycle of the texture and ensures that the video is properly displayed on the
 * texture.
 */
internal class TextureVideoPlayer
@OptIn(UnstableApi::class)
@VisibleForTesting
constructor(
    events: VideoPlayerCallbacks,
    surfaceProducer: SurfaceProducer,
    mediaItem: MediaItem,
    options: VideoPlayerOptions,
    exoPlayerProvider: () -> ExoPlayer
) :
    VideoPlayer(events, mediaItem, options, surfaceProducer, exoPlayerProvider),
    SurfaceProducer.Callback {
  // True when the ExoPlayer instance has a null surface.
  private var needsSurface = true

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  init {
    surfaceProducer.setCallback(this)

    val surface = surfaceProducer.surface
    this.exoPlayer.setVideoSurface(surface)
    needsSurface = surface == null
  }

  override fun createExoPlayerEventListener(
      exoPlayer: ExoPlayer,
      surfaceProducer: SurfaceProducer?
  ): ExoPlayerEventListener {
    requireNotNull(surfaceProducer) {
      ("surfaceProducer cannot be null to create an ExoPlayerEventListener for" +
          " TextureVideoPlayer.")
    }
    val surfaceProducerHandlesCropAndRotation = surfaceProducer.handlesCropAndRotation()
    return TextureExoPlayerEventListener(
        exoPlayer, videoPlayerEvents, surfaceProducerHandlesCropAndRotation)
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  override fun onSurfaceAvailable() {
    if (needsSurface) {
      // TextureVideoPlayer must always set a surfaceProducer.
      checkNotNull(surfaceProducer)
      exoPlayer.setVideoSurface(surfaceProducer.surface)
      needsSurface = false
    }
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  override fun onSurfaceCleanup() {
    exoPlayer.setVideoSurface(null)
    needsSurface = true
  }

  override fun dispose() {
    // Super must be called first to ensure the player is released before the surface.
    super.dispose()

    // TextureVideoPlayer must always set a surfaceProducer.
    checkNotNull(surfaceProducer)
    surfaceProducer.release()
  }

  companion object {
    /**
     * Creates a texture video player.
     *
     * @param context application context.
     * @param events event callbacks.
     * @param surfaceProducer produces a texture to render to.
     * @param asset asset to play.
     * @param options options for playback.
     * @return a video player instance.
     */
    // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
    @OptIn(UnstableApi::class)
    fun create(
        context: Context,
        events: VideoPlayerCallbacks,
        surfaceProducer: SurfaceProducer,
        asset: VideoAsset,
        options: VideoPlayerOptions
    ): TextureVideoPlayer {
      return TextureVideoPlayer(events, surfaceProducer, asset.mediaItem, options) {
        val builder = ExoPlayer.Builder(context)
        val backBufferDurationMs = options.backBufferDurationMs
        if (backBufferDurationMs != null) {
          require(backBufferDurationMs >= 0) { "backBufferDurationMs must be at least 0" }
          if (backBufferDurationMs > 0) {
            // Clamp the value to ensure it fits within the int range expected by
            // DefaultLoadControl.
            val backBufferInt = min(backBufferDurationMs, Int.MAX_VALUE.toLong()).toInt()
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
      }
    }
  }
}
