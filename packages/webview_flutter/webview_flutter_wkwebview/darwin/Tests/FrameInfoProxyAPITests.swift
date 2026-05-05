// Copyright 2013 The Flutter Authors
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

    let instance = TestFrameInfo.instance
    let value = try? api.pigeonDelegate.isMainFrame(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.isMainFrame)
  }

  @MainActor func testRequest() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance = TestFrameInfo.instance
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value?.value, instance.request)
  }

  @MainActor func testNilRequest() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance = TestFrameInfoWithNilRequest.instance
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance)
    // On macOS 15.5+, `WKFrameInfo.request` returns with an empty URLRequest.
    // Previously it would return nil so accept either.
    if value != nil {
      XCTAssertEqual(value?.value.url?.absoluteString, "")
    } else {
      XCTAssertNil(value)
    }
  }
}

class TestFrameInfo: WKFrameInfo {
  // Global test instance of `WKFrameInfo`. Using a static instance prevents a crash when
  // a `WKFrameInfo` is deallocated during a test on iOS 26+.
  static let instance = TestFrameInfo()

  private override init() {

  }

  override var isMainFrame: Bool {
    return true
  }

  override var request: URLRequest {
    return URLRequest(url: URL(string: "https://google.com")!)
  }
}

class TestFrameInfoWithNilRequest: WKFrameInfo {
  // Global test instance of `WKFrameInfo` with a nil URLRequest. Using a static instance prevents a
  // crash when a `WKFrameInfo` is deallocated during a test on iOS 26+.
  static let instance = TestFrameInfoWithNilRequest()

  private override init() {

  }
}
