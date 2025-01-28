// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RestrictTo;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.view.TextureRegistry;

/**
 * A subclass of {@link VideoPlayer} that adds functionality related to texture-based view as a way
 * of displaying the video in the app. It manages the lifecycle of the texture and ensures that the
 * video is properly displayed on the texture.
 */
final class TextureBasedVideoPlayer extends VideoPlayer
    implements TextureRegistry.SurfaceProducer.Callback {
  @NonNull private final TextureRegistry.SurfaceProducer surfaceProducer;
  @Nullable private ExoPlayerState savedStateDuring;

  /**
   * Creates a texture-based video player.
   *
   * @param context application context.
   * @param events event callbacks.
   * @param surfaceProducer produces a texture to render to.
   * @param asset asset to play.
   * @param options options for playback.
   * @return a video player instance.
   */
  @NonNull
  static TextureBasedVideoPlayer create(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer,
      @NonNull VideoAsset asset,
      @NonNull VideoPlayerOptions options) {
    return new TextureBasedVideoPlayer(
        () -> {
          ExoPlayer.Builder builder =
              new ExoPlayer.Builder(context)
                  .setMediaSourceFactory(asset.getMediaSourceFactory(context));
          return builder.build();
        },
        events,
        surfaceProducer,
        asset.getMediaItem(),
        options);
  }

  @VisibleForTesting
  TextureBasedVideoPlayer(
      @NonNull ExoPlayerProvider exoPlayerProvider,
      @NonNull VideoPlayerCallbacks events,
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options) {
    super(exoPlayerProvider, events, mediaItem, options);

    this.surfaceProducer = surfaceProducer;
    surfaceProducer.setCallback(this);

    this.exoPlayer.setVideoSurface(surfaceProducer.getSurface());
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  public void onSurfaceAvailable() {
    if (savedStateDuring != null) {
      exoPlayer = createVideoPlayer();
      savedStateDuring.restore(exoPlayer);
      savedStateDuring = null;
    }
  }

  @RestrictTo(RestrictTo.Scope.LIBRARY)
  // TODO(bparrishMines): Replace with onSurfaceCleanup once available on stable. See
  // https://github.com/flutter/flutter/issues/161256.
  @SuppressWarnings({"deprecation", "removal"})
  public void onSurfaceDestroyed() {
    // Intentionally do not call pause/stop here, because the surface has already been released
    // at this point (see https://github.com/flutter/flutter/issues/156451).
    savedStateDuring = ExoPlayerState.save(exoPlayer);
    exoPlayer.release();
  }

  @Override
  protected boolean wasPlayerInitialized() {
    return savedStateDuring != null;
  }

  @Override
  protected Messages.PlatformVideoViewType getViewType() {
    return Messages.PlatformVideoViewType.TEXTURE_VIEW;
  }

  public void dispose() {
    // Super must be called first to ensure the player is released before the surface.
    super.dispose();

    surfaceProducer.release();
    // TODO(matanlurey): Remove when embedder no longer calls-back once released.
    // https://github.com/flutter/flutter/issues/156434.
    surfaceProducer.setCallback(null);
  }
}
