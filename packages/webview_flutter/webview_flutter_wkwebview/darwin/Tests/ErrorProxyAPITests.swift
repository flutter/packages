// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct ErrorProxyAPITests {
  @Test func code() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSError(registrar)

    let code = 0
    let instance = NSError(domain: "", code: code)
    let value = try api.pigeonDelegate.code(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(code))
  }

  @Test func domain() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSError(registrar)

    let domain = "domain"
    let instance = NSError(domain: domain, code: 0)
    let value = try api.pigeonDelegate.domain(pigeonApi: api, pigeonInstance: instance)

    #expect(value == domain)
  }

  @Test func userInfo() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSError(registrar)

    let userInfo: [String: String?] = ["some": "info"]
    let instance = NSError(domain: "", code: 0, userInfo: userInfo as [String: Any])
    let value = try api.pigeonDelegate.userInfo(pigeonApi: api, pigeonInstance: instance)

    #expect(value as! [String: String?] == userInfo)
  }
}
