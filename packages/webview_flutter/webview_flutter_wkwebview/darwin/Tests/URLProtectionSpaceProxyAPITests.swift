// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class ProtectionSpaceProxyAPITests: XCTestCase {
  func testHost() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLProtectionSpace(registrar)

    let instance = URLProtectionSpace(
      host: "host", port: 23, protocol: "protocol", realm: "realm", authenticationMethod: "myMethod"
    )
    let value = try? api.pigeonDelegate.host(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.host)
  }

  func testPort() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLProtectionSpace(registrar)

    let instance = URLProtectionSpace(
      host: "host", port: 23, protocol: "protocol", realm: "realm", authenticationMethod: "myMethod"
    )
    let value = try? api.pigeonDelegate.port(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.port))
  }

  func testRealm() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLProtectionSpace(registrar)

    let instance = URLProtectionSpace(
      host: "host", port: 23, protocol: "protocol", realm: "realm", authenticationMethod: "myMethod"
    )
    let value = try? api.pigeonDelegate.realm(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.realm)
  }

  func testAuthenticationMethod() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLProtectionSpace(registrar)

    let instance = URLProtectionSpace(
      host: "host", port: 23, protocol: "protocol", realm: "realm", authenticationMethod: "myMethod"
    )
    let value = try? api.pigeonDelegate.authenticationMethod(
      pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.authenticationMethod)
  }

}
