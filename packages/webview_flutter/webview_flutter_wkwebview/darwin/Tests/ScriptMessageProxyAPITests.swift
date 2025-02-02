// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class ScriptMessageProxyAPITests: XCTestCase {
  @MainActor func testName() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKScriptMessage(registrar)

    let instance = TestScriptMessage()
    let value = try? api.pigeonDelegate.name(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.name)
  }

  @MainActor func testBody() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKScriptMessage(registrar)

    let instance = TestScriptMessage()
    let value = try? api.pigeonDelegate.body(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value as! Int, 23)
  }
}

class TestScriptMessage: WKScriptMessage {
  override var name: String {
    return "myString"
  }

  override var body: Any {
    return NSNumber(integerLiteral: 23)
  }
}
