// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import test_plugin

class NonNullFieldsTests: XCTestCase {
  func testMake() {
    let request = NonNullFieldSearchRequest(query: "hello")
    XCTAssertEqual("hello", request.query)
  }
}
