// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.texture;

import android.content.Context;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.trackselection.AdaptiveTrackSelection;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import androidx.media3.exoplayer.upstream.DefaultBandwidthMeter;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoAsset;
import io.flutter.plugins.videoplayer.VideoPlayer;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;
import io.flutter.plugins.videoplayer.VideoPlayerOptions;
import io.flutter.view.TextureRegistry.SurfaceProducer;

/**
 * A subclass of {@link VideoPlayer} that adds functionality related to texture view as a way of
 * displaying the video in the app.
 *
 * <p>It manages the lifecycle of the texture and ensures that the video is properly displayed on
 * the texture.
 */
public final class TextureVideoPlayer extends VideoPlayer implements SurfaceProducer.Callback {
  // True when the ExoPlayer instance has a null surface.
  private boolean needsSurface = true;
  
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
  @UnstableApi
  @NonNull
  public static TextureVideoPlayer create(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull SurfaceProducer surfaceProducer,
      @NonNull VideoAsset asset,
      @NonNull VideoPlayerOptions options) {
    
    TextureVideoPlayer player = new TextureVideoPlayer(
        events,
        surfaceProducer,
        asset.getMediaItem(),
        options,
        () -> {
          // Create bandwidth meter for adaptive streaming
          DefaultBandwidthMeter bandwidthMeter = new DefaultBandwidthMeter.Builder(context)
              .setInitialBitrateEstimate(1_000_000) // Start with 1 Mbps estimate
              .build();
          
          // Create adaptive track selection factory
          AdaptiveTrackSelection.Factory trackSelectionFactory = 
              new AdaptiveTrackSelection.Factory();
          
          DefaultTrackSelector trackSelector = new DefaultTrackSelector(context, trackSelectionFactory);
          
          // Configure for YouTube-style adaptive streaming
          trackSelector.setParameters(
              trackSelector
                  .buildUponParameters()
                  // ENABLE adaptive bitrate streaming
                  .setAllowVideoNonSeamlessAdaptiveness(true) // Allow quality switches even with brief buffering
                  .setAllowVideoMixedMimeTypeAdaptiveness(false) // Keep same codec for stability
                  .setAllowVideoMixedDecoderSupportAdaptiveness(true) // Allow decoder adaptiveness
                  // Audio settings
                  .setAllowAudioMixedMimeTypeAdaptiveness(false)
                  .setAllowAudioMixedSampleRateAdaptiveness(true)
                  .setAllowAudioMixedChannelCountAdaptiveness(true)
                  // Don't force lowest bitrate - let ExoPlayer choose based on network
                  .setForceLowestBitrate(false)
                  .setForceHighestSupportedBitrate(false)
                  // Let ExoPlayer adapt based on network conditions
                  .setMaxVideoBitrate(Integer.MAX_VALUE)
                  .build());
          
          android.util.Log.d("TextureVideoPlayer", "Adaptive bitrate streaming ENABLED - ExoPlayer will automatically switch qualities based on network speed");
          
          ExoPlayer.Builder builder =
              new ExoPlayer.Builder(context)
                  .setTrackSelector(trackSelector)
                  .setBandwidthMeter(bandwidthMeter) // Attach bandwidth meter
                  .setMediaSourceFactory(asset.getMediaSourceFactory(context));
          
          return builder.build();
        });
    
    // DO NOT call enableSmoothAdaptiveStreaming() - it disables ABR!
    // ExoPlayer is now configured for automatic adaptive streaming
    
    return player;
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @UnstableApi
  @VisibleForTesting
  public TextureVideoPlayer(
      @NonNull VideoPlayerCallbacks events,
      @NonNull SurfaceProducer surfaceProducer,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options,
      @NonNull ExoPlayerProvider exoPlayerProvider) {
    super(events, mediaItem, options, surfaceProducer, exoPlayerProvider);

    surfaceProducer.setCallback(this);

    Surface surface = surfaceProducer.getSurface();
    this.exoPlayer.setVideoSurface(surface);
    needsSurface = surface == null;
  }

  @NonNull
  @Override
  protected ExoPlayerEventListener createExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @Nullable SurfaceProducer surfaceProducer) {
    if (surfaceProducer == null) {
      throw new IllegalArgumentException(
          "surfaceProducer cannot be null to create an ExoPlayerEventListener for TextureVideoPlayer.");
    }
    boolean surfaceProducerHandlesCropAndRotation = surfaceProducer.handlesCropAndRotation();
    return new TextureExoPlayerEventListener(
        exoPlayer, videoPlayerEvents, surfaceProducerHandlesCropAndRotation);
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  public void onSurfaceAvailable() {
    if (needsSurface) {
      // TextureVideoPlayer must always set a surfaceProducer.
      assert surfaceProducer != null;
      exoPlayer.setVideoSurface(surfaceProducer.getSurface());
      needsSurface = false;
    }
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  public void onSurfaceCleanup() {
    exoPlayer.setVideoSurface(null);
    needsSurface = true;
  }

  public void dispose() {
    // Super must be called first to ensure the player is released before the surface.
    super.dispose();

    // TextureVideoPlayer must always set a surfaceProducer.
    assert surfaceProducer != null;
    surfaceProducer.release();
  }
}