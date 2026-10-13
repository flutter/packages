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

class EventBridge: NSObject, FlutterStreamHandler, VideoEventListener {

  /// The event channel to dispatch notifications to.
  // TODO(stuartmorgan): Convert this to Pigeon event channels.
  private let eventChannel: FlutterEventChannel

  /// The event sink associated with eventChannel.
  ///
  /// Will be nil both before the channel listener is ready on the Dart side, and after it has been
  /// closed on the Dart side.
  private var eventSink: FlutterEventSink?

  /// A queue of events received before eventSink is ready, to dispatch once the channel is fully
  /// set up.
  private var queuedEvents: [Any]? = []

  init(messenger: FlutterBinaryMessenger, channelName: String) {
    self.eventChannel = FlutterEventChannel(
      name: channelName,
      binaryMessenger: messenger
    )
    super.init()

    // This retain loop is broken in videoPlayerWasDisposed.
    self.eventChannel.setStreamHandler(self)
  }

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.eventSink = eventSink

    // Send any events that came in before the sink was ready.
    self.queuedEvents?.forEach(eventSink)
    self.queuedEvents?.removeAll()

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    // No need to queue events coming in after this point; nil the queue so they will be discarded.
    self.queuedEvents = nil
    return nil
  }

  // MARK: FVPVideoEventListener

  func videoPlayerDidInitialize(withDuration duration: Int64, size: CGSize) {
    sendOrQueue([
      "event": "initialized",
      "duration": NSNumber(value: duration),
      "width": NSNumber(value: size.width),
      "height": NSNumber(value: size.height),
    ])
  }

  func videoPlayerDidError(withMessage errorMessage: String) {
    sendOrQueue(FlutterError(code: "VideoError", message: errorMessage, details: nil))
  }

  func videoPlayerDidComplete() {
    sendOrQueue(["event": "completed"])
  }

  func videoPlayerDidStartBuffering() {
    sendOrQueue(["event": "bufferingStart"])
  }

  func videoPlayerDidEndBuffering() {
    sendOrQueue(["event": "bufferingEnd"])
  }

  func videoPlayerDidUpdateBufferRegions(_ regions: [[NSNumber]]) {
    sendOrQueue(["event": "bufferingUpdate", "values": regions])
  }

  func videoPlayerDidSetPlaying(_ playing: Bool) {
    sendOrQueue(["event": "isPlayingStateUpdate", "isPlaying": NSNumber(value: playing)])
  }

  func videoPlayerWasDisposed() {
    eventChannel.setStreamHandler(nil)
  }

  // MARK: Private methods

  /// Sends the given event to the event sink if it is ready to receive events, or enqueues it to send
  /// later if not.
  private func sendOrQueue(_ event: Any) {
    if let eventSink = self.eventSink {
      eventSink(event)
    } else {
      self.queuedEvents?.append(event)
    }
  }

}
