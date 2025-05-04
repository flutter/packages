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
      stringList: ["string", "another one", nil],
      intList: [1, 2],
      doubleList: [1.1, 2.2],
      boolList: [true, false],
      objectList: ["string", 2],
      listList: [[true], [false]],
      mapList: [["hello": 1234], ["hello": 1234]],
      map: ["hello": 1234, "null": nil],
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

  private let correctList: [Any?] = ["a", 2, "three"]
  private let matchingList: [Any?] = ["a", 2, "three"]
  private let differentList: [Any?] = ["a", 2, "three", 4.0]

  private let correctMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": "three"]
  private let matchingMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": "three"]
  private let differentKeyMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "d": "three"]
  private let differentValueMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": "five"]

  private lazy var correctListInMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": correctList]
  private lazy var matchingListInMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": matchingList]
  private lazy var differentListInMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": differentList]

  private lazy var correctMapInList: [Any?] = ["a", 2, correctMap]
  private lazy var matchingMapInList: [Any?] = ["a", 2, matchingMap]
  private lazy var differentKeyMapInList: [Any?] = ["a", 2, differentKeyMap]
  private lazy var differentValueMapInList: [Any?] = ["a", 2, differentValueMap]

  func testEqualityMethodCorrectlyChecksDeepEquality() {
    let generic = AllNullableTypes(list: correctList, map: correctMap)
    let identical = generic
    XCTAssertEqual(generic, identical, "Identical copies should be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesNonMatchingClasses() {
    let generic = AllNullableTypes(list: correctList, map: correctMap)
    let allNull = AllNullableTypes()
    XCTAssertNotEqual(
      allNull, generic, "Instance with nil properties should not equal instance with values")
  }

  func testEqualityMethodCorrectlyIdentifiesNonMatchingListsInClasses() {
    let withList = AllNullableTypes(list: correctList)
    let withDifferentList = AllNullableTypes(list: differentList)
    XCTAssertNotEqual(
      withList, withDifferentList, "Instances with different lists should not be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesMatchingButUniqueListsInClasses() {
    let withList = AllNullableTypes(list: correctList)
    let withMatchingList = AllNullableTypes(list: matchingList)
    XCTAssertEqual(withList, withMatchingList, "Instances with equivalent lists should be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesNonMatchingKeysInMapsInClasses() {
    let withMap = AllNullableTypes(map: correctMap)
    let withDifferentMap = AllNullableTypes(map: differentKeyMap)
    XCTAssertNotEqual(
      withMap, withDifferentMap, "Instances with different map keys should not be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesNonMatchingValuesInMapsInClasses() {
    let withMap = AllNullableTypes(map: correctMap)
    let withDifferentMap = AllNullableTypes(map: differentValueMap)
    XCTAssertNotEqual(
      withMap, withDifferentMap, "Instances with different map values should not be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesMatchingButUniqueMapsInClasses() {
    let withMap = AllNullableTypes(map: correctMap)
    let withMatchingMap = AllNullableTypes(map: matchingMap)
    XCTAssertEqual(withMap, withMatchingMap, "Instances with equivalent maps should be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesNonMatchingListsNestedInMapsInClasses() {
    let withListInMap = AllNullableTypes(map: correctListInMap)
    let withDifferentListInMap = AllNullableTypes(map: differentListInMap)
    XCTAssertNotEqual(
      withListInMap, withDifferentListInMap,
      "Instances with different nested lists in maps should not be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesMatchingButUniqueListsNestedInMapsInClasses() {
    let withListInMap = AllNullableTypes(map: correctListInMap)
    let withMatchingListInMap = AllNullableTypes(map: matchingListInMap)
    XCTAssertEqual(
      withListInMap, withMatchingListInMap,
      "Instances with equivalent nested lists in maps should be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesNonMatchingKeysInMapsNestedInListsInClasses() {
    let withMapInList = AllNullableTypes(list: correctMapInList)
    let withDifferentMapInList = AllNullableTypes(list: differentKeyMapInList)
    XCTAssertNotEqual(
      withMapInList, withDifferentMapInList,
      "Instances with different nested map keys in lists should not be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesNonMatchingValuesInMapsNestedInListsInClasses() {
    let withMapInList = AllNullableTypes(list: correctMapInList)
    let withDifferentMapInList = AllNullableTypes(list: differentValueMapInList)
    XCTAssertNotEqual(
      withMapInList, withDifferentMapInList,
      "Instances with different nested map values in lists should not be equal")
  }

  func testEqualityMethodCorrectlyIdentifiesMatchingButUniqueMapsNestedInListsInClasses() {
    let withMapInList = AllNullableTypes(list: correctMapInList)
    let withMatchingMapInList = AllNullableTypes(list: matchingMapInList)
    XCTAssertEqual(
      withMapInList, withMatchingMapInList,
      "Instances with equivalent nested maps in lists should be equal")
  }
}
