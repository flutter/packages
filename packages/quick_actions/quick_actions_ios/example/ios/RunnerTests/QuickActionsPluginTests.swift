// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import quick_actions_ios

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

    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let parseShortcutItemsExpectation = expectation(
      description: "parseShortcutItems must be called.")
    mockShortcutItemParser.parseShortcutItemsStub = { items in
      XCTAssertEqual(items.first!.icon, rawItem.icon)
      XCTAssertEqual(items.first!.localizedTitle, rawItem.localizedTitle)
      XCTAssertEqual(items.first!.type, rawItem.type)
      parseShortcutItemsExpectation.fulfill()
      return [item]
    }

    try? plugin.setShortcutItems(itemsList: [rawItem])
    XCTAssertEqual(mockShortcutItemProvider.shortcutItems, [item], "Must set shortcut items.")
    waitForExpectations(timeout: 1)
  }

  func testHandleMethodCall_clearShortcutItems() {
    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    mockShortcutItemProvider.shortcutItems = [item]

    try? plugin.clearShortcutItems()

    XCTAssertEqual(mockShortcutItemProvider.shortcutItems, [], "Must clear shortcut items.")

  }

  func testApplicationPerformActionForShortcutItem() {
    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let item = UIApplicationShortcutItem(
      type: "SearchTheThing",
      localizedTitle: "Search the thing",
      localizedSubtitle: nil,
      icon: UIApplicationShortcutIcon(templateImageName: "search_the_thing.png"),
      userInfo: nil)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")
    plugin.testStub = {
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
    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

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
    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    XCTAssert(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")
  }

  func testApplicationDidBecomeActive_launchWithoutShortcut() {
    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

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

    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")
    plugin.testStub = {
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

    let mockMessenger = MockBinaryMessenger()
    let mockShortcutItemProvider = MockShortcutItemProvider()
    let mockShortcutItemParser = MockShortcutItemParser()

    let plugin = QuickActionsPlugin(
      messenger: mockMessenger,
      shortcutItemProvider: mockShortcutItemProvider,
      shortcutItemParser: mockShortcutItemParser)

    let invokeMethodExpectation = expectation(description: "invokeMethod must be called.")

    var invokeMethodCount = 0
    plugin.testStub = {
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
  }

}
