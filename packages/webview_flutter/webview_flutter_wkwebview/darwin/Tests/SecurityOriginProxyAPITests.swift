// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

@MainActor
class SecurityOriginProxyAPITests: XCTestCase {
  static let testSecurityOrigin = TestSecurityOrigin.customInit()

  @MainActor func testHost() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKSecurityOrigin(registrar)

    let instance = SecurityOriginProxyAPITests.testSecurityOrigin
    let value = try? api.pigeonDelegate.host(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.host)
  }

  @MainActor func testPort() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKSecurityOrigin(registrar)

    let instance = SecurityOriginProxyAPITests.testSecurityOrigin
    let value = try? api.pigeonDelegate.port(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.port))
  }

  @MainActor func testSecurityProtocol() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKSecurityOrigin(registrar)

    let instance = SecurityOriginProxyAPITests.testSecurityOrigin
    let value = try? api.pigeonDelegate.securityProtocol(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.`protocol`)
  }
}

class TestSecurityOrigin: WKSecurityOrigin {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestSecurityOrigin {
    let instance =
      TestSecurityOrigin.perform(NSSelectorFromString("new")).takeRetainedValue()
      as! TestSecurityOrigin
    return instance
  }

  override var host: String {
    return "host"
  }

  override var port: Int {
    return 23
  }

  override var `protocol`: String {
    return "protocol"
  }
}
