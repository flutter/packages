// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class ErrorProxyAPITests: XCTestCase {
  func testCode() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSError(registrar)

    let code = 0
    let instance = NSError(domain: "", code: code)
    let value = try? api.pigeonDelegate.code(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(code))
  }

  func testDomain() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSError(registrar)

    let domain = "domain"
    let instance = NSError(domain: domain, code: 0)
    let value = try? api.pigeonDelegate.domain(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, domain)
  }

  func testUserInfo() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSError(registrar)

    let userInfo: [String: String?] = ["some": "info"]
    let instance = NSError(domain: "", code: 0, userInfo: userInfo as [String: Any])
    let value = try? api.pigeonDelegate.userInfo(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value as! [String: String?], userInfo)
  }
}
