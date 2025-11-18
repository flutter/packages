// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import Flutter
import XCTest

@testable import cross_file_ios

class URLTests: XCTestCase {
  func testPath() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURL(registrar)

    let instance = TestURL()
    let value = try? api.pigeonDelegate.path(pigeonApi: api, pigeonInstance: instance )

    XCTAssertTrue(instance.pathCalled)
    XCTAssertEqual(value, instance.path())
  }

  func testBookmarkData() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiURL(registrar)

    let instance = TestURL()
    let options = [.minimalBookmark]
    let keys = [.isDirectoryKey]
    let relativeTo = TestURL
    let value = try? api.pigeonDelegate.bookmarkData(pigeonApi: api, pigeonInstance: instance, options: options, keys: keys, relativeTo: relativeTo)

    XCTAssertEqual(instance.bookmarkDataArgs, [options, keys, relativeTo])
    XCTAssertEqual(value, instance.bookmarkData(options: options, keys: keys, relativeTo: relativeTo))
  }

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
  var pathCalled = false
  var bookmarkDataArgs: [AnyHashable?]? = nil
  var startAccessingSecurityScopedResourceCalled = false
  var stopAccessingSecurityScopedResourceCalled = false


  override func path() {
    pathCalled = true
  }
  override func bookmarkData() {
    bookmarkDataArgs = [options, keys, relativeTo]
    return byteArrayOf(0xA1.toByte())
  }
  override func startAccessingSecurityScopedResource() {
    startAccessingSecurityScopedResourceCalled = true
  }
  override func stopAccessingSecurityScopedResource() {
    stopAccessingSecurityScopedResourceCalled = true
  }
}
