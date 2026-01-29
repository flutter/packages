// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// A thread safe wrapper for FlutterEventChannel that can be called from any thread, by dispatching
/// its underlying engine calls to the main thread.
class ThreadSafeEventChannel {
  private let channel: EventChannel

  /// Creates a ThreadSafeEventChannel by wrapping a FlutterEventChannel object.
  /// channel - The FlutterEventChannel object to be wrapped.
  init(eventChannel channel: EventChannel) {
    self.channel = channel
  }

  /// Registers a handler on the main thread for stream setup requests from the Flutter side.
  /// The completion block runs on the main thread.
  /// handler - The stream handler to register (nil to unregister).
  /// completion - The completion block that runs on the main thread.
  func setStreamHandler(
    _ handler: (any FlutterStreamHandler & NSObjectProtocol)?, completion: @escaping () -> Void
  ) {
    // WARNING: Should not use weak self, because ThreadSafeEventChannel is a local variable
    // (retained within call stack, but not in the heap). ensureToRunOnMainQueue may trigger a
    // context switch (when calling from background thread), in which case using weak self will always
    // result in a nil self. Alternative to using strong self, we can also create a local strong
    // variable to be captured by this block.
    ensureToRunOnMainQueue {
      self.channel.setStreamHandler(handler)
      completion()
    }
  }
}
