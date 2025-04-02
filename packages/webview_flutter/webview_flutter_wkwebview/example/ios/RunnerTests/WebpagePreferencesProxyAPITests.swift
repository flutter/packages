// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class WebpagePreferencesProxyAPITests: XCTestCase {
  @available(iOS 14.0, macOS 11.0, *)
  @MainActor func testSetAllowsContentJavaScript() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKWebpagePreferences(registrar)

    let instance = WKWebpagePreferences()
    let allow = true
    try? api.pigeonDelegate.setAllowsContentJavaScript(
      pigeonApi: api, pigeonInstance: instance, allow: allow)

    XCTAssertEqual(instance.allowsContentJavaScript, allow)
  }
}
