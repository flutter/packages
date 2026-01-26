// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// Handles streaming of camera image data to Dart via Flutter event channels.
protocol ImageStreamHandler: FlutterStreamHandler {
  /// The queue on which `eventSink` property should be accessed.
  var captureSessionQueue: DispatchQueue { get }

  /// The event sink to stream camera events to Dart.
  ///
  /// The property should only be accessed on `captureSessionQueue`.
  /// The block itself should be invoked on the main queue.
  var eventSink: FlutterEventSink? { get set }
}

/// Default implementation of ImageStreamHandler.
class DefaultImageStreamHandler: NSObject, ImageStreamHandler {
  let captureSessionQueue: DispatchQueue
  var eventSink: FlutterEventSink?

  /// Initialize an image stream handler.
  /// captureSessionQueue - the queue on which the event sink should be accessed.
  init(captureSessionQueue: DispatchQueue) {
    self.captureSessionQueue = captureSessionQueue
    super.init()
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    captureSessionQueue.async { [weak self] in
      self?.eventSink = events
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    captureSessionQueue.async { [weak self] in
      self?.eventSink = nil
    }
    return nil
  }
}
