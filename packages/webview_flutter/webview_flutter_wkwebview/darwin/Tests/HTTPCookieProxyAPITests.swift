// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class HTTPCookieProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPCookie(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api,
      properties: [.name: "foo", .value: "bar", .domain: "http://google.com", .path: "/anything"])
    XCTAssertNotNil(instance)
  }

  func testGetProperties() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPCookie(registrar)

    let instance = HTTPCookie(properties: [
      .name: "foo", .value: "bar", .domain: "http://google.com", .path: "/anything",
    ])!
    let value = try? api.pigeonDelegate.getProperties(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value?[.name] as? String, "foo")
    XCTAssertEqual(value?[.value] as? String, "bar")
    XCTAssertEqual(value?[.domain] as? String, "http://google.com")
    XCTAssertEqual(value?[.path] as? String, "/anything")
  }
}
