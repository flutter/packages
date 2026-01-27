// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.platformview;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.Format;
import androidx.media3.common.VideoSize;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;
import java.util.Objects;

public final class PlatformViewExoPlayerEventListener extends ExoPlayerEventListener {
  
  // Track the initial format to avoid re-initialization on resolution changes
  private Format initialVideoFormat = null;
  private boolean hasInitialized = false;

  public PlatformViewExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @NonNull VideoPlayerCallbacks events) {
    super(exoPlayer, events);
  }

  @OptIn(markerClass = UnstableApi.class)
  @Override
  protected void sendInitialized() {
    // Only send initialization once with the initial format
    // Subsequent resolution changes are handled by ExoPlayer automatically
    if (hasInitialized) {
      return;
    }

    Format videoFormat = exoPlayer.getVideoFormat();
    if (videoFormat == null) {
      // Format not available yet, wait for next callback
      return;
    }

    // Store the initial format
    initialVideoFormat = videoFormat;
    hasInitialized = true;

    RotationDegrees rotationCorrection =
        RotationDegrees.fromDegrees(videoFormat.rotationDegrees);
    int width = videoFormat.width;
    int height = videoFormat.height;

    // Switch the width/height if video was taken in portrait mode and a rotation
    // correction was detected.
    if (rotationCorrection == RotationDegrees.ROTATE_90
        || rotationCorrection == RotationDegrees.ROTATE_270) {
      width = videoFormat.height;
      height = videoFormat.width;
      rotationCorrection = RotationDegrees.fromDegrees(0);
    }

    android.util.Log.d("PlatformViewListener", 
        "Initialized with resolution: " + width + "x" + height);

    events.onInitialized(width, height, exoPlayer.getDuration(), rotationCorrection.getDegrees());
  }

  @Override
  public void onVideoSizeChanged(@NonNull VideoSize videoSize) {
    // Log resolution changes for debugging
    android.util.Log.d("PlatformViewListener", 
        "Resolution changed to: " + videoSize.width + "x" + videoSize.height);
    
    // Don't re-initialize - let ExoPlayer and TextureView handle the resize
    // The TextureView will automatically adapt to new dimensions
    // This prevents the frame split issue during 720p -> 480p -> 360p transitions
  }
}