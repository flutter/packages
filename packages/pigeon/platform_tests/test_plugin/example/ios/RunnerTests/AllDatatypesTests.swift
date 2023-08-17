// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest
@testable import test_plugin

class AllDatatypesTests: XCTestCase {

  func testAllNull() throws {
    let everything = AllNullableTypes()
    let binaryMessenger = EchoBinaryMessenger(codec: FlutterIntegrationCoreApiCodec.shared)
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")

    api.echoNullable(everything) { result in
      XCTAssertNotNil(result)
      XCTAssertNil(result!.aNullableBool)
      XCTAssertNil(result!.aNullableInt)
      XCTAssertNil(result!.aNullableDouble)
      XCTAssertNil(result!.aNullableString)
      XCTAssertNil(result!.aNullableByteArray)
      XCTAssertNil(result!.aNullable4ByteArray)
      XCTAssertNil(result!.aNullable8ByteArray)
      XCTAssertNil(result!.aNullableFloatArray)
      XCTAssertNil(result!.aNullableList)
      XCTAssertNil(result!.aNullableMap)
      XCTAssertNil(result!.nullableNestedList)
      XCTAssertNil(result!.nullableMapWithAnnotations)
      XCTAssertNil(result!.nullableMapWithObject)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  func testAllEquals() throws {
    let everything = AllNullableTypes(
      aNullableBool: true,
      aNullableInt: 1,
      aNullableDouble: 2.0,
      aNullableByteArray: FlutterStandardTypedData(bytes: "1234".data(using: .utf8)!),
      aNullable4ByteArray: FlutterStandardTypedData(int32: "1234".data(using: .utf8)!),
      aNullable8ByteArray: FlutterStandardTypedData(int64: "12345678".data(using: .utf8)!),
      aNullableFloatArray: FlutterStandardTypedData(float64: "12345678".data(using: .utf8)!),
      aNullableList: [1, 2],
      aNullableMap: ["hello": 1234],
      nullableNestedList: [[true, false], [true]],
      nullableMapWithAnnotations: ["hello": "world"],
      nullableMapWithObject: ["hello": 1234, "goodbye" : "world"],
      aNullableString: "123"
    )
    
    let binaryMessenger = EchoBinaryMessenger(codec: FlutterIntegrationCoreApiCodec.shared)
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")

    api.echoNullable(everything) { result in
      XCTAssertNotNil(result)
      XCTAssertEqual(result!.aNullableBool, everything.aNullableBool)
      XCTAssertEqual(result!.aNullableInt, everything.aNullableInt)
      XCTAssertEqual(result!.aNullableDouble, everything.aNullableDouble)
      XCTAssertEqual(result!.aNullableString, everything.aNullableString)
      XCTAssertEqual(result!.aNullableByteArray, everything.aNullableByteArray)
      XCTAssertEqual(result!.aNullable4ByteArray, everything.aNullable4ByteArray)
      XCTAssertEqual(result!.aNullable8ByteArray, everything.aNullable8ByteArray)
      XCTAssertEqual(result!.aNullableFloatArray, everything.aNullableFloatArray)
      XCTAssert(equalsList(result!.aNullableList, everything.aNullableList))
      XCTAssert(equalsDictionary(result!.aNullableMap, everything.aNullableMap))
      XCTAssertEqual(result!.nullableNestedList, everything.nullableNestedList)
      XCTAssertEqual(result!.nullableMapWithAnnotations, everything.nullableMapWithAnnotations)
      XCTAssert(equalsDictionary(result!.nullableMapWithObject, everything.nullableMapWithObject))

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }
}
