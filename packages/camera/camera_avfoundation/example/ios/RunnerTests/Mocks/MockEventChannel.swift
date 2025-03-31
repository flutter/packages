// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A mock implementation of `FLTEventChannel` that allows injecting a custom implementation
/// for setting a stream handler.
final class MockEventChannel: NSObject, FLTEventChannel {
  var setStreamHandlerStub: ((FlutterStreamHandler?) -> Void)?

  func setStreamHandler(_ handler: (FlutterStreamHandler & NSObjectProtocol)?) {
    setStreamHandlerStub?(handler)
  }
}
