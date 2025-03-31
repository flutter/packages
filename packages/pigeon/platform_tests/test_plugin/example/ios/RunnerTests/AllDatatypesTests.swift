// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import test_plugin

class AllDatatypesTests: XCTestCase {

  func testAllNull() throws {
    let everything = AllNullableTypes()
    let binaryMessenger = EchoBinaryMessenger(codec: CoreTestsPigeonCodec.shared)
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")

    api.echoNullable(everything) { result in
      switch result {
      case .success(let res):
        XCTAssertNotNil(res)
        XCTAssertNil(res!.aNullableBool)
        XCTAssertNil(res!.aNullableInt)
        XCTAssertNil(res!.aNullableDouble)
        XCTAssertNil(res!.aNullableString)
        XCTAssertNil(res!.aNullableByteArray)
        XCTAssertNil(res!.aNullable4ByteArray)
        XCTAssertNil(res!.aNullable8ByteArray)
        XCTAssertNil(res!.aNullableFloatArray)
        XCTAssertNil(res!.list)
        XCTAssertNil(res!.boolList)
        XCTAssertNil(res!.intList)
        XCTAssertNil(res!.doubleList)
        XCTAssertNil(res!.stringList)
        XCTAssertNil(res!.listList)
        XCTAssertNil(res!.map)
        XCTAssertNil(res!.stringMap)
        XCTAssertNil(res!.intMap)
        expectation.fulfill()
      case .failure(_):
        return

      }
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
      aNullableString: "123",
      list: ["string", 2],
      stringList: ["string", "another one"],
      intList: [1, 2],
      doubleList: [1.1, 2.2],
      boolList: [true, false],
      objectList: ["string", 2],
      listList: [[true], [false]],
      mapList: [["hello": 1234], ["hello": 1234]],
      map: ["hello": 1234],
      stringMap: ["hello": "you"],
      intMap: [1: 0],
      objectMap: ["hello": 1234],
      listMap: [1234: ["string", 2]],
      mapMap: [1234: ["hello": 1234]]
    )

    let binaryMessenger = EchoBinaryMessenger(codec: CoreTestsPigeonCodec.shared)
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")

    api.echoNullable(everything) { result in
      switch result {
      case .success(let res):
        XCTAssertNotNil(res)
        XCTAssertEqual(res!.aNullableBool, everything.aNullableBool)
        XCTAssertEqual(res!.aNullableInt, everything.aNullableInt)
        XCTAssertEqual(res!.aNullableDouble, everything.aNullableDouble)
        XCTAssertEqual(res!.aNullableString, everything.aNullableString)
        XCTAssertEqual(res!.aNullableByteArray, everything.aNullableByteArray)
        XCTAssertEqual(res!.aNullable4ByteArray, everything.aNullable4ByteArray)
        XCTAssertEqual(res!.aNullable8ByteArray, everything.aNullable8ByteArray)
        XCTAssertEqual(res!.aNullableFloatArray, everything.aNullableFloatArray)
        XCTAssert(equalsList(res!.list, everything.list))
        XCTAssert(equalsList(res!.stringList, everything.stringList))
        XCTAssert(equalsList(res!.intList, everything.intList))
        XCTAssert(equalsList(res!.doubleList, everything.doubleList))
        XCTAssert(equalsList(res!.boolList, everything.boolList))
        XCTAssert(equalsList(res!.objectList, everything.objectList))
        if res!.listList != nil {
          for (index, list) in res!.listList!.enumerated() {
            XCTAssert(equalsList(list, everything.listList![index]))
          }
        }
        if res!.mapList != nil {
          for (index, map) in res!.mapList!.enumerated() {
            XCTAssert(equalsDictionary(map, everything.mapList![index]))
          }
        }
        XCTAssert(equalsDictionary(res!.map, everything.map))
        XCTAssert(equalsDictionary(res!.stringMap, everything.stringMap))
        XCTAssert(equalsDictionary(res!.intMap, everything.intMap))
        XCTAssert(equalsDictionary(res!.objectMap, everything.objectMap))
        if res!.listMap != nil {
          for (index, list) in res!.listMap! {
            XCTAssert(equalsList(list, everything.listMap![index]!))
          }
        }
        if res!.mapMap != nil {
          for (index, map) in res!.mapMap! {
            XCTAssert(equalsDictionary(map, everything.mapMap![index]!))
          }
        }
        expectation.fulfill()
        return
      case .failure(_):
        return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }
}
