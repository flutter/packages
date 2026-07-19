// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@MainActor
@Suite struct SecurityOriginProxyAPITests {
  static let testSecurityOrigin = TestSecurityOrigin.customInit()

  @MainActor @Test func host() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKSecurityOrigin(registrar)

    let instance = SecurityOriginProxyAPITests.testSecurityOrigin
    let value = try? api.pigeonDelegate.host(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.host)
  }

  @MainActor @Test func port() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKSecurityOrigin(registrar)

    let instance = SecurityOriginProxyAPITests.testSecurityOrigin
    let value = try? api.pigeonDelegate.port(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.port))
  }

  @MainActor @Test func securityProtocol() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKSecurityOrigin(registrar)

    let instance = SecurityOriginProxyAPITests.testSecurityOrigin
    let value = try? api.pigeonDelegate.securityProtocol(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.`protocol`)
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
