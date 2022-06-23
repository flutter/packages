// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import Runner

class MockApi2Host: Api2Host {
  var output: Int32?
  
  func calculate(value: Value, completion: @escaping (Value) -> Void) {
    completion(Value(number: output))
  }
  
  func voidVoid(completion: @escaping () -> Void) {
    completion()
  }
}

class AsyncHandlersTest: XCTestCase {
  
  func testAsyncHost2Flutter() throws {
    let binaryMessenger = MockBinaryMessenger<Value>(codec: Api2FlutterCodec.shared)
    binaryMessenger.result = Value(number: 2)
    let api2Flutter = Api2Flutter(binaryMessenger: binaryMessenger)
    let input = Value(number: 1)
    
    let expectation = XCTestExpectation(description: "calculate callback")
    api2Flutter.calculate(value: input) { output in
      XCTAssertEqual(output.number, 2)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testAsyncFlutter2HostVoidVoid() throws {
    let binaryMessenger = MockBinaryMessenger<Value>(codec: Api2HostCodec.shared)
    let mockApi2Host = MockApi2Host()
    mockApi2Host.output = 2
    Api2HostSetup.setUp(binaryMessenger: binaryMessenger, api: mockApi2Host)
    let channelName = "dev.flutter.pigeon.Api2Host.voidVoid"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])
    
    let expectation = XCTestExpectation(description: "voidvoid callback")
    binaryMessenger.handlers[channelName]?(nil) { data in
      let outputMap = binaryMessenger.codec.decode(data) as? [String: Any]
      XCTAssertNil(outputMap?["result"])
      XCTAssertNil(outputMap?["error"])
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testAsyncFlutter2Host() throws {
    let binaryMessenger = MockBinaryMessenger<Value>(codec: Api2HostCodec.shared)
    let mockApi2Host = MockApi2Host()
    mockApi2Host.output = 2
    Api2HostSetup.setUp(binaryMessenger: binaryMessenger, api: mockApi2Host)
    let channelName = "dev.flutter.pigeon.Api2Host.calculate"
    XCTAssertNotNil(binaryMessenger.handlers[channelName])
    
    let input = Value(number: 1)
    let inputEncoded = binaryMessenger.codec.encode([input])
    
    let expectation = XCTestExpectation(description: "calculate callback")
    binaryMessenger.handlers[channelName]?(inputEncoded) { data in
      let outputMap = binaryMessenger.codec.decode(data) as? [String: Any]
      let output = outputMap?["result"] as? Value
      XCTAssertEqual(output?.number, 2)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
  }
}
