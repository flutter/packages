// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import macos_swift_unit_tests

class MessagesTest: XCTestCase {
   func testMakeApi() {
    let api = MyApi()
    XCTAssertNotNil(api)
   }
}
