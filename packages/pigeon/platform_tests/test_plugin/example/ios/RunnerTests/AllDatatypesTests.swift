// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest
@testable import test_plugin

class AllDatatypesTests: XCTestCase {

  func testAllNull() throws {
    let everything = AllTypes()
    let binaryMessenger = EchoBinaryMessenger(codec: FlutterIntegrationCoreApiCodec.shared)
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")

    api.echoAllTypes(everything: everything) { result in
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
    let everything = AllTypes(
      aBool: false,
      anInt: 1,
      aDouble: 2.0,
      aString: "123",
      aByteArray: FlutterStandardTypedData(bytes: "1234".data(using: .utf8)!),
      a4ByteArray: FlutterStandardTypedData(int32: "1234".data(using: .utf8)!),
      a8ByteArray: FlutterStandardTypedData(int64: "12345678".data(using: .utf8)!),
      aFloatArray: FlutterStandardTypedData(float64: "12345678".data(using: .utf8)!),

      aList: [1, 2],
      aMap: ["hello": 1234],
      nestedList: [[true, false], [true]],
      mapWithAnnotations: ["hello": "world"],
      mapWithObject: ["hello": 1234, "goodbye" : "world"]
    )
    let binaryMessenger = EchoBinaryMessenger(codec: FlutterIntegrationCoreApiCodec.shared)
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")

    api.echoAllTypes(everything: everything) { result in
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
