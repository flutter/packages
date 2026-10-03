// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct AuthenticationChallengeResponseProxyAPITests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiAuthenticationChallengeResponse(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, disposition: UrlSessionAuthChallengeDisposition.useCredential,
      credential: URLCredential())
    #expect(instance != nil)
  }

  @Test func disposition() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiAuthenticationChallengeResponse(registrar)

    let instance = AuthenticationChallengeResponse(
      disposition: .useCredential, credential: URLCredential())
    let value = try api.pigeonDelegate.disposition(pigeonApi: api, pigeonInstance: instance)

    #expect(value == UrlSessionAuthChallengeDisposition.useCredential)
  }

  @Test func credential() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiAuthenticationChallengeResponse(registrar)

    let instance = AuthenticationChallengeResponse(
      disposition: .useCredential, credential: URLCredential())
    let value = try api.pigeonDelegate.credential(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.credential)
  }
}
