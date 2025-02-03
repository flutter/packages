// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class NavigationActionProxyAPITests: XCTestCase {
  @MainActor func testRequest() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

    let instance: TestNavigationAction? = TestNavigationAction()
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance!)

    XCTAssertEqual(value?.value, instance!.request)
  }

  @MainActor func testTargetFrame() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

    let instance: TestNavigationAction? = TestNavigationAction()
    let value = try? api.pigeonDelegate.targetFrame(pigeonApi: api, pigeonInstance: instance!)

    XCTAssertEqual(value, instance!.targetFrame)
  }

  @MainActor func testNavigationType() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

    let instance: TestNavigationAction? = TestNavigationAction()
    let value = try? api.pigeonDelegate.navigationType(pigeonApi: api, pigeonInstance: instance!)

    XCTAssertEqual(value, .formSubmitted)
  }
}

class TestNavigationAction: WKNavigationAction {
  let internalTargetFrame = TestFrameInfo()

  override var request: URLRequest {
    return URLRequest(url: URL(string: "http://google.com")!)
  }

  override var targetFrame: WKFrameInfo? {
    return internalTargetFrame
  }

  override var navigationType: WKNavigationType {
    return .formSubmitted
  }
}
