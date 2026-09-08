// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct GetTrustResultResponseProxyAPITests {
  @Test func result() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiGetTrustResultResponse(registrar)

    let instance = GetTrustResultResponse(result: SecTrustResultType.invalid, resultCode: -1)
    let value = try api.pigeonDelegate.result(pigeonApi: api, pigeonInstance: instance)

    #expect(value == DartSecTrustResultType.invalid)
  }

  @Test func resultCode() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiGetTrustResultResponse(registrar)

    let instance = GetTrustResultResponse(result: SecTrustResultType.invalid, resultCode: -1)
    let value = try api.pigeonDelegate.resultCode(pigeonApi: api, pigeonInstance: instance)

    #expect(value == -1)
  }
}
