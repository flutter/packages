// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct HTTPCookieProxyAPITests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPCookie(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api,
      properties: [.name: "foo", .value: "bar", .domain: "http://google.com", .path: "/anything"])
    #expect(instance != nil)
  }

  @Test func getProperties() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPCookie(registrar)

    let instance = HTTPCookie(properties: [
      .name: "foo", .value: "bar", .domain: "http://google.com", .path: "/anything",
    ])!
    let value = try? api.pigeonDelegate.getProperties(pigeonApi: api, pigeonInstance: instance)

    #expect(value?[.name] as? String == "foo")
    #expect(value?[.value] as? String == "bar")
    #expect(value?[.domain] as? String == "http://google.com")
    #expect(value?[.path] as? String == "/anything")
  }
}
