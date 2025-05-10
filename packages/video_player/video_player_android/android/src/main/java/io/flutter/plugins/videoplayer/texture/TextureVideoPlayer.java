// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.texture;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.ExoPlayerState;
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
  @Nullable private ExoPlayerState savedStateDuring;
  private TextureSurfaceHelper surfaceHelper;

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
  @NonNull
  public static TextureVideoPlayer create(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull SurfaceProducer surfaceProducer,
      @NonNull VideoAsset asset,
      @NonNull VideoPlayerOptions options) {
    return new TextureVideoPlayer(
        events,
        surfaceProducer,
        asset.getMediaItem(),
        options,
        () -> {
          ExoPlayer.Builder builder =
              new ExoPlayer.Builder(context)
                  .setMediaSourceFactory(asset.getMediaSourceFactory(context));
          return builder.build();
        });
  }

  @VisibleForTesting
  public TextureVideoPlayer(
      @NonNull VideoPlayerCallbacks events,
      @NonNull SurfaceProducer surfaceProducer,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options,
      @NonNull ExoPlayerProvider exoPlayerProvider) {
    super(events, mediaItem, options, surfaceProducer, exoPlayerProvider);

    surfaceProducer.setCallback(this);
    
    // Initialize the surface helper
    surfaceHelper = new TextureSurfaceHelper(exoPlayer);
    surfaceHelper.setSurface(surfaceProducer.getSurface());
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
        exoPlayer,
        videoPlayerEvents,
        surfaceProducerHandlesCropAndRotation,
        playerHasBeenSuspended());
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  public void onSurfaceAvailable() {
    if (savedStateDuring != null) {
      // If we previously cleared the surface but didn't fully release the player
      if (!exoPlayer.isPlaying() && exoPlayer.getPlayWhenReady()) {
        // We need to recreate the player
        exoPlayer = createVideoPlayer();
        
        // Also recreate surface helper for the new player
        surfaceHelper = new TextureSurfaceHelper(exoPlayer);
      }
      
      // Set the surface using the helper to avoid flickering
      surfaceHelper.setSurface(surfaceProducer.getSurface());
      
      // Restore the saved state
      savedStateDuring.restore(exoPlayer);
      
      // Clear the saved state now that we've restored it
      savedStateDuring = null;
    } else {
      // If there's no saved state but surface became available,
      // just ensure the surface is set
      surfaceHelper.setSurface(surfaceProducer.getSurface());
    }
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  // TODO(bparrishMines): Replace with onSurfaceCleanup once available on stable. See
  // https://github.com/flutter/flutter/issues/161256.
  @SuppressWarnings({"deprecation", "removal"})
  public void onSurfaceDestroyed() {
    // Save the player state no matter what
    if (savedStateDuring == null) {
      savedStateDuring = ExoPlayerState.save(exoPlayer);
    }
    
    // If playing, we need to pause to prevent background playback with no surface
    if (exoPlayer.isPlaying()) {
      exoPlayer.pause();
    }
    
    // Use the helper to safely clear the surface
    // This prevents texture destruction which causes flickering
    surfaceHelper.clearSurface();
  }

  @Override
  public void dispose() {
    // Release surface helper first
    if (surfaceHelper != null) {
      surfaceHelper.release();
      surfaceHelper = null;
    }
    
    // Super must be called to ensure the player is released before the surface.
    super.dispose();

    surfaceProducer.release();
    // TODO(matanlurey): Remove when embedder no longer calls-back once released.
    // https://github.com/flutter/flutter/issues/156434.
    surfaceProducer.setCallback(null);
  }
  
  private boolean playerHasBeenSuspended() {
    return savedStateDuring != null;
  }
}
