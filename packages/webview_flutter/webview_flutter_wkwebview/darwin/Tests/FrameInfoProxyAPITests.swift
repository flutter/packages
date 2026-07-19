// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@MainActor
@Suite struct FrameInfoProxyAPITests {
  @MainActor @Test func isMainFrame() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance = TestFrameInfo.instance
    let value = try? api.pigeonDelegate.isMainFrame(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.isMainFrame)
  }

  @MainActor @Test func request() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance = TestFrameInfo.instance
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance)

    #expect(value?.value == instance.request)
  }

  @MainActor @Test func nilRequest() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKFrameInfo(registrar)

    let instance = TestFrameInfoWithNilRequest.instance
    let value = try? api.pigeonDelegate.request(pigeonApi: api, pigeonInstance: instance)
    // On macOS 15.5+, `WKFrameInfo.request` returns with an empty URLRequest.
    // Previously it would return nil so accept either.
    if value != nil {
      #expect(value?.value.url?.absoluteString == "")
    } else {
      #expect(value == nil)
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
