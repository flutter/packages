// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class NavigationResponseProxyAPITests: XCTestCase {
  @MainActor func testResponse() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationResponse(registrar)

    let instance = WKNavigationResponse()
    let value = try? api.pigeonDelegate.response(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.response)
  }

  @MainActor func testIsForMainFrame() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationResponse(registrar)

    let instance = TestNavigationResponse()
    let value = try? api.pigeonDelegate.isForMainFrame(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.isForMainFrame)
  }
}

class TestNavigationResponse: WKNavigationResponse {
  let testResponse = URLResponse()

  override var isForMainFrame: Bool {
    return true
  }

  override var response: URLResponse {
    return testResponse
  }
}
