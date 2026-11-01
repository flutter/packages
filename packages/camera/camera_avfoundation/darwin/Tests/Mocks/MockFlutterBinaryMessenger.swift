// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// Mocked implementation of `FlutterBinaryMessenger` that allows constructing a `CameraPlugin`
/// instance for testing and capturing messages sent through the messenger.
final class MockFlutterBinaryMessenger: NSObject, FlutterBinaryMessenger {
  var sendStub: ((String, Data?, FlutterBinaryReply?) -> Void)?

  func send(onChannel channel: String, message: Data?) {}

  func send(
    onChannel channel:
      String,
    message:
      Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {
    sendStub?(channel, message, callback)
  }

  func setMessageHandlerOnChannel(
    _ channel: String,
    binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection { 0 }

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}
