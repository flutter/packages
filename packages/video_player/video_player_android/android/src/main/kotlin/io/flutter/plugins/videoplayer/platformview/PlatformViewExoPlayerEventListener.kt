// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer.platformview

import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import io.flutter.plugins.videoplayer.ExoPlayerEventListener
import io.flutter.plugins.videoplayer.ExoPlayerEventListener.RotationDegrees.Companion.fromDegrees
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks
import kotlin.math.max
import kotlin.math.roundToInt

internal class PlatformViewExoPlayerEventListener(
    exoPlayer: ExoPlayer,
    events: VideoPlayerCallbacks
) : ExoPlayerEventListener(exoPlayer, events) {
  @OptIn(UnstableApi::class)
  override fun sendInitialized() {
    // We can't rely on VideoSize here, because at this point it is not available - the platform
    // view was not created yet. We use the video format instead.
    val videoFormat =
        exoPlayer.videoFormat
            ?: throw IllegalStateException("sendInitialized called with no video playing")
    var rotationCorrection = fromDegrees(videoFormat.rotationDegrees)
    var width = videoFormat.width
    var height = videoFormat.height

    // Anamorphic content is stored with non-square pixels, so the coded width has to be
    // scaled by the pixel aspect ratio to obtain the display width. This is applied before
    // the rotation swap below, because Format reports the ratio for the unrotated frame.
    // Width is only scaled when it is known (Format.NO_VALUE is negative), and is clamped to at
    // least one pixel so that a malformed ratio cannot report a zero width.
    val pixelWidthHeightRatio = videoFormat.pixelWidthHeightRatio
    if (width > 0 && pixelWidthHeightRatio > 0 && pixelWidthHeightRatio != 1f) {
      width = max(1, (width * pixelWidthHeightRatio).roundToInt())
    }

    // Switch the width/height if video was taken in portrait mode and a rotation
    // correction was detected.
    if (rotationCorrection == RotationDegrees.ROTATE_90 ||
        rotationCorrection == RotationDegrees.ROTATE_270) {
      val displayWidth = width
      width = height
      height = displayWidth

      rotationCorrection = RotationDegrees.ROTATE_0
    }

    events.onInitialized(width, height, exoPlayer.duration, rotationCorrection.degrees)
  }
}
