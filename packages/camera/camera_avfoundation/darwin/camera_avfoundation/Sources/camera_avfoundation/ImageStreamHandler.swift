// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// Handles streaming of camera image data to Dart via Flutter event channels.
protocol ImageStreamHandler: ImageDataStreamStreamHandler {
  /// The queue on which `eventSink` property should be accessed.
  var captureSessionQueue: DispatchQueue { get }

  /// The event sink to stream camera events to Dart.
  ///
  /// The property should only be accessed on `captureSessionQueue`.
  /// The block itself should be invoked on the main queue.
  var eventSink: PigeonEventSink<PlatformCameraImageData>? { get set }
}

/// Default implementation of ImageStreamHandler.
class DefaultImageStreamHandler: ImageDataStreamStreamHandler, ImageStreamHandler {
  let captureSessionQueue: DispatchQueue
  var eventSink: PigeonEventSink<PlatformCameraImageData>?

  /// Initialize an image stream handler.
  /// captureSessionQueue - the queue on which the event sink should be accessed.
  init(captureSessionQueue: DispatchQueue) {
    self.captureSessionQueue = captureSessionQueue
    super.init()
  }

  override func onListen(
    withArguments arguments: Any?, sink: PigeonEventSink<PlatformCameraImageData>
  ) {
    captureSessionQueue.async { [weak self] in
      self?.eventSink = sink
    }
  }

  override func onCancel(withArguments arguments: Any?) {
    captureSessionQueue.async { [weak self] in
      self?.eventSink = nil
    }
  }
}
