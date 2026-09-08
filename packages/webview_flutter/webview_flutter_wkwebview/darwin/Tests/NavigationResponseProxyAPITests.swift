// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct NavigationResponseProxyAPITests {
  @MainActor @Test func response() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationResponse(registrar)

    let instance = TestNavigationResponse.instance
    let value = try? api.pigeonDelegate.response(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.response)
  }

  @MainActor @Test func isForMainFrame() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationResponse(registrar)

    let instance = TestNavigationResponse.instance
    let value = try api.pigeonDelegate.isForMainFrame(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.isForMainFrame)
  }
}

class TestNavigationResponse: WKNavigationResponse {
  // Provides a static instance to prevent a crash when a WKNavigationResponse is deallocated
  // See https://github.com/flutter/flutter/issues/173326
  static let instance = TestNavigationResponse()

  let testResponse = URLResponse()

  private override init() {
    super.init()
  }

  override var isForMainFrame: Bool {
    return true
  }

  override var response: URLResponse {
    return testResponse
  }
}
