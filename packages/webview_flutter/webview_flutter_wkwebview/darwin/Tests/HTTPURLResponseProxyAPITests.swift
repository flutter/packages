// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class HTTPURLResponseProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPURLResponse(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, statusCode: 404, url: "http://google.com", httpVersion: nil,
      headerFields: ["Content-Type": "image/png"])

    XCTAssertEqual(instance?.url, URL(string: "http://google.com"))
    XCTAssertEqual(instance?.statusCode, 404)
    XCTAssertEqual(instance?.value(forHTTPHeaderField: "Content-Type"), "image/png")
  }

  func testPigeonDefaultConstructorWithInvalidUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPURLResponse(registrar)

    XCTAssertThrowsError(
      try api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api, statusCode: 200, url: "", httpVersion: nil, headerFields: nil))
  }

  func testStatusCode() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPURLResponse(registrar)

    let instance = HTTPURLResponse(
      url: URL(string: "http://google.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
    let value = try? api.pigeonDelegate.statusCode(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, Int64(instance.statusCode))
  }
}
