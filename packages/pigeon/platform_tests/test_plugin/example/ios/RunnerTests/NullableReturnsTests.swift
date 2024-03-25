// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import test_plugin

class MockNullableArgHostApi: NullableArgHostApi {
  var didCall: Bool = false
  var x: Int64?

  func doit(x: Int64?) -> Int64 {
    didCall = true
    self.x = x
    return x ?? 0
  }
}

class NullableReturnsTests: XCTestCase {
  var codec = FlutterStandardMessageCodec.sharedInstance()
  func testNullableParameterWithFlutterApi() {
    let binaryMessenger = EchoBinaryMessenger(codec: codec)
    binaryMessenger.defaultReturn = 99
    let api = NullableArgFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    api.doit(x: nil) { result in
      switch result {
      case .success(let res):
        XCTAssertEqual(99, res)
        expectation.fulfill()
      case .failure(_):
        return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testNullableParameterWithHostApi() {
    let api = MockNullableArgHostApi()
    let binaryMessenger = MockBinaryMessenger<Int64?>(codec: codec)
    let channel = "dev.flutter.pigeon.pigeon_integration_tests.NullableArgHostApi.doit"

    NullableArgHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: api)
    XCTAssertNotNil(binaryMessenger.handlers[channel])

    let inputEncoded = binaryMessenger.codec.encode([nil] as [Any?])

    let expectation = XCTestExpectation(description: "callback")
    binaryMessenger.handlers[channel]?(inputEncoded) { _ in
      expectation.fulfill()
    }

    XCTAssertTrue(api.didCall)
    XCTAssertNil(api.x)
    wait(for: [expectation], timeout: 1.0)

  }
}
