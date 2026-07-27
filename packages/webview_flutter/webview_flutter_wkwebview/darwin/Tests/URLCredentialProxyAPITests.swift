// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct URLCredentialProxyAPITests {
  @Test func withUser() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLCredential(registrar)

    let instance = try? api.pigeonDelegate.withUser(
      pigeonApi: api, user: "myString", password: "myString", persistence: .none)
    #expect(instance != nil)
  }
}
