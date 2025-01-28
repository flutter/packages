// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class URLAuthenticationChallengeProxyAPITests: XCTestCase {
  func testGetProtectionSpace() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLAuthenticationChallenge(registrar)

    let instance = URLAuthenticationChallenge(
      protectionSpace: URLProtectionSpace(), proposedCredential: nil, previousFailureCount: 3,
      failureResponse: nil, error: nil, sender: TestURLAuthenticationChallengeSender())
    let value = try? api.pigeonDelegate.getProtectionSpace(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.protectionSpace)
  }
}
