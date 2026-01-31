// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.platformview;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
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
 * A subclass of {@link VideoPlayer} that adds functionality related to platform view as a way of
 * displaying the video in the app.
 */
public class PlatformViewVideoPlayer extends VideoPlayer {
  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @UnstableApi
  @VisibleForTesting
  public PlatformViewVideoPlayer(
      @NonNull VideoPlayerCallbacks events,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options,
      @NonNull ExoPlayerProvider exoPlayerProvider) {
    super(events, mediaItem, options, /* surfaceProducer */ null, exoPlayerProvider);
  }

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
  @UnstableApi
  @NonNull
  public static PlatformViewVideoPlayer create(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull VideoAsset asset,
      @NonNull VideoPlayerOptions options) {
    
    PlatformViewVideoPlayer player = new PlatformViewVideoPlayer(
        events,
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
          
          android.util.Log.d("PlatformViewVideoPlayer", "Adaptive bitrate streaming ENABLED - ExoPlayer will automatically switch qualities based on network speed");
          
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

  @NonNull
  @Override
  protected ExoPlayerEventListener createExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @Nullable SurfaceProducer surfaceProducer) {
    return new PlatformViewExoPlayerEventListener(exoPlayer, videoPlayerEvents);
  }
}