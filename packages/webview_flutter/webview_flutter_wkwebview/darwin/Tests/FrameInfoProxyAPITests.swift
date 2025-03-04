// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

@MainActor
class FrameInfoProxyAPITests: XCTestCase {
  @MainActor func testIsMainFrame() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance: TestFrameInfo? = TestFrameInfo()
    let value = try? api.pigeonDelegate.isMainFrame(pigeonApi: api, pigeonInstance: instance!)

    XCTAssertEqual(value, instance!.isMainFrame)
  }

  @MainActor func testRequest() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance: TestFrameInfo? = TestFrameInfo()
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance!)

    XCTAssertEqual(value?.value, instance!.request)
  }

  @MainActor func testNilRequest() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance = TestFrameInfoWithNilRequest()
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance)

    XCTAssertNil(value)
  }
}

class TestFrameInfo: WKFrameInfo {
  override var isMainFrame: Bool {
    return true
  }

  override var request: URLRequest {
    return URLRequest(url: URL(string: "https://google.com")!)
  }
}

class TestFrameInfoWithNilRequest: WKFrameInfo {
}
