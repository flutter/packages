// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

/// Mocked implementation of `FlutterBinaryMessenger` protocol that exists to allow constructing
/// a `CameraPlugin` instance for testing. It contains an empty implementation for all protocol
/// methods.
final class MockFlutterBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}

  func send(
    onChannel channel:
      String,
    message:
      Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {}

  func setMessageHandlerOnChannel(
    _ channel: String,
    binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection { 0 }

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}
