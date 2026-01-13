// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class GetTrustResultResponseProxyAPITests: XCTestCase {
  func testResult() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiGetTrustResultResponse(registrar)

    let instance = GetTrustResultResponse(result: SecTrustResultType.invalid, resultCode: -1)
    let value = try? api.pigeonDelegate.result(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, DartSecTrustResultType.invalid)
  }

  func testResultCode() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiGetTrustResultResponse(registrar)

    let instance = GetTrustResultResponse(result: SecTrustResultType.invalid, resultCode: -1)
    let value = try? api.pigeonDelegate.resultCode(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, -1)
  }
}
