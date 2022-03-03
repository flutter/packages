// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import Runner

//Int, Bool Double, String, List, Map

class PrimitiveTests: XCTestCase {

    func testIntPrimitive() throws {
        let binaryMessenger = EchoBinaryMessenger(codec: PrimitiveHostApiCodec.shared)
        let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        api.anInt(value: 1) { result in
            XCTAssertEqual(1, result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testBoolPrimitive() throws {
        let binaryMessenger = EchoBinaryMessenger(codec: PrimitiveHostApiCodec.shared)
        let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        api.aBool(value: true) { result in
            XCTAssertEqual(true, result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testDoublePrimitive() throws {
        let binaryMessenger = EchoBinaryMessenger(codec: PrimitiveHostApiCodec.shared)
        let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        let arg: Double = 1.5
        api.aDouble(value: arg) { result in
            XCTAssertEqual(arg, result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testStringPrimitive() throws {
        let binaryMessenger = EchoBinaryMessenger(codec: PrimitiveHostApiCodec.shared)
        let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        let arg: String = "hello"
        api.aString(value: arg) { result in
            XCTAssertEqual(arg, result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testListPrimitive() throws {
        let binaryMessenger = EchoBinaryMessenger(codec: PrimitiveHostApiCodec.shared)
        let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        let arg = ["hello"]
        api.aList(value: arg) { result in
            XCTAssert(equalsList(arg, result))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testMapPrimitive() throws {
        let binaryMessenger = EchoBinaryMessenger(codec: PrimitiveHostApiCodec.shared)
        let api = PrimitiveFlutterApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        let arg = ["hello": 1]
        api.aMap(value: arg) { result in
            XCTAssert(equalsDictionary(arg, result))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
