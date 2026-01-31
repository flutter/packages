// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

@testable import camera_avfoundation

/// A mock implementation of `EventChannel` that allows injecting a custom implementation
/// for setting a stream handler.
final class MockEventChannel: EventChannel {
  var setStreamHandlerStub: (((any FlutterStreamHandler & NSObjectProtocol)?) -> Void)?

  func setStreamHandler(_ handler: (any FlutterStreamHandler & NSObjectProtocol)?) {
    setStreamHandlerStub?(handler)
  }
}
