// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer.platformview

import android.content.Context
import android.os.Build
import android.view.Surface
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import io.flutter.plugin.platform.PlatformView

/**
 * A class used to create a native video view that can be embedded in a Flutter app. It wraps an
 * [ExoPlayer] instance and displays its video content.
 */
internal class PlatformVideoView
@OptIn(UnstableApi::class)
/**
 * Constructs a new PlatformVideoView.
 *
 * @param context The context in which the view is running.
 * @param exoPlayer The ExoPlayer instance used to play the video.
 */
constructor(context: Context, exoPlayer: ExoPlayer) : PlatformView {
  private val surfaceView: SurfaceView = VideoSurfaceView(context, exoPlayer)

  init {
    setupSurfaceWithCallback(exoPlayer)

    if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.N_MR1) {
      // Avoid blank space instead of a video on Android versions below 8 by adjusting video's
      // z-layer within the Android view hierarchy:
      surfaceView.setZOrderMediaOverlay(true)
    }
  }

  private fun setupSurfaceWithCallback(exoPlayer: ExoPlayer) {
    surfaceView.holder.addCallback(
        object : SurfaceHolder.Callback {
          override fun surfaceCreated(holder: SurfaceHolder) {
            bindPlayerToSurface(exoPlayer, holder.surface)
            forceFirstFrameForAndroid9(exoPlayer)
          }

          override fun surfaceChanged(
              holder: SurfaceHolder,
              format: Int,
              width: Int,
              height: Int
          ) {}

          override fun surfaceDestroyed(holder: SurfaceHolder) {
            // Use clearVideoSurface to ensure we only unbind if this surface is currently
            // active.
            exoPlayer.clearVideoSurface(holder.surface)
          }
        })
  }

  /**
   * A custom SurfaceView that re-attaches the player surface when the view becomes visible again,
   * such as after returning from a full-screen route transition.
   */
  private class VideoSurfaceView(context: Context?, private val exoPlayer: ExoPlayer) :
      SurfaceView(context) {
    protected override fun onVisibilityChanged(changedView: View, visibility: Int) {
      super.onVisibilityChanged(changedView, visibility)
      // When the view becomes visible again, re-attach the current surface.
      if (visibility == VISIBLE && isShown) {
        bindPlayerToSurface(exoPlayer, holder.surface)
      }
    }
  }

  /**
   * Returns the view associated with this PlatformView.
   *
   * @return The SurfaceView used to display the video.
   */
  override fun getView(): View {
    return surfaceView
  }

  /** Disposes of the resources used by this PlatformView. */
  override fun dispose() {
    surfaceView.holder.surface.release()
  }

  private companion object {
    /** Binds the ExoPlayer to the provided surface. */
    fun bindPlayerToSurface(exoPlayer: ExoPlayer, surface: Surface) {
      if (surface.isValid) {
        exoPlayer.setVideoSurface(surface)
      }
    }

    /**
     * Workaround for a rendering bug on Android 9 (API 28) where the decoder does not flush its
     * output buffer when a new surface is attached while the player is paused.
     */
    fun forceFirstFrameForAndroid9(exoPlayer: ExoPlayer) {
      if (Build.VERSION.SDK_INT == Build.VERSION_CODES.P && !exoPlayer.playWhenReady) {
        val position = exoPlayer.currentPosition
        exoPlayer.seekTo(if (position == 0L) 1 else position)
      }
    }
  }
}
