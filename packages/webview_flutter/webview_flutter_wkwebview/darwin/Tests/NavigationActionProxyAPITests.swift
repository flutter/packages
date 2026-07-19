// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct NavigationActionProxyAPITests {
  @MainActor @Test func request() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

    let instance: TestNavigationAction? = TestNavigationAction()
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance!)

    #expect(value?.value == instance!.request)
  }

  @MainActor @Test func targetFrame() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

    let instance: TestNavigationAction? = TestNavigationAction()
    let value = try? api.pigeonDelegate.targetFrame(pigeonApi: api, pigeonInstance: instance!)

    #expect(value == instance!.targetFrame)
  }

  @MainActor @Test func navigationType() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationAction(registrar)

    let instance: TestNavigationAction? = TestNavigationAction()
    let value = try? api.pigeonDelegate.navigationType(pigeonApi: api, pigeonInstance: instance!)

    #expect(value == .formSubmitted)
  }
}

class TestNavigationAction: WKNavigationAction {
  let internalTargetFrame = TestFrameInfo.instance

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
