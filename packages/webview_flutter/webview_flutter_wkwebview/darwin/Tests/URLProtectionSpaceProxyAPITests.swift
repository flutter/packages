// Copyright 2013 The Flutter Authors
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

  func testGetServerTrust() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLProtectionSpace(registrar)

    let instance = TestProtectionSpace(
      host: "host", port: 23, protocol: "protocol", realm: "realm", authenticationMethod: "myMethod"
    )
    let value = try? api.pigeonDelegate.getServerTrust(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value!.value, instance.serverTrust)
  }
}

class TestProtectionSpace: URLProtectionSpace, @unchecked Sendable {
  var serverTrustVal: SecTrust?

  override var serverTrust: SecTrust? {
    if serverTrustVal == nil {
      let url = FlutterAssetManager().urlForAsset("assets/test_cert.der")!

      let certificateData = NSData(contentsOf: url)
      let dummyCertificate: SecCertificate! = SecCertificateCreateWithData(nil, certificateData!)

      var trust: SecTrust?
      SecTrustCreateWithCertificates(
        [dummyCertificate] as AnyObject, SecPolicyCreateBasicX509(), &trust)
      serverTrustVal = trust!
    }
    return serverTrustVal
  }
}
