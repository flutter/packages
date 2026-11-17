// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

/**
 * Callbacks representing events invoked by [VideoPlayer].
 *
 * In the actual plugin, this will always be [VideoPlayerEventCallbacks], which creates the expected
 * events to send back through the plugin channel. In tests methods can be overridden in order to
 * assert results.
 *
 * See [androidx.media3.common.Player.Listener] for details.
 */
internal interface VideoPlayerCallbacks {
  fun onInitialized(width: Int, height: Int, durationInMs: Long, rotationCorrectionInDegrees: Int)

  fun onPlaybackStateChanged(state: PlatformPlaybackState)

  fun onError(code: String, message: String?, details: Any?)

  fun onIsPlayingStateUpdate(isPlaying: Boolean)

  fun onAudioTrackChanged(selectedTrackId: String?)

  fun onVideoTrackChanged(selectedTrackId: String?)

  /* Called when the player is disposed and the channel is no longer needed. */
  fun onDisposed()
}
