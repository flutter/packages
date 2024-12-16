// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class AuthenticationChallengeResponseProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiAuthenticationChallengeResponse(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, disposition: UrlSessionAuthChallengeDisposition.useCredential,
      credential: URLCredential())
    XCTAssertNotNil(instance)
  }

  func testDisposition() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiAuthenticationChallengeResponse(registrar)

    let instance = AuthenticationChallengeResponse(
      disposition: .useCredential, credential: URLCredential())
    let value = try? api.pigeonDelegate.disposition(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, UrlSessionAuthChallengeDisposition.useCredential)
  }

  func testCredential() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiAuthenticationChallengeResponse(registrar)

    let instance = AuthenticationChallengeResponse(
      disposition: .useCredential, credential: URLCredential())
    let value = try? api.pigeonDelegate.credential(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.credential)
  }
}
