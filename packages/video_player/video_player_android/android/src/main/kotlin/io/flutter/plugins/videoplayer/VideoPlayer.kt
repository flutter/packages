// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.os.Handler
import android.os.Looper
import androidx.annotation.OptIn
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.Format
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector
import io.flutter.view.TextureRegistry.SurfaceProducer
import kotlin.math.max
import kotlin.math.min

/**
 * A class responsible for managing video playback using [ExoPlayer].
 *
 * It provides methods to control playback, adjust volume, and handle seeking.
 */
internal abstract class VideoPlayer
// Error thrown for this-escape warning on JDK 21+ due to
// https://bugs.openjdk.org/browse/JDK-8015831.
// Keeping behavior as-is and addressing the warning could cause a regression:
// https://github.com/flutter/packages/pull/10193
@Suppress("this-escape")
constructor(
    protected val videoPlayerEvents: VideoPlayerCallbacks,
    mediaItem: MediaItem,
    options: VideoPlayerOptions,
    protected val surfaceProducer: SurfaceProducer?,
    exoPlayerProvider: () -> ExoPlayer
) : VideoPlayerInstanceApi {
  private var disposeHandler: (() -> Unit)? = null
  private var exoPlayerEventListener: ExoPlayerEventListener?
  val exoPlayer: ExoPlayer = exoPlayerProvider()

  private val mainHandler = Handler(Looper.getMainLooper())
  private var isDisposed = false

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  init {
    exoPlayer.setMediaItem(mediaItem)
    exoPlayer.prepare()
    val listener = createExoPlayerEventListener(exoPlayer, surfaceProducer)
    exoPlayerEventListener = listener
    exoPlayer.addListener(listener)
    setAudioAttributes(exoPlayer, options.mixWithOthers)
  }

  fun setDisposeHandler(handler: (() -> Unit)?) {
    disposeHandler = handler
  }

  protected abstract fun createExoPlayerEventListener(
      exoPlayer: ExoPlayer,
      surfaceProducer: SurfaceProducer?
  ): ExoPlayerEventListener

  override fun play() {
    exoPlayer.play()
  }

  override fun pause() {
    exoPlayer.pause()
  }

  override fun setLooping(looping: Boolean) {
    exoPlayer.repeatMode = if (looping) Player.REPEAT_MODE_ALL else Player.REPEAT_MODE_OFF
  }

  override fun setVolume(volume: Double) {
    val bracketedValue = max(0.0, min(1.0, volume)).toFloat()
    exoPlayer.volume = bracketedValue
  }

  override fun setPlaybackSpeed(speed: Double) {
    // We do not need to consider pitch and skipSilence for now as we do not handle them and
    // therefore never diverge from the default values.
    val playbackParameters = PlaybackParameters(speed.toFloat())

    exoPlayer.playbackParameters = playbackParameters
  }

  override fun getCurrentPosition(): Long {
    return exoPlayer.currentPosition
  }

  override fun getBufferedPosition(): Long {
    return exoPlayer.bufferedPosition
  }

  override fun seekTo(position: Long) {
    exoPlayer.seekTo(position)
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(UnstableApi::class)
  override fun getAudioTracks(): NativeAudioTrackData {
    val audioTracks: List<ExoPlayerAudioTrackData> = buildList {
      // Iterate through all track groups
      exoPlayer.currentTracks.groups.forEachIndexed { groupIndex, group ->
        // Only process audio tracks
        if (group.type == C.TRACK_TYPE_AUDIO) {
          for (trackIndex in 0 ..< group.length) {
            val format = group.getTrackFormat(trackIndex)
            val isSelected = group.isTrackSelected(trackIndex)

            // Create audio track data with metadata
            val audioTrack =
                ExoPlayerAudioTrackData(
                    groupIndex.toLong(),
                    trackIndex.toLong(),
                    format.label,
                    format.language,
                    isSelected,
                    getFormatValue(format.bitrate),
                    getFormatValue(format.sampleRate),
                    getFormatValue(format.channelCount),
                    format.codecs)

            add(audioTrack)
          }
        }
      }
    }
    return NativeAudioTrackData(audioTracks)
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(UnstableApi::class)
  override fun selectAudioTrack(groupIndex: Long, trackIndex: Long) {
    val trackSelector = exoPlayer.trackSelector as? DefaultTrackSelector
    checkNotNull(trackSelector) { "Cannot select audio track: track selector is null" }

    // Get current tracks
    val tracks = exoPlayer.currentTracks

    require(groupIndex >= 0 && groupIndex < tracks.groups.size) {
      ("Cannot select audio track: groupIndex $groupIndex is out of bounds " +
          "(available groups: ${tracks.groups.size})")
    }

    val group = tracks.groups[groupIndex.toInt()]

    // Verify it's an audio track
    require(group.type == C.TRACK_TYPE_AUDIO) {
      ("Cannot select audio track: group at index $groupIndex is not an audio track " +
          "(type: ${group.type})")
    }

    // Verify the track index is valid
    require(trackIndex >= 0 && trackIndex < group.length) {
      ("Cannot select audio track: trackIndex $trackIndex is out of bounds " +
          "(available tracks in group: ${group.length})")
    }

    // Get the track group and create a selection override
    val trackGroup = group.mediaTrackGroup
    val override = TrackSelectionOverride(trackGroup, trackIndex.toInt())

    // Apply the track selection override
    trackSelector.setParameters(
        trackSelector.buildUponParameters().setOverrideForType(override).build())
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(UnstableApi::class)
  override fun getVideoTracks(): NativeVideoTrackData {
    val videoTracks: List<ExoPlayerVideoTrackData> = buildList {
      // Iterate through all track groups
      exoPlayer.currentTracks.groups.forEachIndexed { groupIndex, group ->
        // Only process video tracks
        if (group.type == C.TRACK_TYPE_VIDEO) {
          for (trackIndex in 0 ..< group.length) {
            val format = group.getTrackFormat(trackIndex)
            val isSelected = group.isTrackSelected(trackIndex)

            // Create video track data with metadata
            val videoTrack =
                ExoPlayerVideoTrackData(
                    groupIndex.toLong(),
                    trackIndex.toLong(),
                    format.label,
                    isSelected,
                    getFormatValue(format.bitrate),
                    getFormatValue(format.width),
                    getFormatValue(format.height),
                    getFormatValue(format.frameRate.toDouble()),
                    format.codecs)

            add(videoTrack)
          }
        }
      }
    }
    return NativeVideoTrackData(videoTracks)
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(UnstableApi::class)
  override fun enableAutoVideoQuality() {
    val trackSelector = exoPlayer.trackSelector as? DefaultTrackSelector
    checkNotNull(trackSelector) { "Cannot enable auto video quality: track selector is null" }

    // Clear video track override to enable adaptive streaming
    trackSelector.setParameters(
        trackSelector.buildUponParameters().clearOverridesOfType(C.TRACK_TYPE_VIDEO).build())
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(UnstableApi::class)
  override fun selectVideoTrack(groupIndex: Long, trackIndex: Long) {
    val trackSelector = exoPlayer.trackSelector as? DefaultTrackSelector
    checkNotNull(trackSelector) { "Cannot select video track: track selector is null" }

    // Get current tracks
    val tracks = exoPlayer.currentTracks

    require(groupIndex >= 0 && groupIndex < tracks.groups.size) {
      ("Cannot select video track: groupIndex $groupIndex is out of bounds " +
          "(available groups: ${tracks.groups.size})")
    }

    val group = tracks.groups[groupIndex.toInt()]

    // Verify it's a video track
    require(group.type == C.TRACK_TYPE_VIDEO) {
      ("Cannot select video track: group at index $groupIndex is not a video track " +
          "(type: ${group.type})")
    }

    // Verify the track index is valid
    require(trackIndex >= 0 && trackIndex < group.length) {
      ("Cannot select video track: trackIndex $trackIndex is out of bounds " +
          "(available tracks in group: ${group.length})")
    }

    // Get the track group and create a selection override
    val trackGroup = group.mediaTrackGroup
    val override = TrackSelectionOverride(trackGroup, trackIndex.toInt())

    // Check if the new track has different dimensions than the current track
    val currentFormat = exoPlayer.videoFormat
    val newFormat = trackGroup.getFormat(trackIndex.toInt())
    val dimensionsChanged =
        currentFormat == null ||
            currentFormat.width != newFormat.width ||
            currentFormat.height != newFormat.height

    // When video dimensions change, we need to force a complete renderer reset to avoid
    // surface rendering issues. We do this by temporarily disabling the video track type,
    // which causes ExoPlayer to release the current video renderer and MediaCodec decoder.
    // After a brief delay, we re-enable video with the new track selection, which creates
    // a fresh renderer properly configured for the new dimensions.
    //
    // Why is this necessary?
    // When switching between video tracks with different resolutions (e.g., 720p to 1080p),
    // the existing video surface and MediaCodec decoder may not properly reconfigure for the
    // new dimensions. This can cause visual glitches where the video appears in the wrong
    // position (e.g., top-left corner) or the old surface remains partially visible.
    // By disabling the video track type, we force ExoPlayer to completely release the
    // current renderer and decoder, ensuring a clean slate for the new resolution.
    //
    // References:
    // - ExoPlayer TrackSelection documentation:
    //   https://developer.android.com/media/media3/exoplayer/track-selection
    // - DefaultTrackSelector.setParameters() for track type disabling:
    //
    // https://developer.android.com/reference/androidx/media3/exoplayer/trackselection/DefaultTrackSelector.Parameters.Builder#setTrackTypeDisabled(int,boolean)
    // - This approach is necessary because ExoPlayer doesn't provide a direct API to force
    //   a renderer reset when dimensions change. Disabling and re-enabling the track type
    //   is the recommended way to ensure proper resource cleanup and reinitialization.
    // TODO(nateshmbhat): Remove this workaround once Media3 provides a supported
    // renderer reset path or reliable resolution-changing track switches.
    // https://github.com/flutter/flutter/issues/183824
    if (dimensionsChanged) {
      val wasPlaying = exoPlayer.isPlaying
      val currentPosition = exoPlayer.currentPosition

      // Disable video track type to force renderer release
      trackSelector.setParameters(
          trackSelector
              .buildUponParameters()
              .setTrackTypeDisabled(C.TRACK_TYPE_VIDEO, true)
              .build())

      // Re-enable video with the new track selection after allowing renderer to release.
      //
      // Why 150ms delay?
      // This delay is necessary to allow the MediaCodec decoder and video renderer to fully
      // release their resources before we attempt to create new ones. Without this delay,
      // the new decoder may be initialized before the old one is completely released, leading
      // to resource conflicts and rendering artifacts. The 150ms value was determined through
      // empirical testing across various Android devices and provides a reliable balance
      // between responsiveness and ensuring complete resource cleanup. Shorter delays (e.g.,
      // 50-100ms) were found to still cause glitches on some devices, while longer delays
      // would unnecessarily impact user experience.
      mainHandler.postDelayed(
          Runnable {
            // Guard against player disposal during the delay. The isDisposed flag
            // is the authoritative check; the trackSelector null-check is kept for
            // safety even though it is set in the constructor.
            if (isDisposed) {
              return@Runnable
            }

            trackSelector.setParameters(
                trackSelector
                    .buildUponParameters()
                    .setTrackTypeDisabled(C.TRACK_TYPE_VIDEO, false)
                    .setOverrideForType(override)
                    .build())

            // Restore playback state
            exoPlayer.seekTo(currentPosition)
            if (wasPlaying) {
              exoPlayer.play()
            }
          },
          150)
      return
    }

    // Apply the track selection override normally if dimensions haven't changed
    trackSelector.setParameters(
        trackSelector.buildUponParameters().setOverrideForType(override).build())
  }

  open fun dispose() {
    isDisposed = true
    mainHandler.removeCallbacksAndMessages(null)
    disposeHandler?.invoke()
    exoPlayerEventListener?.dispose()
    exoPlayerEventListener = null
    exoPlayer.release()
  }

  private companion object {
    fun setAudioAttributes(exoPlayer: ExoPlayer, isMixMode: Boolean) {
      exoPlayer.setAudioAttributes(
          AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(), !isMixMode)
    }

    /**
     * Helper method to extract a long value from a Format field, returning null if the value is
     * Format.NO_VALUE.
     *
     * @param value The format value to check.
     * @return The value as a Long, or null if it's Format.NO_VALUE.
     */
    fun getFormatValue(value: Int): Long? {
      return if (value != Format.NO_VALUE) value.toLong() else null
    }

    /**
     * Helper method to extract a double value from a Format field, returning null if the value is
     * Format.NO_VALUE.
     *
     * @param value The format value to check.
     * @return The value as a Double, or null if it's Format.NO_VALUE.
     */
    fun getFormatValue(value: Double): Double? {
      return if (value != Format.NO_VALUE.toDouble()) value else null
    }
  }
}
