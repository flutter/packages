// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.platformview;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoAsset;
import io.flutter.plugins.videoplayer.VideoPlayer;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;
import io.flutter.plugins.videoplayer.VideoPlayerOptions;
import io.flutter.plugins.videoplayer.texture.TextureSurfaceHelper;

/**
 * A {@link VideoPlayer} that uses a platform view to display video content.
 */
public final class PlatformViewVideoPlayer extends VideoPlayer {
  private PlatformVideoView platformView;
  private boolean isDisposed = false;

  /**
   * Creates a platform view video player.
   *
   * @param context application context.
   * @param events event callbacks.
   * @param asset asset to play.
   * @param options options for playback.
   * @return a video player instance.
   */
  @NonNull
  public static PlatformViewVideoPlayer create(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull VideoAsset asset,
      @NonNull VideoPlayerOptions options) {
    return new PlatformViewVideoPlayer(
        context,
        events,
        asset.getMediaItem(),
        options,
        () -> {
          ExoPlayer.Builder builder =
              new ExoPlayer.Builder(context)
                  .setMediaSourceFactory(asset.getMediaSourceFactory(context));
          
          // Configure for better performance
          builder.setBufferSize(5 * 1024 * 1024); // 5MB buffer
          
          return builder.build();
        });
  }

  @VisibleForTesting
  public PlatformViewVideoPlayer(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options,
      @NonNull ExoPlayerProvider exoPlayerProvider) {
    super(events, mediaItem, options, null, exoPlayerProvider);
    platformView = new PlatformVideoView(context, exoPlayer);
  }

  @NonNull
  @Override
  protected ExoPlayerEventListener createExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @Nullable Object ignored) {
    return new PlatformViewExoPlayerEventListener(exoPlayer, videoPlayerEvents);
  }

  @Override
  public void dispose() {
    if (isDisposed) {
      return;
    }
    
    isDisposed = true;
    
    // Call super first to clean up ExoPlayer resources
    super.dispose();
    
    platformView.dispose();
    platformView = null;
  }

  /**
   * Gets the platform view that can be embedded in a Flutter app.
   *
   * @return The platform view.
   */
  @NonNull
  public PlatformVideoView getPlatformView() {
    if (isDisposed) {
      throw new IllegalStateException("PlatformViewVideoPlayer is already disposed");
    }
    return platformView;
  }
}
