// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import quick_actions_ios

class MockFlutterApi: IOSQuickActionsFlutterApiProtocol {
  /// Method to allow for async testing.
  var launchActionCallback: ((String) -> Void)? = nil

  func launchAction(
    action actionArg: String, completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    self.launchActionCallback?(actionArg)
    completion(.success(Void()))
  }
}

class QuickActionsPluginTests: XCTestCase {

  func testHandleMethodCall_setShortcutItems() {
    let rawItem = ShortcutItemMessage(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      icon: "search_the_thing.png"
    )

    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    plugin.setShortcutItems(itemsList: [rawItem])
    XCTAssertEqual(mockShortcutItemProvider.shortcutItems, [item], "Must set shortcut items.")
  }

  func testHandleMethodCall_clearShortcutItems() {
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    mockShortcutItemProvider.shortcutItems = [item]

    plugin.clearShortcutItems()

    XCTAssertEqual(mockShortcutItemProvider.shortcutItems, [], "Must clear shortcut items.")

  }

  func testApplicationPerformActionForShortcutItem() {
    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")
    flutterApi.launchActionCallback = { aString in
      XCTAssertEqual(aString, item.type)
      invokeMethodExpectation.fulfill()
    }

    let actionResult = plugin.application(
      UIApplication.shared,
      performActionFor: item
    ) { success in
      // noop
    }

    XCTAssert(actionResult, "performActionForShortcutItem must return true.")
    waitForExpectations(timeout: 1)
  }

  func testApplicationDidFinishLaunchingWithOptions_launchWithShortcut() {
    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let launchResult = plugin.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])
    XCTAssertFalse(
      launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")
  }

  func testApplicationDidFinishLaunchingWithOptions_launchWithoutShortcut() {
    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    XCTAssert(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")
  }

  func testApplicationDidBecomeActive_launchWithoutShortcut() {
    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    XCTAssert(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")

    plugin.applicationDidBecomeActive(UIApplication.shared)
  }

  func testApplicationDidBecomeActive_launchWithShortcut() {
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")
    flutterApi.launchActionCallback = { aString in
      XCTAssertEqual(aString, item.type)
      invokeMethodExpectation.fulfill()
    }

    let launchResult = plugin.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])

    XCTAssertFalse(
      launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")

    plugin.applicationDidBecomeActive(UIApplication.shared)
    waitForExpectations(timeout: 1)
  }

  func testApplicationDidBecomeActive_launchWithShortcut_becomeActiveTwice() {
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")

    var invokeMethodCount = 0
    flutterApi.launchActionCallback = { aString in
      XCTAssertEqual(aString, item.type)
      invokeMethodCount += 1
      invokeMethodExpectation.fulfill()
    }

    let launchResult = plugin.application(
      UIApplication.shared,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])

    XCTAssertFalse(
      launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")

    plugin.applicationDidBecomeActive(UIApplication.shared)
    waitForExpectations(timeout: 1)

    XCTAssertEqual(invokeMethodCount, 1, "shortcut should only be handled once per launch.")
  }
}
