// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer.platformview

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugins.videoplayer.AndroidVideoPlayerApi.Companion.codec
import io.flutter.plugins.videoplayer.PlatformVideoViewCreationParams
import io.flutter.plugins.videoplayer.VideoPlayer

/**
 * A factory class responsible for creating platform video views that can be embedded in a Flutter
 * app.
 */
internal class PlatformVideoViewFactory
/**
 * Constructs a new PlatformVideoViewFactory.
 *
 * @param videoPlayerProvider The provider used to retrieve the video player associated with the
 *   view.
 */
(private val videoPlayerProvider: VideoPlayerProvider) : PlatformViewFactory(codec) {
  /** Functional interface for providing a VideoPlayer instance based on the player ID. */
  fun interface VideoPlayerProvider {
    /**
     * Retrieves a VideoPlayer instance based on the provided player ID.
     *
     * @param playerId The unique identifier for the video player.
     * @return A VideoPlayer instance associated with the given player ID.
     */
    fun getVideoPlayer(playerId: Long): VideoPlayer
  }

  /**
   * Creates a new instance of platform view.
   *
   * @param context The context in which the view is running.
   * @param id The unique identifier for the view.
   * @param args The arguments for creating the view.
   * @return A new instance of PlatformVideoView.
   */
  override fun create(context: Context, id: Int, args: Any?): PlatformView {
    val params = args as PlatformVideoViewCreationParams
    val playerId = params.playerId

    val player = videoPlayerProvider.getVideoPlayer(playerId)
    val exoPlayer = player.exoPlayer

    return PlatformVideoView(context, exoPlayer)
  }
}
