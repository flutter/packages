// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import Flutter
import XCTest

@testable import cross_file_ios

class URLTests: XCTestCase {
  func testStartAccessingSecurityScopedResource() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURL(registrar)

    let instance = TestURL()
    let value = try? api.pigeonDelegate.startAccessingSecurityScopedResource(pigeonApi: api, pigeonInstance: instance )

    XCTAssertTrue(instance.startAccessingSecurityScopedResourceCalled)
    XCTAssertEqual(value, instance.startAccessingSecurityScopedResource())
  }

  func testStopAccessingSecurityScopedResource() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURL(registrar)

    let instance = TestURL()
    try? api.pigeonDelegate.stopAccessingSecurityScopedResource(pigeonApi: api, pigeonInstance: instance )

    XCTAssertTrue(instance.stopAccessingSecurityScopedResourceCalled)
  }

}
class TestURL: URL {
  var startAccessingSecurityScopedResourceCalled = false
  var stopAccessingSecurityScopedResourceCalled = false


  override func startAccessingSecurityScopedResource() {
    startAccessingSecurityScopedResourceCalled = true
  }
  override func stopAccessingSecurityScopedResource() {
    stopAccessingSecurityScopedResourceCalled = true
  }
}
