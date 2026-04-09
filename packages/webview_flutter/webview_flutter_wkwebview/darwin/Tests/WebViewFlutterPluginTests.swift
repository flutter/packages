// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
  import UIKit
#endif

class WebViewFlutterPluginTests: XCTestCase {
  #if os(iOS)
    func testWillTerminateSetRegistrarToNil() {
      let plugin = WebViewFlutterPlugin(binaryMessenger: TestBinaryMessenger())

      // Ensure method is from `FlutterApplicationLifeCycleDelegate`.
      (plugin as FlutterApplicationLifeCycleDelegate).applicationWillTerminate!(UIApplication())
      XCTAssertNil(plugin.proxyApiRegistrar)
    }
  #endif
}
