// Copyright 2013 The Flutter Authors. All rights reserved.
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

  // Deprecated system tests.

  let prefixes: [String] = ["aPrefix", ""]

  func testSetAndGet() throws {
    for aPrefix in prefixes {
      let plugin = DeprecatedSharedPreferencesPlugin()

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
      let plugin = DeprecatedSharedPreferencesPlugin()

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
      let plugin = DeprecatedSharedPreferencesPlugin()
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
      let plugin = DeprecatedSharedPreferencesPlugin()
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
      let plugin = DeprecatedSharedPreferencesPlugin()
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

  func testAsyncSetAndGet() throws {

    let plugin = SharedPreferencesPlugin()

    plugin.setBool(key: "aBool", value: true)
    plugin.setDouble(key: "aDouble", value: 3.14)
    plugin.setValue(key: "anInt", value: 42)
    plugin.setValue(key: "aString", value: "hello world")
    plugin.setValue(key: "aStringList", value: ["hello", "world"])

    XCTAssertEqual(plugin.getBool(key: "aBool", options: emptyOptions), true)
    XCTAssertEqual(
      plugin.getDouble(key: "aDouble", options: emptyOptions), 3.14, accuracy: 0.0001)
    XCTAssertEqual(plugin.getInt(key: "anInt", options: emptyOptions), 42)
    XCTAssertEqual(plugin.getString(key: "aString", options: emptyOptions), "hello world")
    XCTAssertEqual(
      plugin.getStringList(key: "aStringList", options: emptyOptions), ["hello", "world"])
  }

  func testAsyncGetAll() throws {

    let plugin = SharedPreferencesPlugin()

    plugin.setBool(key: "aBool", value: true)
    plugin.setDouble(key: "aDouble", value: 3.14)
    plugin.setValue(key: "anInt", value: 42)
    plugin.setValue(key: "aString", value: "hello world")
    plugin.setValue(key: "aStringList", value: ["hello", "world"])

    let storedValues = plugin.getAll(allowList: nil, options: emptyOptions)
    XCTAssertEqual(storedValues["aBool"] as? Bool, true)
    XCTAssertEqual(storedValues["aDouble"] as! Double, 3.14, accuracy: 0.0001)
    XCTAssertEqual(storedValues["anInt"] as? Int, 42)
    XCTAssertEqual(storedValues["aString"] as? String, "hello world")
    XCTAssertEqual(storedValues["aStringList"] as? [String], ["hello", "world"])

  }

  func testAsyncGetAllWithAllowList() throws {

    let plugin = SharedPreferencesPlugin()

    plugin.setBool(key: "aBool", value: true)
    plugin.setDouble(key: "aDouble", value: 3.14)
    plugin.setValue(key: "anInt", value: 42)
    plugin.setValue(key: "aString", value: "hello world")
    plugin.setValue(key: "aStringList", value: ["hello", "world"])

    let storedValues = plugin.getAll(allowList: ["aBool"], options: emptyOptions)
    XCTAssertEqual(storedValues["aBool"] as? Bool, true)
    XCTAssertNil(storedValues["aDouble"] ?? nil)
    XCTAssertNil(storedValues["anInt"] ?? nil)
    XCTAssertNil(storedValues["aString"] ?? nil)
    XCTAssertNil(storedValues["aStringList"] ?? nil)

  }

  func testAsyncRemove() throws {

    let plugin = SharedPreferencesPlugin()
    plugin.setString(key: testKey, value: testValue, options: emptyOptions)

    // Make sure there is something to remove, so the test can't pass due to a set failure.
    let preRemovalValue = plugin.getString(key: testKey, options: emptyOptions)
    XCTAssertEqual(preRemovalValue, testValue)

    // Then verify that removing it works.
    plugin.remove(key: testKey, options: emptyOptions)

    let finalValue = plugin.getString(key: testKey, options: emptyOptions)
    XCTAssertNil(finalValue)

  }

  func testAsyncClearWithNoAllowlist() throws {

    let plugin = SharedPreferencesPlugin()
    plugin.setString(key: testKey, value: testValue, options: emptyOptions)

    // Make sure there is something to remove, so the test can't pass due to a set failure.
    let preRemovalValue = plugin.getString(key: testKey, options: emptyOptions)
    XCTAssertEqual(preRemovalValue, testValue)

    // Then verify that clearing works.
    plugin.clear(allowList: nil, options: emptyOptions)

    let finalValue = plugin.getString(key: testKey, options: emptyOptions)
    XCTAssertNil(finalValue)

  }

  func testAsyncClearWithAllowlist() throws {

    let plugin = SharedPreferencesPlugin()

    plugin.setString(key: testKey, value: testValue, options: emptyOptions)
    plugin.setString(key: testKeyToStay, value: testValue, options: emptyOptions)

    // Make sure there is something to clear, so the test can't pass due to a set failure.
    let preRemovalValue = plugin.getString(key: testKey, options: emptyOptions)
    XCTAssertEqual(preRemovalValue, testValue)

    plugin.clear(allowList: [testKey], options: emptyOptions)

    let finalValueNil = plugin.getString(key: testKey, options: emptyOptions)
    XCTAssertNil(finalValue)
    let finalValueNotNil = plugin.getString(key: testKeyTwo, options: emptyOptions)
    XCTAssertEqual(finalValue, testValue)
  }
}
