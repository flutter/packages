// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import test_plugin

/// Tests NSNull is correctly handled by `nilOrValue` helper, by manually setting nullable fields to NSNull.
final class NSNullFieldTests: XCTestCase {

  func testNSNull_nullListToCustomStructField() throws {
    let reply = NullFieldsSearchReply(
      result: nil,
      error: nil,
      indices: nil,
      request: nil,
      type: nil)
    var list = reply.toList()
    // request field
    list[3] = NSNull()
    let copy = NullFieldsSearchReply.fromList(list)
    XCTAssertNotNil(copy)
    XCTAssertNil(copy!.request)
  }

  func testNSNull_nullListField() {
    let reply = NullFieldsSearchReply(
      result: nil,
      error: nil,
      indices: nil,
      request: nil,
      type: nil)
    var list = reply.toList()
    // indices field
    list[2] = NSNull()
    let copy = NullFieldsSearchReply.fromList(list)
    XCTAssertNotNil(copy)
    XCTAssertNil(copy!.indices)
  }

  func testNSNull_nullBasicFields() throws {
    let reply = NullFieldsSearchReply(
      result: nil,
      error: nil,
      indices: nil,
      request: nil,
      type: nil)
    var list = reply.toList()
    // result field
    list[0] = NSNull()
    // error field
    list[1] = NSNull()
    // type field
    list[4] = NSNull()
    let copy = NullFieldsSearchReply.fromList(list)
    XCTAssertNotNil(copy)
    XCTAssertNil(copy!.result)
    XCTAssertNil(copy!.error)
    XCTAssertNil(copy!.type)
  }
}
