// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

private enum QueueableEvent {
  case event(PlatformVideoEvent)
  case error(FlutterError)
}

@MainActor final class EventBridge: VideoEventsStreamHandler, VideoEventListener {
  /// The event sink associated with eventChannel.
  ///
  /// Will be nil both before the channel listener is ready on the Dart side, and after it has been
  /// closed on the Dart side.
  private var eventSink: PigeonEventSink<PlatformVideoEvent>?

  /// A queue of events received before eventSink is ready, to dispatch once the channel is fully
  /// set up.
  private var queuedEvents: [QueueableEvent]? = []

  /// The event channel registration, for later unregistering.
  private var eventChannel: VideoEventsEventChannel?

  init(messenger: FlutterBinaryMessenger, channelSuffix: String) {
    super.init()
    eventChannel = VideoEventsStreamHandler.register(
      with: messenger,
      instanceName: channelSuffix,
      streamHandler: self,
    )
  }

  // MARK: VideoEventsStreamHandler

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<PlatformVideoEvent>) {
    // Work around lack of annotations in Pigeon-generated code. See
    // https://github.com/flutter/flutter/issues/195012
    MainActor.assumeIsolated {
      eventSink = sink

      // Send any events that came in before the sink was ready.
      if let queuedEvents = queuedEvents {
        for event in queuedEvents {
          switch event {
          case .event(let videoEvent):
            sink.success(videoEvent)
          case .error(let errorEvent):
            sink.error(
              code: errorEvent.code, message: errorEvent.message, details: errorEvent.details)
          }
        }
      }
      self.queuedEvents?.removeAll()
    }
  }

  override func onCancel(withArguments arguments: Any?) {
    // Work around lack of annotations in Pigeon-generated code. See
    // https://github.com/flutter/flutter/issues/195012
    MainActor.assumeIsolated {
      eventSink = nil
      // No need to queue events coming in after this point; nil the queue so they will be discarded.
      queuedEvents = nil
    }
  }

  // MARK: VideoEventListener

  func videoPlayerDidInitialize(withDuration duration: Int64, size: CGSize) {
    sendOrQueueEvent(
      InitializationEvent(durationMilliseconds: duration, width: size.width, height: size.height))
  }

  func videoPlayerDidError(withMessage errorMessage: String) {
    sendOrQueueError(FlutterError(code: "VideoError", message: errorMessage, details: nil))
  }

  func videoPlayerDidComplete() {
    sendOrQueueEvent(PlaybackCompleteEvent())
  }

  func videoPlayerDidStartBuffering() {
    sendOrQueueEvent(BufferingStartEvent())
  }

  func videoPlayerDidEndBuffering() {
    sendOrQueueEvent(BufferingEndEvent())
  }

  func videoPlayerDidUpdateBufferRegions(_ regions: [PlatformDurationRange]) {
    sendOrQueueEvent(BufferingUpdateEvent(bufferedRanges: regions))
  }

  func videoPlayerDidSetPlaying(_ playing: Bool) {
    sendOrQueueEvent(IsPlayingStateEvent(isPlaying: playing))
  }

  func videoPlayerWasDisposed() {
    eventChannel?.setStreamHandler(nil)
    eventChannel = nil
    // Ignore any future events
    eventSink = nil
    queuedEvents = nil
  }

  // MARK: Private methods

  /// Sends the given event to the event sink if it is ready to receive events, or enqueues it to send
  /// later if not.
  private func sendOrQueueEvent(_ event: PlatformVideoEvent) {
    if let eventSink = self.eventSink {
      eventSink.success(event)
    } else {
      self.queuedEvents?.append(.event(event))
    }
  }

  private func sendOrQueueError(_ error: FlutterError) {
    if let eventSink = self.eventSink {
      eventSink.error(code: error.code, message: error.message, details: error.details)
    } else {
      self.queuedEvents?.append(.error(error))
    }
  }
}
