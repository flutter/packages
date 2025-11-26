// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import cross_file_ios

class URLResolvingBookmarkDataResponseTests: XCTestCase {
  func testUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLResolvingBookmarkDataResponse(registrar)

    let instance = TestURLResolvingBookmarkDataResponse()
    let value = try? api.pigeonDelegate.url(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.url)
  }

  func testIsStale() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURLResolvingBookmarkDataResponse(registrar)

    let instance = TestURLResolvingBookmarkDataResponse()
    let value = try? api.pigeonDelegate.isStale(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.isStale)
  }

}
