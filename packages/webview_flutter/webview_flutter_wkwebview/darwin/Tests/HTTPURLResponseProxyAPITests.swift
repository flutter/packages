// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class HTTPURLResponseProxyAPITests: XCTestCase {
  func testStatusCode() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPURLResponse(registrar)

    let instance = HTTPURLResponse(
      url: URL(string: "http://google.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
    let value = try? api.pigeonDelegate.statusCode(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.statusCode))
  }
}
