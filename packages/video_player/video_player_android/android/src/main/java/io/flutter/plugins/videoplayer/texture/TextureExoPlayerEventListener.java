// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.texture;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.Format;
import androidx.media3.common.VideoSize;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;
import java.util.Objects;

public final class TextureExoPlayerEventListener extends ExoPlayerEventListener {
  private final boolean surfaceProducerHandlesCropAndRotation;
  private boolean hasInitialized = false;

  public TextureExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer,
      @NonNull VideoPlayerCallbacks events,
      boolean surfaceProducerHandlesCropAndRotation) {
    super(exoPlayer, events);
    this.surfaceProducerHandlesCropAndRotation = surfaceProducerHandlesCropAndRotation;
  }

  @OptIn(markerClass = UnstableApi.class)
  @Override
  protected void sendInitialized() {
    // Only send initialization once with the initial format
    // Subsequent resolution changes are handled by ExoPlayer automatically
    if (hasInitialized) {
      return;
    }

    VideoSize videoSize = exoPlayer.getVideoSize();
    RotationDegrees rotationCorrection = RotationDegrees.ROTATE_0;
    int width = videoSize.width;
    int height = videoSize.height;
    
    if (width == 0 || height == 0) {
      // Video size not available yet, wait for next callback
      return;
    }

    hasInitialized = true;

    // When the SurfaceTexture backend for Impeller is used, the preview should already
    // be correctly rotated.
    if (!surfaceProducerHandlesCropAndRotation) {
      // The video's Format also provides a rotation correction that may be used to
      // correct the rotation, so we try to use that to correct the video rotation
      // when the ImageReader backend for Impeller is used.
      int rawVideoFormatRotation = getRotationCorrectionFromFormat(exoPlayer);

      try {
        rotationCorrection = RotationDegrees.fromDegrees(rawVideoFormatRotation);
      } catch (IllegalArgumentException e) {
        // Rotation correction other than 0, 90, 180, 270 reported by Format. Because this is
        // unexpected we apply no rotation correction.
        rotationCorrection = RotationDegrees.ROTATE_0;
      }
    }

    android.util.Log.d("TextureListener", 
        "Initialized with resolution: " + width + "x" + height + 
        ", rotation: " + rotationCorrection.getDegrees());

    events.onInitialized(width, height, exoPlayer.getDuration(), rotationCorrection.getDegrees());
  }

  @Override
  public void onVideoSizeChanged(@NonNull VideoSize videoSize) {
    android.util.Log.d("TextureListener", 
        "Resolution changed to: " + videoSize.width + "x" + videoSize.height);
    
    // Don't re-initialize - let ExoPlayer handle the resize
    // The texture surface will automatically adapt to new dimensions
    // This prevents the frame split issue during 720p -> 480p -> 360p transitions
  }

  @OptIn(markerClass = UnstableApi.class)
  // A video's Format and its rotation degrees are unstable because they are not guaranteed
  // the same implementation across API versions. It is possible that this logic may need
  // revisiting should the implementation change across versions of the Exoplayer API.
  private int getRotationCorrectionFromFormat(ExoPlayer exoPlayer) {
    Format videoFormat = Objects.requireNonNull(exoPlayer.getVideoFormat());
    return videoFormat.rotationDegrees;
  }
}