// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class URLResponseProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLResponse(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, url: "test-scheme://host/resource", mimeType: "image/png",
      expectedContentLength: 3, textEncodingName: nil)

    XCTAssertEqual(instance?.url, URL(string: "test-scheme://host/resource"))
    XCTAssertEqual(instance?.mimeType, "image/png")
    XCTAssertEqual(instance?.expectedContentLength, 3)
    XCTAssertNil(instance?.textEncodingName)
  }

  func testPigeonDefaultConstructorWithInvalidUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLResponse(registrar)

    XCTAssertThrowsError(
      try api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api, url: "", mimeType: nil, expectedContentLength: 0,
        textEncodingName: nil))
  }
}
