// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.texture;

import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.Format;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;
import java.util.Objects;

public final class TextureExoPlayerEventListener extends ExoPlayerEventListener {
  @VisibleForTesting
  public TextureExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @NonNull VideoPlayerCallbacks events) {
    this(exoPlayer, events, false);
  }

  public TextureExoPlayerEventListener(
      @NonNull ExoPlayer exoPlayer, @NonNull VideoPlayerCallbacks events, boolean initialized) {
    super(exoPlayer, events, initialized);
  }

  @Override
  protected void sendInitialized() {
    VideoSize videoSize = exoPlayer.getVideoSize();
    int rotationCorrection = 0;
    int width = videoSize.width;
    int height = videoSize.height;
    if (width != 0 && height != 0) {
      RotationDegrees reportedRotationCorrection = RotationDegrees.ROTATE_0;

      if (Build.VERSION.SDK_INT <= 21) {
        // On API 21 and below, Exoplayer may not internally handle rotation correction
        // and reports it through VideoSize.unappliedRotationDegrees. We may apply it to
        // fix the case of upside-down playback.
        try {
          reportedRotationCorrection =
              RotationDegrees.fromDegrees(videoSize.unappliedRotationDegrees);
          rotationCorrection =
              getRotationCorrectionFromUnappliedRotation(reportedRotationCorrection);
        } catch (IllegalArgumentException e) {
          // Unapplied rotation other than 0, 90, 180, 270 reported by VideoSize. Because this is
          // unexpected, we apply no rotation correction.
          reportedRotationCorrection = RotationDegrees.ROTATE_0;
          rotationCorrection = 0;
        }
      }
      // TODO(camsim99): Replace this with a call to `handlesCropAndRotation` when it is
      // available in stable. https://github.com/flutter/flutter/issues/157198
      else if (Build.VERSION.SDK_INT < 29) {
        // When the SurfaceTexture backend for Impeller is used, the preview should already
        // be correctly rotated.
        rotationCorrection = 0;
      } else {
        // The video's Format also provides a rotation correction that may be used to
        // correct the rotation, so we try to use that to correct the video rotation
        // when the ImageReader backend for Impeller is used.
        rotationCorrection = getRotationCorrectionFromFormat(exoPlayer);

        try {
          reportedRotationCorrection = RotationDegrees.fromDegrees(rotationCorrection);
        } catch (IllegalArgumentException e) {
          // Rotation correction other than 0, 90, 180, 270 reported by Format. Because this is
          // unexpected we apply no rotation correction.
          reportedRotationCorrection = RotationDegrees.ROTATE_0;
          rotationCorrection = 0;
        }
      }

      // Switch the width/height if video was taken in portrait mode and a rotation
      // correction was detected.
      if (reportedRotationCorrection == RotationDegrees.ROTATE_90
          || reportedRotationCorrection == RotationDegrees.ROTATE_270) {
        width = videoSize.height;
        height = videoSize.width;
      }
    }
    events.onInitialized(width, height, exoPlayer.getDuration(), rotationCorrection);
  }

  private int getRotationCorrectionFromUnappliedRotation(RotationDegrees unappliedRotationDegrees) {
    int rotationCorrection = 0;

    // Rotating the video with ExoPlayer does not seem to be possible with a Surface,
    // so inform the Flutter code that the widget needs to be rotated to prevent
    // upside-down playback for videos with unappliedRotationDegrees of 180 (other orientations
    // work correctly without correction).
    if (unappliedRotationDegrees == RotationDegrees.ROTATE_180) {
      rotationCorrection = unappliedRotationDegrees.getDegrees();
    }

    return rotationCorrection;
  }

  @OptIn(markerClass = androidx.media3.common.util.UnstableApi.class)
  // A video's Format and its rotation degrees are unstable because they are not guaranteed
  // the same implementation across API versions. It is possible that this logic may need
  // revisiting should the implementation change across versions of the Exoplayer API.
  private int getRotationCorrectionFromFormat(ExoPlayer exoPlayer) {
    Format videoFormat = Objects.requireNonNull(exoPlayer.getVideoFormat());
    return videoFormat.rotationDegrees;
  }
}
