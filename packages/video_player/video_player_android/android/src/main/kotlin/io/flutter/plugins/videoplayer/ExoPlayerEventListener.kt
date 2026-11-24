// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.os.Handler
import android.os.Looper
import androidx.media3.common.C
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.Timeline
import androidx.media3.common.Tracks
import androidx.media3.exoplayer.ExoPlayer

internal abstract class ExoPlayerEventListener(
    protected val exoPlayer: ExoPlayer,
    protected val events: VideoPlayerCallbacks
) : Player.Listener {
  private var isInitialized = false
  private var isWaitingForValidDuration = false
  private val mainHandler = Handler(Looper.getMainLooper())
  private val initializationFallback = Runnable {
    if (!isInitialized && isWaitingForValidDuration) {
      isWaitingForValidDuration = false
      isInitialized = true
      sendInitialized()
    }
  }

  protected enum class RotationDegrees(val degrees: Int) {
    ROTATE_0(0),
    ROTATE_90(90),
    ROTATE_180(180),
    ROTATE_270(270);

    companion object {
      fun fromDegrees(degrees: Int): RotationDegrees {
        for (rotationDegrees in entries) {
          if (rotationDegrees.degrees == degrees) {
            return rotationDegrees
          }
        }
        throw IllegalArgumentException("Invalid rotation degrees specified: $degrees")
      }
    }
  }

  protected abstract fun sendInitialized()

  /** Cancels pending initialization callbacks when the player is disposed. */
  fun dispose() {
    isWaitingForValidDuration = false
    mainHandler.removeCallbacks(initializationFallback)
    events.onDisposed()
  }

  private fun hasValidDuration(): Boolean {
    return exoPlayer.duration != C.TIME_UNSET
  }

  private fun shouldWaitForValidDuration(): Boolean {
    return !exoPlayer.isCurrentMediaItemLive && !exoPlayer.isCurrentMediaItemDynamic
  }

  private fun maybeSendInitialized() {
    if (isInitialized) {
      return
    }

    if (!hasValidDuration() && shouldWaitForValidDuration()) {
      if (!isWaitingForValidDuration) {
        isWaitingForValidDuration = true
        mainHandler.postDelayed(initializationFallback, DURATION_UNSET_INITIALIZATION_TIMEOUT_MS)
      }
      return
    }

    isWaitingForValidDuration = false
    isInitialized = true
    mainHandler.removeCallbacks(initializationFallback)
    sendInitialized()
  }

  override fun onPlaybackStateChanged(playbackState: Int) {
    val platformState =
        when (playbackState) {
          Player.STATE_BUFFERING -> PlatformPlaybackState.BUFFERING
          Player.STATE_READY -> {
            maybeSendInitialized()
            PlatformPlaybackState.READY
          }
          Player.STATE_ENDED -> PlatformPlaybackState.ENDED
          Player.STATE_IDLE -> PlatformPlaybackState.IDLE
          else -> PlatformPlaybackState.UNKNOWN
        }
    events.onPlaybackStateChanged(platformState)
  }

  override fun onTimelineChanged(timeline: Timeline, reason: Int) {
    if (isWaitingForValidDuration && exoPlayer.playbackState == Player.STATE_READY) {
      maybeSendInitialized()
    }
  }

  override fun onPlayerError(error: PlaybackException) {
    if (error.errorCode == PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW) {
      // See
      // https://exoplayer.dev/live-streaming.html#behindlivewindowexception-and-error_code_behind_live_window
      exoPlayer.seekToDefaultPosition()
      exoPlayer.prepare()
    } else {
      events.onError("VideoError", "Video player had error $error", null)
    }
  }

  override fun onIsPlayingChanged(isPlaying: Boolean) {
    events.onIsPlayingStateUpdate(isPlaying)
  }

  override fun onTracksChanged(tracks: Tracks) {
    // Find the currently selected audio track and notify
    val selectedAudioTrackId = findSelectedAudioTrackId(tracks)
    events.onAudioTrackChanged(selectedAudioTrackId)

    // Find the currently selected video track and notify
    val selectedVideoTrackId = findSelectedVideoTrackId(tracks)
    events.onVideoTrackChanged(selectedVideoTrackId)
  }

  /**
   * Finds the ID of the currently selected audio track.
   *
   * @param tracks The current tracks
   * @return The track ID in format "groupIndex_trackIndex", or null if no audio track is selected
   */
  private fun findSelectedAudioTrackId(tracks: Tracks): String? {
    // Keep this ID format in sync with android_video_player.dart::_parseAndroidTrackId.
    for ((groupIndex, group) in tracks.groups.withIndex()) {
      if (group.type == C.TRACK_TYPE_AUDIO && group.isSelected) {
        // Find the selected track within this group
        for (i in 0 ..< group.length) {
          if (group.isTrackSelected(i)) {
            return "${groupIndex}_$i"
          }
        }
      }
    }
    return null
  }

  /**
   * Finds the ID of the currently selected video track.
   *
   * @param tracks The current tracks
   * @return The track ID in format "groupIndex_trackIndex", or null if no video track is selected
   */
  private fun findSelectedVideoTrackId(tracks: Tracks): String? {
    // Keep this ID format in sync with android_video_player.dart::_parseAndroidTrackId.
    for ((groupIndex, group) in tracks.groups.withIndex()) {
      if (group.type == C.TRACK_TYPE_VIDEO && group.isSelected) {
        // Find the selected track within this group
        for (i in 0 ..< group.length) {
          if (group.isTrackSelected(i)) {
            return "${groupIndex}_$i"
          }
        }
      }
    }
    return null
  }

  companion object {
    internal const val DURATION_UNSET_INITIALIZATION_TIMEOUT_MS: Long = 2000
  }
}
