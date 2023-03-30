// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import test_plugin

class RunnerTests: XCTestCase {
  
  func testToListAndBack() throws {
    let reply = MessageSearchReply(result: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    XCTAssertEqual(reply.result, copy?.result)
  }

  func testHandlesNull() throws {
    let reply = MessageSearchReply()
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    XCTAssertNil(copy?.result)
  }

  func testHandlesNullFirst() throws {
    let reply = MessageSearchReply(error: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    XCTAssertEqual(reply.error, copy?.error)
  }
}
