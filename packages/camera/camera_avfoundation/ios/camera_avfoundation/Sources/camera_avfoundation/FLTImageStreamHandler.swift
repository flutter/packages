// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class FLTImageStreamHandler: NSObject, FlutterStreamHandler {

  /// The queue on which `eventSink` property should be accessed.
  let captureSessionQueue: DispatchQueue

  /// The event sink to stream camera events to Dart.
  ///
  /// The property should only be accessed on `captureSessionQueue`.
  /// The block itself should be invoked on the main queue.
  private(set) var eventSink: FlutterEventSink?

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
