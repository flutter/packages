// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class URLCredentialProxyAPITests: XCTestCase {
  func testWithUser() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLCredential(registrar)

    let instance = try? api.pigeonDelegate.withUser(
      pigeonApi: api, user: "myString", password: "myString", persistence: .none)
    XCTAssertNotNil(instance)
  }
}
