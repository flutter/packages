// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import test_plugin

@MainActor
struct AllDatatypesTests {

  @Test
  func allNull() async throws {
    let everything = AllNullableTypes()
    let binaryMessenger = EchoBinaryMessenger(codec: CoreTestsPigeonCodec.shared)
    let api = FlutterIntegrationCoreApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      api.echoNullable(everything) { result in
        switch result {
        case .success(let res):
          #expect(everything == res)
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  @Test
  func allEquals() async throws {
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

    await confirmation { confirmed in
      api.echoNullable(everything) { res in
        switch res {
        case .success(let res):
          #expect(everything == res)
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

  private let correctList: [Any?] = ["a", 2, "three"]
  private let matchingList: [Any?] = ["a", 2, "three"]
  private let differentList: [Any?] = ["a", 2, "three", 4.0]

  private let correctMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": "three"]
  private let matchingMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": "three"]
  private let differentKeyMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "d": "three"]
  private let differentValueMap: [AnyHashable: Any?] = ["a": 1, "b": 2, "c": "five"]

  private var correctListInMap: [AnyHashable: Any?] { ["a": 1, "b": 2, "c": correctList] }
  private var matchingListInMap: [AnyHashable: Any?] { ["a": 1, "b": 2, "c": matchingList] }
  private var differentListInMap: [AnyHashable: Any?] { ["a": 1, "b": 2, "c": differentList] }

  private var correctMapInList: [Any?] { ["a", 2, correctMap] }
  private var matchingMapInList: [Any?] { ["a", 2, matchingMap] }
  private var differentKeyMapInList: [Any?] { ["a", 2, differentKeyMap] }
  private var differentValueMapInList: [Any?] { ["a", 2, differentValueMap] }

  @Test
  func equalityMethodCorrectlyChecksDeepEquality() {
    let generic = AllNullableTypes(list: correctList, map: correctMap)
    let identical = generic
    #expect(generic == identical, "Identical copies should be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesNonMatchingClasses() {
    let generic = AllNullableTypes(list: correctList, map: correctMap)
    let allNull = AllNullableTypes()
    #expect(
      allNull != generic, "Instance with nil properties should not equal instance with values")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesNonMatchingListsInClasses() {
    let withList = AllNullableTypes(list: correctList)
    let withDifferentList = AllNullableTypes(list: differentList)
    #expect(
      withList != withDifferentList, "Instances with different lists should not be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesMatchingButUniqueListsInClasses() {
    let withList = AllNullableTypes(list: correctList)
    let withMatchingList = AllNullableTypes(list: matchingList)
    #expect(withList == withMatchingList, "Instances with equivalent lists should be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesNonMatchingKeysInMapsInClasses() {
    let withMap = AllNullableTypes(map: correctMap)
    let withDifferentMap = AllNullableTypes(map: differentKeyMap)
    #expect(
      withMap != withDifferentMap, "Instances with different map keys should not be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesNonMatchingValuesInMapsInClasses() {
    let withMap = AllNullableTypes(map: correctMap)
    let withDifferentMap = AllNullableTypes(map: differentValueMap)
    #expect(
      withMap != withDifferentMap, "Instances with different map values should not be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesMatchingButUniqueMapsInClasses() {
    let withMap = AllNullableTypes(map: correctMap)
    let withMatchingMap = AllNullableTypes(map: matchingMap)
    #expect(withMap == withMatchingMap, "Instances with equivalent maps should be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesNonMatchingListsNestedInMapsInClasses() {
    let withListInMap = AllNullableTypes(map: correctListInMap)
    let withDifferentListInMap = AllNullableTypes(map: differentListInMap)
    #expect(
      withListInMap != withDifferentListInMap,
      "Instances with different nested lists in maps should not be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesMatchingButUniqueListsNestedInMapsInClasses() {
    let withListInMap = AllNullableTypes(map: correctListInMap)
    let withMatchingListInMap = AllNullableTypes(map: matchingListInMap)
    #expect(
      withListInMap == withMatchingListInMap,
      "Instances with equivalent nested lists in maps should be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesNonMatchingKeysInMapsNestedInListsInClasses() {
    let withMapInList = AllNullableTypes(list: correctMapInList)
    let withDifferentMapInList = AllNullableTypes(list: differentKeyMapInList)
    #expect(
      withMapInList != withDifferentMapInList,
      "Instances with different nested map keys in lists should not be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesNonMatchingValuesInMapsNestedInListsInClasses() {
    let withMapInList = AllNullableTypes(list: correctMapInList)
    let withDifferentMapInList = AllNullableTypes(list: differentValueMapInList)
    #expect(
      withMapInList != withDifferentMapInList,
      "Instances with different nested map values in lists should not be equal")
  }

  @Test
  func equalityMethodCorrectlyIdentifiesMatchingButUniqueMapsNestedInListsInClasses() {
    let withMapInList = AllNullableTypes(list: correctMapInList)
    let withMatchingMapInList = AllNullableTypes(list: matchingMapInList)
    #expect(
      withMapInList == withMatchingMapInList,
      "Instances with equivalent nested maps in lists should be equal")
  }
}
