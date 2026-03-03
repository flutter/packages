// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import WebKit

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

class PlatformViewImplTests: XCTestCase {
  #if os(iOS)
    func testPlatformViewImplStoresViewWithAWeakReference() {
      var view: WKWebView? = WKWebView()
      let platformView = PlatformViewImpl(uiView: view!)

      XCTAssertTrue(platformView.view() is WKWebView)

      view = nil
      XCTAssertFalse(platformView.view() is WKWebView)
    }
  #endif
}
