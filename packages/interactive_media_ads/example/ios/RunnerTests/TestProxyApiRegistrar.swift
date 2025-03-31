// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads

class TestProxyApiRegistrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar {
  private class TestBinaryMessenger: NSObject, FlutterBinaryMessenger {
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

  init() {
    let testBinaryMessenger = TestBinaryMessenger()
    super.init(binaryMessenger: testBinaryMessenger, apiDelegate: ProxyApiDelegate())
  }
}
