// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class UserScriptProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, source: "myString", injectionTime: .atDocumentStart, isForMainFrameOnly: true)
    XCTAssertNotNil(instance)
  }

  @MainActor func testSource() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = WKUserScript(
      source: "source", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    let value = try? api.pigeonDelegate.source(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.source)
  }

  @MainActor func testInjectionTime() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = WKUserScript(
      source: "source", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    let value = try? api.pigeonDelegate.injectionTime(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, .atDocumentEnd)
  }

  @MainActor func testIsMainFrameOnly() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUserScript(registrar)

    let instance = WKUserScript(
      source: "source", injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    let value = try? api.pigeonDelegate.isForMainFrameOnly(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.isForMainFrameOnly)
  }
}
