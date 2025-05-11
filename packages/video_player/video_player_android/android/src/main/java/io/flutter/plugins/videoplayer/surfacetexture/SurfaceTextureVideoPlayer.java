// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer.surfacetexture;

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
import android.view.Surface;

import io.flutter.plugins.videoplayer.texture.TextureExoPlayerEventListener;

import io.flutter.view.TextureRegistry;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;

/**
 * A subclass of {@link VideoPlayer} that adds functionality related to texture
 * view as a way of displaying the video in the app.
 *
 * <p>
 * It manages the lifecycle of the texture and ensures that the video is
 * properly displayed on the texture.
 */
public final class SurfaceTextureVideoPlayer extends VideoPlayer {

    @NonNull
    private Surface surface;
    @NonNull
    private final TextureRegistry.SurfaceTextureEntry textureEntry;
    @Nullable
    private ExoPlayerState savedStateDuring;

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
    public static SurfaceTextureVideoPlayer create(
            @NonNull Context context,
            @NonNull VideoPlayerCallbacks events,
            @NonNull TextureRegistry.SurfaceTextureEntry textureEntry,
            @NonNull VideoAsset asset,
            @NonNull VideoPlayerOptions options) {
        return new SurfaceTextureVideoPlayer(
                events,
                textureEntry,
                asset.getMediaItem(),
                options,
                () -> {
                    ExoPlayer.Builder builder
                    = new ExoPlayer.Builder(context)
                            .setMediaSourceFactory(asset.getMediaSourceFactory(context));
                    return builder.build();
                });
    }

    @VisibleForTesting
    public SurfaceTextureVideoPlayer(
            @NonNull VideoPlayerCallbacks events,
            @NonNull TextureRegistry.SurfaceTextureEntry textureEntry,
            @NonNull MediaItem mediaItem,
            @NonNull VideoPlayerOptions options,
            @NonNull ExoPlayerProvider exoPlayerProvider) {
        super(events, mediaItem, options, exoPlayerProvider);

        this.textureEntry = textureEntry;
        this.surface = new Surface(textureEntry.surfaceTexture());

        this.exoPlayer.setVideoSurface(this.surface);
    }

    @NonNull
    @Override
    protected ExoPlayerEventListener createExoPlayerEventListener(@NonNull ExoPlayer exoPlayer) {
        return new TextureExoPlayerEventListener(exoPlayer, videoPlayerEvents, playerHasBeenSuspended());
    }

    @RestrictTo(RestrictTo.Scope.LIBRARY)
    public void onSurfaceAvailable() {
        if (savedStateDuring != null) {
            exoPlayer = createVideoPlayer();
            surface = new Surface(textureEntry.surfaceTexture());
            exoPlayer.setVideoSurface(surface);
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

    private boolean playerHasBeenSuspended() {
        return savedStateDuring != null;
    }

    public void dispose() {
        // Super must be called first to ensure the player is released before the surface.
        super.dispose();

        textureEntry.release();
        if (surface != null) {
            surface.release();
        }
    }
}
