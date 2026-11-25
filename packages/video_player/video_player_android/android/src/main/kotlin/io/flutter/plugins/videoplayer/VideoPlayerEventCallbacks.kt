// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import androidx.annotation.VisibleForTesting
import io.flutter.plugin.common.BinaryMessenger

internal class VideoPlayerEventCallbacks
private constructor(
    private val eventSink: QueuingEventSink,
    private val eventChannel: VideoEventsEventChannel?
) : VideoPlayerCallbacks {

  override fun onInitialized(
      width: Int,
      height: Int,
      durationInMs: Long,
      rotationCorrectionInDegrees: Int
  ) {
    eventSink.success(
        InitializationEvent(
            durationInMs, width.toLong(), height.toLong(), rotationCorrectionInDegrees.toLong()))
  }

  override fun onPlaybackStateChanged(state: PlatformPlaybackState) {
    eventSink.success(PlaybackStateChangeEvent(state))
  }

  override fun onError(code: String, message: String?, details: Any?) {
    eventSink.error(code, message, details)
  }

  override fun onIsPlayingStateUpdate(isPlaying: Boolean) {
    eventSink.success(IsPlayingStateEvent(isPlaying))
  }

  override fun onAudioTrackChanged(selectedTrackId: String?) {
    eventSink.success(AudioTrackChangedEvent(selectedTrackId))
  }

  override fun onVideoTrackChanged(selectedTrackId: String?) {
    eventSink.success(VideoTrackChangedEvent(selectedTrackId))
  }

  override fun onDisposed() {
    eventChannel?.setStreamHandler(null)
  }

  companion object {
    fun bindTo(binaryMessenger: BinaryMessenger, identifier: String): VideoPlayerEventCallbacks =
        bindTo(binaryMessenger, identifier, VideoEventsStreamHandler::register)

    @VisibleForTesting
    fun bindTo(
        binaryMessenger: BinaryMessenger,
        identifier: String,
        eventChannelFactory:
            (
                messenger: BinaryMessenger,
                handler: VideoEventsStreamHandler,
                identifier: String) -> VideoEventsEventChannel
    ): VideoPlayerEventCallbacks {
      val eventSink = QueuingEventSink()
      val eventChannel =
          eventChannelFactory(
              binaryMessenger,
              object : VideoEventsStreamHandler() {
                override fun onListen(p0: Any?, sink: PigeonEventSink<PlatformVideoEvent>) {
                  eventSink.setDelegate(sink)
                }

                override fun onCancel(p0: Any?) {
                  eventSink.setDelegate(null)
                }
              },
              identifier)
      return VideoPlayerEventCallbacks(eventSink, eventChannel)
    }

    @VisibleForTesting
    fun withSink(eventSink: QueuingEventSink): VideoPlayerEventCallbacks {
      return VideoPlayerEventCallbacks(eventSink, null)
    }
  }
}
