// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest
@testable import test_plugin

class MockMultipleArityHostApi: MultipleArityHostApi {
  func subtract(x: Int64, y: Int64) -> Int64 {
    return x - y
  }
}

class MultipleArityTests: XCTestCase {
  var codec = FlutterStandardMessageCodec.sharedInstance()
  func testSimpleHost() throws {
    let binaryMessenger = MockBinaryMessenger<Int64>(codec: EnumApi2HostCodec.shared)
    MultipleArityHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: MockMultipleArityHostApi())
    let channelName = "dev.flutter.pigeon.MultipleArityHostApi.subtract"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])

    let inputX = 10
    let inputY = 7
    let inputEncoded = binaryMessenger.codec.encode([inputX, inputY])

    let expectation = XCTestExpectation(description: "subtraction")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputList = binaryMessenger.codec.decode(data) as? [Any]
      XCTAssertNotNil(outputList)
      
      let output = outputList![0] as? Int64
      XCTAssertEqual(3, output)
        XCTAssertTrue(outputList?.count == 1)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

  func testSimpleFlutter() throws {
    let binaryMessenger = HandlerBinaryMessenger(codec: codec) { args in
      return (args[0] as! Int) - (args[1] as! Int)
    }
    let api = MultipleArityFlutterApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "subtraction")
    api.subtract(x: 30, y: 10) { result in
      XCTAssertEqual(20, result)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }

}
