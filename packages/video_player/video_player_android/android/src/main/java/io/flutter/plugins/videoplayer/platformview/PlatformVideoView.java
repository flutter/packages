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

/**
 * A {@link PlatformView} that displays video content using a {@link TextureView}.
 *
 * <p>TextureView is used instead of SurfaceView to support seamless resolution changes during
 * adaptive bitrate streaming (HLS/DASH). SurfaceView operates on a separate window layer which
 * can cause visual artifacts when the video resolution changes mid-playback.
 */
@UnstableApi
public final class PlatformVideoView implements PlatformView {
  @NonNull private final TextureView textureView;
  @NonNull private final ExoPlayer exoPlayer;
  private Surface surface;

  /**
   * Constructs a new PlatformVideoView.
   *
   * @param context The context in which the view is running.
   * @param exoPlayer The ExoPlayer instance used to play the video.
   */
  public PlatformVideoView(@NonNull Context context, @NonNull ExoPlayer exoPlayer) {
    this.exoPlayer = exoPlayer;
    this.textureView = new TextureView(context);

    textureView.setSurfaceTextureListener(
        new TextureView.SurfaceTextureListener() {
          @Override
          public void onSurfaceTextureAvailable(
              @NonNull SurfaceTexture surfaceTexture, int width, int height) {
            surface = new Surface(surfaceTexture);
            exoPlayer.setVideoSurface(surface);
          }

          @Override
          public void onSurfaceTextureSizeChanged(
              @NonNull SurfaceTexture surfaceTexture, int width, int height) {
            // No-op: ExoPlayer handles resolution changes during adaptive bitrate streaming.
            // The MediaCodec decoder seamlessly adapts to the new resolution.
          }

          @Override
          public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surfaceTexture) {
            exoPlayer.setVideoSurface(null);
            if (surface != null) {
              surface.release();
              surface = null;
            }
            return true;
          }

          @Override
          public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surfaceTexture) {
            // No-op.
          }
        });
  }

  /**
   * Returns the view associated with this PlatformView.
   *
   * @return The TextureView used to display the video.
   */
  @NonNull
  @Override
  public View getView() {
    return textureView;
  }

  /** Disposes of the resources used by this PlatformView. */
  @Override
  public void dispose() {
    textureView.setSurfaceTextureListener(null);
    exoPlayer.setVideoSurface(null);
    if (surface != null) {
      surface.release();
      surface = null;
    }
  }
}
