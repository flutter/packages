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
        XCTAssert(everything == res!)
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

    api.echoNullable(everything) { res in
      switch res {
      case .success(let res):
        XCTAssert(everything == res!)
        expectation.fulfill()
        return
      case .failure(_):
        return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }
}
