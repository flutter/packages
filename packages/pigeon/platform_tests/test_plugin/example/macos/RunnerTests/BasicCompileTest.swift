// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import test_plugin

class MyApi: HostTrivialApi {
  func noop() {}
}

// Since the generator is almost entirely shared with iOS, this is currently
// just testing that the generated code compiles for macOS (e.g., that the
// Flutter framework import is correct).
class BasicCompileTest: XCTestCase {
  func testMakeApi() {
    let api = MyApi()
    XCTAssertNotNil(api)
  }
}
