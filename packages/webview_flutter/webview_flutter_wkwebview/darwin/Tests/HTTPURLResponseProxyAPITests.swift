// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct HTTPURLResponseProxyAPITests {
  @Test func statusCode() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiHTTPURLResponse(registrar)

    let instance = HTTPURLResponse(
      url: URL(string: "http://google.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
    let value = try api.pigeonDelegate.statusCode(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.statusCode))
  }
}
