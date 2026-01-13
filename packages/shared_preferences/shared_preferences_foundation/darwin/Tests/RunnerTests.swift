// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import shared_preferences_foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

class RunnerTests: XCTestCase {
  let testKey = "foo"
  let testKeyTwo = "baz"
  let testValue = "bar"

  // Legacy system tests.

  let prefixes: [String] = ["aPrefix", ""]

  func testSetAndGet() throws {
    for aPrefix in prefixes {
      let plugin = LegacySharedPreferencesPlugin()

      plugin.setBool(key: "\(aPrefix)aBool", value: true)
      plugin.setDouble(key: "\(aPrefix)aDouble", value: 3.14)
      plugin.setValue(key: "\(aPrefix)anInt", value: 42)
      plugin.setValue(key: "\(aPrefix)aString", value: "hello world")
      plugin.setValue(key: "\(aPrefix)aStringList", value: ["hello", "world"])

      let storedValues = plugin.getAll(prefix: aPrefix, allowList: nil)
      XCTAssertEqual(storedValues["\(aPrefix)aBool"] as? Bool, true)
      XCTAssertEqual(storedValues["\(aPrefix)aDouble"] as! Double, 3.14, accuracy: 0.0001)
      XCTAssertEqual(storedValues["\(aPrefix)anInt"] as? Int, 42)
      XCTAssertEqual(storedValues["\(aPrefix)aString"] as? String, "hello world")
      XCTAssertEqual(storedValues["\(aPrefix)aStringList"] as? [String], ["hello", "world"])
    }
  }

  func testGetWithAllowList() throws {
    for aPrefix in prefixes {
      let plugin = LegacySharedPreferencesPlugin()

      plugin.setBool(key: "\(aPrefix)aBool", value: true)
      plugin.setDouble(key: "\(aPrefix)aDouble", value: 3.14)
      plugin.setValue(key: "\(aPrefix)anInt", value: 42)
      plugin.setValue(key: "\(aPrefix)aString", value: "hello world")
      plugin.setValue(key: "\(aPrefix)aStringList", value: ["hello", "world"])

      let storedValues = plugin.getAll(prefix: aPrefix, allowList: ["\(aPrefix)aBool"])
      XCTAssertEqual(storedValues["\(aPrefix)aBool"] as? Bool, true)
      XCTAssertNil(storedValues["\(aPrefix)aDouble"] ?? nil)
      XCTAssertNil(storedValues["\(aPrefix)anInt"] ?? nil)
      XCTAssertNil(storedValues["\(aPrefix)aString"] ?? nil)
      XCTAssertNil(storedValues["\(aPrefix)aStringList"] ?? nil)
    }
  }

  func testRemove() throws {
    for aPrefix in prefixes {
      let plugin = LegacySharedPreferencesPlugin()
      let testKey = "\(aPrefix)\(testKey)"
      plugin.setValue(key: testKey, value: 42)

      // Make sure there is something to remove, so the test can't pass due to a set failure.
      let preRemovalValues = plugin.getAll(prefix: aPrefix, allowList: nil)
      XCTAssertEqual(preRemovalValues[testKey] as? Int, 42)

      // Then verify that removing it works.
      plugin.remove(key: testKey)

      let finalValues = plugin.getAll(prefix: aPrefix, allowList: nil)
      XCTAssertNil(finalValues[testKey] as Any?)
    }
  }

  func testClearWithNoAllowlist() throws {
    for aPrefix in prefixes {
      let plugin = LegacySharedPreferencesPlugin()
      let testKey = "\(aPrefix)\(testKey)"
      plugin.setValue(key: testKey, value: 42)

      // Make sure there is something to clear, so the test can't pass due to a set failure.
      let preRemovalValues = plugin.getAll(prefix: aPrefix, allowList: nil)
      XCTAssertEqual(preRemovalValues[testKey] as? Int, 42)

      // Then verify that clearing works.
      plugin.clear(prefix: aPrefix, allowList: nil)

      let finalValues = plugin.getAll(prefix: aPrefix, allowList: nil)
      XCTAssertNil(finalValues[testKey] as Any?)
    }
  }

  func testClearWithAllowlist() throws {
    for aPrefix in prefixes {
      let plugin = LegacySharedPreferencesPlugin()
      let testKey = "\(aPrefix)\(testKey)"
      plugin.setValue(key: testKey, value: 42)

      // Make sure there is something to clear, so the test can't pass due to a set failure.
      let preRemovalValues = plugin.getAll(prefix: aPrefix, allowList: nil)
      XCTAssertEqual(preRemovalValues[testKey] as? Int, 42)

      plugin.clear(prefix: aPrefix, allowList: ["\(aPrefix)\(testKeyTwo)"])

      let finalValues = plugin.getAll(prefix: aPrefix, allowList: nil)
      XCTAssertEqual(finalValues[testKey] as? Int, 42)
    }
  }

  // Async system tests.

  let emptyOptions = SharedPreferencesPigeonOptions()
  let optionsWithSuiteName = SharedPreferencesPigeonOptions(
    suiteName: "group.example.sharedPreferencesFoundationExample")

  func testAsyncSetAndGet() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aBool", value: true, options: emptyOptions)
    try plugin.set(key: "aDouble", value: 3.14, options: emptyOptions)
    try plugin.set(key: "anInt", value: 42, options: emptyOptions)
    try plugin.set(key: "aString", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aStringList", value: ["hello", "world"], options: emptyOptions)

    XCTAssertEqual(((try plugin.getValue(key: "aBool", options: emptyOptions)) != nil), true)
    XCTAssertEqual(
      try plugin.getValue(key: "aDouble", options: emptyOptions) as! Double, 3.14, accuracy: 0.0001)
    XCTAssertEqual(try plugin.getValue(key: "anInt", options: emptyOptions) as! Int, 42)
    XCTAssertEqual(
      try plugin.getValue(key: "aString", options: emptyOptions) as! String, "hello world")
    XCTAssertEqual(
      try plugin.getValue(key: "aStringList", options: emptyOptions) as! [String],
      ["hello", "world"])
  }

  func testAsyncGetAll() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aBool", value: true, options: emptyOptions)
    try plugin.set(key: "aDouble", value: 3.14, options: emptyOptions)
    try plugin.set(key: "anInt", value: 42, options: emptyOptions)
    try plugin.set(key: "aString", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aStringList", value: ["hello", "world"], options: emptyOptions)

    let storedValues = try plugin.getAll(allowList: nil, options: emptyOptions)
    XCTAssertEqual(storedValues["aBool"] as? Bool, true)
    XCTAssertEqual(storedValues["aDouble"] as! Double, 3.14, accuracy: 0.0001)
    XCTAssertEqual(storedValues["anInt"] as? Int, 42)
    XCTAssertEqual(storedValues["aString"] as? String, "hello world")
    XCTAssertEqual(storedValues["aStringList"] as? [String], ["hello", "world"])

  }

  func testAsyncGetAllWithAndWithoutSuiteName() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aKey", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aKeySuite", value: "hello world with suite", options: optionsWithSuiteName)

    let storedValues = try plugin.getAll(allowList: nil, options: emptyOptions)
    XCTAssertEqual(storedValues["aKey"] as? String, "hello world")

    let storedValuesWithGroup = try plugin.getAll(allowList: nil, options: optionsWithSuiteName)
    XCTAssertEqual(storedValuesWithGroup["aKeySuite"] as? String, "hello world with suite")
  }

  func testAsyncGetAllWithAllowList() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aBool", value: true, options: emptyOptions)
    try plugin.set(key: "aDouble", value: 3.14, options: emptyOptions)
    try plugin.set(key: "anInt", value: 42, options: emptyOptions)
    try plugin.set(key: "aString", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aStringList", value: ["hello", "world"], options: emptyOptions)

    let storedValues = try plugin.getAll(allowList: ["aBool"], options: emptyOptions)
    XCTAssertEqual(storedValues["aBool"] as? Bool, true)
    XCTAssertNil(storedValues["aDouble"] ?? nil)
    XCTAssertNil(storedValues["anInt"] ?? nil)
    XCTAssertNil(storedValues["aString"] ?? nil)
    XCTAssertNil(storedValues["aStringList"] ?? nil)

  }

  func testAsyncRemove() throws {
    let plugin = SharedPreferencesPlugin()
    try plugin.set(key: testKey, value: testValue, options: emptyOptions)

    // Make sure there is something to remove, so the test can't pass due to a set failure.
    let preRemovalValue = try plugin.getValue(key: testKey, options: emptyOptions) as! String
    XCTAssertEqual(preRemovalValue, testValue)

    // Then verify that removing it works.
    try plugin.remove(key: testKey, options: emptyOptions)

    let finalValue = try plugin.getValue(key: testKey, options: emptyOptions)
    XCTAssertNil(finalValue)

  }

  func testAsyncClearWithNoAllowlist() throws {
    let plugin = SharedPreferencesPlugin()
    try plugin.set(key: testKey, value: testValue, options: emptyOptions)

    // Make sure there is something to remove, so the test can't pass due to a set failure.
    let preRemovalValue = try plugin.getValue(key: testKey, options: emptyOptions) as! String
    XCTAssertEqual(preRemovalValue, testValue)

    // Then verify that clearing works.
    try plugin.clear(allowList: nil, options: emptyOptions)

    let finalValue = try plugin.getValue(key: testKey, options: emptyOptions)
    XCTAssertNil(finalValue)

  }

  func testAsyncClearWithAllowlist() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: testKey, value: testValue, options: emptyOptions)
    try plugin.set(key: testKeyTwo, value: testValue, options: emptyOptions)

    // Make sure there is something to clear, so the test can't pass due to a set failure.
    let preRemovalValue = try plugin.getValue(key: testKey, options: emptyOptions) as! String
    XCTAssertEqual(preRemovalValue, testValue)

    try plugin.clear(allowList: [testKey], options: emptyOptions)

    let finalValueNil = try plugin.getValue(key: testKey, options: emptyOptions)
    XCTAssertNil(finalValueNil)
    let finalValueNotNil = try plugin.getValue(key: testKeyTwo, options: emptyOptions) as! String
    XCTAssertEqual(finalValueNotNil, testValue)
  }
}
