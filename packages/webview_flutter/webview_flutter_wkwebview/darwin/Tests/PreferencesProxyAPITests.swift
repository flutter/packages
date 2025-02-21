// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class PreferencesProxyAPITests: XCTestCase {
  @MainActor func testSetJavaScriptEnabled() throws {
    if #available(iOS 14.0, macOS 11.0, *) {
      throw XCTSkip("Required API is not available for this test.")

    } else {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiWKPreferences(registrar)

      let instance = WKPreferences()
      let enabled = true
      try? api.pigeonDelegate.setJavaScriptEnabled(
        pigeonApi: api, pigeonInstance: instance, enabled: enabled)

      XCTAssertEqual(instance.javaScriptEnabled, enabled)
    }
  }
}
