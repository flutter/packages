// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import webview_flutter_wkwebview

class TestProxyApiRegistrar: WebKitLibraryPigeonProxyApiRegistrar {
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
    super.init(binaryMessenger: TestBinaryMessenger(), apiDelegate: ProxyAPIDelegate())
  }
}
