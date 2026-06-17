// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

@testable import cross_file_darwin

class TestProxyApiRegistrar: ProxyAPIRegistrar {
  init() {
    super.init(
        binaryMessenger: TestBinaryMessenger())
  }

  override func dispatchOnMainThread(
      execute work: @escaping (@escaping (String, PigeonError) -> Void) -> Void
  ) {
    work { _, _ in }
  }
}

class TestBundle: Bundle, @unchecked Sendable {
  override func url(forResource name: String?, withExtension ext: String?) -> URL? {
    return URL(string: "assets/www/index.html")!
  }
}

class TestBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {

  }

  func send(
    onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {

  }

  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    return 0
  }

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {

  }
}
