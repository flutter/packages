// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer.texture

import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import io.flutter.plugins.videoplayer.ExoPlayerEventListener
import io.flutter.plugins.videoplayer.ExoPlayerEventListener.RotationDegrees.Companion.fromDegrees
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks
import kotlin.math.max
import kotlin.math.roundToInt

internal class TextureExoPlayerEventListener(
    exoPlayer: ExoPlayer,
    events: VideoPlayerCallbacks,
    private val surfaceProducerHandlesCropAndRotation: Boolean
) : ExoPlayerEventListener(exoPlayer, events) {
  override fun sendInitialized() {
    val videoSize = exoPlayer.videoSize
    var rotationCorrection = RotationDegrees.ROTATE_0
    var width = videoSize.width
    val height = videoSize.height
    if (width != 0 && height != 0) {
      // Anamorphic content is stored with non-square pixels, so the coded width has to be
      // scaled by the pixel aspect ratio to obtain the display width. ExoPlayer reports a
      // pixelWidthHeightRatio that already accounts for any applied rotation, so this is
      // correct regardless of the rotation correction computed below.
      // Clamped to at least one pixel so that a malformed ratio cannot report a zero width.
      val pixelWidthHeightRatio = videoSize.pixelWidthHeightRatio
      if (pixelWidthHeightRatio > 0 && pixelWidthHeightRatio != 1f) {
        width = max(1, (width * pixelWidthHeightRatio).roundToInt())
      }

      // When the SurfaceTexture backend for Impeller is used, the preview should already
      // be correctly rotated.
      if (!surfaceProducerHandlesCropAndRotation) {
        // The video's Format also provides a rotation correction that may be used to
        // correct the rotation, so we try to use that to correct the video rotation
        // when the ImageReader backend for Impeller is used.
        val rawVideoFormatRotation = getRotationCorrectionFromFormat(exoPlayer)

        rotationCorrection =
            try {
              fromDegrees(rawVideoFormatRotation)
            } catch (_: IllegalArgumentException) {
              // Rotation correction other than 0, 90, 180, 270 reported by Format. Because this is
              // unexpected we apply no rotation correction.
              RotationDegrees.ROTATE_0
            }
      }
    }
    events.onInitialized(width, height, exoPlayer.duration, rotationCorrection.degrees)
  }

  // A video's Format and its rotation degrees are unstable because they are not guaranteed
  // the same implementation across API versions. It is possible that this logic may need
  // revisiting should the implementation change across versions of the Exoplayer API.
  @OptIn(UnstableApi::class)
  private fun getRotationCorrectionFromFormat(exoPlayer: ExoPlayer): Int {
    return exoPlayer.videoFormat?.rotationDegrees ?: 0
  }
}
