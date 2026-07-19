// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct URLAuthenticationChallengeProxyAPITests {
  @Test func getProtectionSpace() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLAuthenticationChallenge(registrar)

    let instance = URLAuthenticationChallenge(
      protectionSpace: URLProtectionSpace(), proposedCredential: nil, previousFailureCount: 3,
      failureResponse: nil, error: nil, sender: TestURLAuthenticationChallengeSender())
    let value = try api.pigeonDelegate.getProtectionSpace(pigeonApi: api, pigeonInstance: instance)

    #expect(value.host == instance.protectionSpace.host)
    #expect(value.port == instance.protectionSpace.port)
    #expect(value.protocol == instance.protectionSpace.protocol)
    #expect(value.realm == instance.protectionSpace.realm)
    #expect(value.authenticationMethod == instance.protectionSpace.authenticationMethod)
  }
}
