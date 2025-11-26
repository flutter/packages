// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import cross_file_ios

class FileHandleTests: XCTestCase {
  func testFromReadingFromUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)

    let instance = try? api.pigeonDelegate.fromReadingFromUrl(pigeonApi: api, url: TestURL)
    XCTAssertNotNil(instance)
  }

  func testReadToEnd() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)

    let instance = TestFileHandle()
    let value = try? api.pigeonDelegate.readToEnd(pigeonApi: api, pigeonInstance: instance)

    XCTAssertTrue(instance.readToEndCalled)
    XCTAssertEqual(value, instance.readToEnd())
  }

}
class TestFileHandle: FileHandle {
  var readToEndCalled = false

  override func readToEnd() {
    readToEndCalled = true
  }
}
