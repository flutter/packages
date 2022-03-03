// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import Runner

class MockApi2Host: AHApi2Host {
    var output: Int32?
    
    func calculate(value: AHValue, completion: @escaping (AHValue) -> Void) {
        completion(AHValue(number: output))
    }
    
    func voidVoid(completion: @escaping () -> Void) {
        completion()
    }
}

class AsyncHandlersTest: XCTestCase {
    
    func testAsyncHost2Flutter() throws {
        let binaryMessenger = MockBinaryMessenger(codec: AHApi2FlutterCodec.shared)
        binaryMessenger.result = AHValue(number: 2)
        let api2Flutter = AHApi2Flutter(binaryMessenger: binaryMessenger)
        let input = AHValue(number: 1)
        
        let expectation = XCTestExpectation(description: "calculate callback")
        api2Flutter.calculate(value: input) { output in
            XCTAssertEqual(output.number, 2)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAsyncFlutter2HostVoidVoid() throws {
        let binaryMessenger = MockBinaryMessenger(codec: AHApi2HostCodec.shared)
        let mockApi2Host = MockApi2Host()
        mockApi2Host.output = 2
        AHApi2HostSetup.setUp(binaryMessenger: binaryMessenger, api: mockApi2Host)
        let channelName = "dev.flutter.pigeon.Api2Host.voidVoid"
        XCTAssertNotNil(binaryMessenger.handlers[channelName])
        
        let expectation = XCTestExpectation(description: "voidvoid callback")
        binaryMessenger.handlers[channelName]?(nil) { data in
            let outputMap = binaryMessenger.codec.decode(data) as? [String: Any]
            XCTAssert(outputMap?["result"] == nil)
            XCTAssert(outputMap?["error"] == nil)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAsyncFlutter2Host() throws {
        let binaryMessenger = MockBinaryMessenger(codec: AHApi2HostCodec.shared)
        let mockApi2Host = MockApi2Host()
        mockApi2Host.output = 2
        AHApi2HostSetup.setUp(binaryMessenger: binaryMessenger, api: mockApi2Host)
        let channelName = "dev.flutter.pigeon.Api2Host.calculate"
        XCTAssertNotNil(binaryMessenger.handlers[channelName])
        
        let input = AHValue(number: 1)
        let inputEncoded = binaryMessenger.codec.encode([input])
        
        let expectation = XCTestExpectation(description: "calculate callback")
        binaryMessenger.handlers[channelName]?(inputEncoded) { data in
            let outputMap = binaryMessenger.codec.decode(data) as? [String: Any]
            let output = outputMap?["result"] as? AHValue
            XCTAssertEqual(output?.number, 2)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
