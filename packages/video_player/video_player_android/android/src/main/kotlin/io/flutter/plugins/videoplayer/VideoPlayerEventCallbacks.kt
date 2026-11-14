// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import androidx.annotation.VisibleForTesting
import io.flutter.plugin.common.BinaryMessenger

internal class VideoPlayerEventCallbacks private constructor(
    private val eventSink: QueuingEventSink,
    private val eventChannel: VideoEventsEventChannel?
) : VideoPlayerCallbacks {
    @VisibleForTesting
    internal interface EventChannelFactory {
        fun create(
            messenger: BinaryMessenger?, handler: VideoEventsStreamHandler?, identifier: String?
        ): VideoEventsEventChannel?
    }

    override fun onInitialized(
        width: Int, height: Int, durationInMs: Long, rotationCorrectionInDegrees: Int
    ) {
        eventSink.success(
            InitializationEvent(
                durationInMs,
                width.toLong(),
                height.toLong(),
                rotationCorrectionInDegrees.toLong()
            )
        )
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
        if (eventChannel != null) {
            eventChannel.setStreamHandler(null)
        }
    }

    companion object {
        fun bindTo(
            binaryMessenger: BinaryMessenger, identifier: String
        ): VideoPlayerEventCallbacks {
            return bindTo(
                binaryMessenger,
                identifier,
                EventChannelFactory { messenger: BinaryMessenger?, streamHandler: VideoEventsStreamHandler?, instanceName: String? ->
                    VideoEventsStreamHandler.Companion.register(
                        messenger!!,
                        streamHandler!!,
                        instanceName!!
                    )
                })
        }

        @JvmStatic
        @VisibleForTesting
        fun bindTo(
            binaryMessenger: BinaryMessenger,
            identifier: String,
            factory: EventChannelFactory
        ): VideoPlayerEventCallbacks {
            val eventSink = QueuingEventSink()
            val eventChannel =
                factory.create(
                    binaryMessenger,
                    object : VideoEventsStreamHandler() {
                        public override fun onListen(
                            arguments: Any?, events: PigeonEventSink<PlatformVideoEvent?>
                        ) {
                            eventSink.setDelegate(events)
                        }

                        public override fun onCancel(arguments: Any?) {
                            eventSink.setDelegate(null)
                        }
                    },
                    identifier
                )
            return VideoPlayerEventCallbacks(eventSink, eventChannel)
        }

        @JvmStatic
        @VisibleForTesting
        fun withSink(eventSink: QueuingEventSink): VideoPlayerEventCallbacks {
            return VideoPlayerEventCallbacks(eventSink, null)
        }
    }
}
