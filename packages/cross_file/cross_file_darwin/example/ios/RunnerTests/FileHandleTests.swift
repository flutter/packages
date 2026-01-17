// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import cross_file_darwin

class FileHandleTests: XCTestCase {
  func testForReadingFromUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)

    let instance = try? api.pigeonDelegate.forReadingFromUrl(pigeonApi: api, url: "myString")
    XCTAssertNotNil(instance)
  }

  func testReadUpToCount() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)

    let instance = TestFileHandle()
    let count = 0
    let value = try? api.pigeonDelegate.readUpToCount(
      pigeonApi: api, pigeonInstance: instance, count: count)

    XCTAssertEqual(instance.readUpToCountArgs, [count])
    XCTAssertEqual(value, instance.readUpToCount(count: count))
  }

  func testReadToEnd() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)

    let instance = TestFileHandle()
    let value = try? api.pigeonDelegate.readToEnd(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.readToEndCalled)
    XCTAssertEqual(value, instance.readToEnd())
  }

  func testSeek() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)

    let instance = TestFileHandle()
    let offset = 0
    let value = try? api.pigeonDelegate.seek(
      pigeonApi: api, pigeonInstance: instance, offset: offset)

    XCTAssertEqual(instance.seekArgs, [offset])
    XCTAssertEqual(value, instance.seek(offset: offset))
  }

  func testClose() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)

    let instance = TestFileHandle()
    try? api.pigeonDelegate.close(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.closeCalled)
  }

}
class TestFileHandle: FileHandle {
  var readUpToCountArgs: [AnyHashable?]? = nil
  var readToEndCalled = false
  var seekArgs: [AnyHashable?]? = nil
  var closeCalled = false

  override func readUpToCount() {
    readUpToCountArgs = [count]
    return byteArrayOf(0xA1.toByte())
  }
  override func readToEnd() {
    readToEndCalled = true
  }
  override func seek() {
    seekArgs = [offset]
    return 0
  }
  override func close() {
    closeCalled = true
  }
}
