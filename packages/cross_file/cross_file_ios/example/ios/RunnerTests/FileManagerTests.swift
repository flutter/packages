// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Flutter
import XCTest

@testable import cross_file_ios

class FileManagerTests: XCTestCase {
  func testFileExistsAtPath() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileManager(registrar)

    let instance = TestFileManager()
    let path = "myString"
    let value = try? api.pigeonDelegate.fileExistsAtPath(pigeonApi: api, pigeonInstance: instance, path: path)

    XCTAssertEqual(instance.fileExistsAtPathArgs, [path])
    XCTAssertEqual(value, instance.fileExistsAtPath(path: path))
  }

  func testIsReadableFileAtPath() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileManager(registrar)

    let instance = TestFileManager()
    let path = "myString"
    let value = try? api.pigeonDelegate.isReadableFileAtPath(pigeonApi: api, pigeonInstance: instance, path: path)

    XCTAssertEqual(instance.isReadableFileAtPathArgs, [path])
    XCTAssertEqual(value, instance.isReadableFileAtPath(path: path))
  }

  func testContentsAtPath() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileManager(registrar)

    let instance = TestFileManager()
    let path = "myString"
    let value = try? api.pigeonDelegate.contentsAtPath(pigeonApi: api, pigeonInstance: instance, path: path)

    XCTAssertEqual(instance.contentsAtPathArgs, [path])
    XCTAssertEqual(value, instance.contentsAtPath(path: path))
  }

}
class TestFileManager: FileManager {
  var fileExistsAtPathArgs: [AnyHashable?]? = nil
  var isReadableFileAtPathArgs: [AnyHashable?]? = nil
  var contentsAtPathArgs: [AnyHashable?]? = nil


  override func fileExistsAtPath() {
    fileExistsAtPathArgs = [path]
    return true
  }
  override func isReadableFileAtPath() {
    isReadableFileAtPathArgs = [path]
    return true
  }
  override func contentsAtPath() {
    contentsAtPathArgs = [path]
    return byteArrayOf(0xA1.toByte())
  }
}
