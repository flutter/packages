// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import Runner

class AllDatatypesTests: XCTestCase {
    
    func testAllNull() throws {
        let everything = ADEverything()
        let binaryMessenger = EchoBinaryMessenger(codec: ADFlutterEverythingCodec.shared)
        let api = ADFlutterEverything(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        
        api.echo(everything: everything) { result in
            XCTAssertNil(result.aBool)
            XCTAssertNil(result.anInt)
            XCTAssertNil(result.aDouble)
            XCTAssertNil(result.aString)
            XCTAssertNil(result.aByteArray)
            XCTAssertNil(result.a4ByteArray)
            XCTAssertNil(result.a8ByteArray)
            XCTAssertNil(result.aFloatArray)
            XCTAssertNil(result.aList)
            XCTAssertNil(result.aMap)
            XCTAssertNil(result.nestedList)
            XCTAssertNil(result.mapWithAnnotations)
            XCTAssertNil(result.mapWithObject)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAllEquals() throws {
        let everything = ADEverything(
            aBool: false,
            anInt: 1,
            aDouble: 2.0,
            aString: "123",
            aByteArray: [UInt8]("1234".data(using: .utf8)!),
            a4ByteArray: [Int32].init(arrayLiteral: 1, 2, 3, 4),
            a8ByteArray: [Int64].init(arrayLiteral: 1, 2, 3, 4, 5, 6, 7, 8),
            aFloatArray: [Float64].init(arrayLiteral: 1, 2, 3, 4, 5, 6, 7, 8),
            aList: [1, 2],
            aMap: ["hello": 1234],
            nestedList: [[true, false], [true]],
            mapWithAnnotations: ["hello": "world"],
            mapWithObject: ["hello": 1234, "goodbye" : "world"]
        )
        let binaryMessenger = EchoBinaryMessenger(codec: ADFlutterEverythingCodec.shared)
        let api = ADFlutterEverything(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        
        api.echo(everything: everything) { result in
            XCTAssertEqual(result.aBool, everything.aBool)
            XCTAssertEqual(result.anInt, everything.anInt)
            XCTAssertEqual(result.aDouble, everything.aDouble)
            XCTAssertEqual(result.aString, everything.aString)
            XCTAssertEqual(result.aByteArray, everything.aByteArray)
            XCTAssertEqual(result.a4ByteArray, everything.a4ByteArray)
            XCTAssertEqual(result.a8ByteArray, everything.a8ByteArray)
            XCTAssertEqual(result.aFloatArray, everything.aFloatArray)
            XCTAssert(equalsList(result.aList, everything.aList))
            XCTAssert(equalsDictionary(result.aMap, everything.aMap))
            XCTAssertEqual(result.nestedList, everything.nestedList)
            XCTAssertEqual(result.mapWithAnnotations, everything.mapWithAnnotations)
            XCTAssert(equalsDictionary(result.mapWithObject, everything.mapWithObject))
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
