// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.platformview;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;

@UnstableApi
public final class PlatformVideoView implements PlatformView {

    @NonNull
    private final TextureView textureView;

    @NonNull
    private final ExoPlayer exoPlayer;

    private Surface surface;

    public PlatformVideoView(
            @NonNull Context context,
            @NonNull ExoPlayer exoPlayer
    ) {
        this.exoPlayer = exoPlayer;
        this.textureView = new TextureView(context);

        textureView.setSurfaceTextureListener(
                new TextureView.SurfaceTextureListener() {
                    @Override
                    public void onSurfaceTextureAvailable(
                            @NonNull SurfaceTexture surfaceTexture,
                            int width,
                            int height
                    ) {
                        surface = new Surface(surfaceTexture);
                        exoPlayer.setVideoSurface(surface);
                    }

                    @Override
                    public void onSurfaceTextureSizeChanged(
                            @NonNull SurfaceTexture surfaceTexture,
                            int width,
                            int height
                    ) {
                        // ExoPlayer handles HLS adaptive bitrate resolution changes automatically.
                        // No need to recreate the surface - doing so causes frame misalignment issues.
                        // The MediaCodec decoder will seamlessly adapt to the new resolution.
                    }

                    @Override
                    public boolean onSurfaceTextureDestroyed(
                            @NonNull SurfaceTexture surfaceTexture
                    ) {
                        exoPlayer.setVideoSurface(null);
                        if (surface != null) {
                            surface.release();
                            surface = null;
                        }
                        return true; // TextureView can safely release the SurfaceTexture
                    }

                    @Override
                    public void onSurfaceTextureUpdated(
                            @NonNull SurfaceTexture surfaceTexture
                    ) {
                        // No-op
                    }
                }
        );
    }

    @NonNull
    @Override
    public View getView() {
        return textureView;
    }

    @Override
    public void dispose() {
        // Remove listener to prevent callback leaks
        textureView.setSurfaceTextureListener(null);
        
        exoPlayer.setVideoSurface(null);
        
        if (surface != null) {
            surface.release();
            surface = null;
        }
    }
}