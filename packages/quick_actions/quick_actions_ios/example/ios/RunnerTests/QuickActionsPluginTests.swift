// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

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

@MainActor
struct QuickActionsPluginTests {

  @Test func handleMethodCallSetShortcutItems() {
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
    #expect(mockShortcutItemProvider.shortcutItems == [item])
  }

  @Test func handleMethodCallClearShortcutItems() {
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

    #expect(mockShortcutItemProvider.shortcutItems == [])

  }

  @Test func applicationPerformActionForShortcutItem() async {
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

    await confirmation("invokeMethod must be called") { confirmed in
      flutterApi.launchActionCallback = { aString in
        #expect(aString == item.type)
        confirmed()
      }

      let actionResult = plugin.application(
        UIApplication.shared,
        performActionFor: item
      ) { success in
        // noop
      }

      #expect(actionResult, "performActionForShortcutItem must return true.")
    }
  }

  @Test func applicationDidFinishLaunchingWithOptionsLaunchWithShortcut() {
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
    #expect(
      !launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")
  }

  @Test func applicationDidFinishLaunchingWithOptionsLaunchWithoutShortcut() {
    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    #expect(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")
  }

  @Test func applicationDidBecomeActiveLaunchWithoutShortcut() {
    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    #expect(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")

    plugin.applicationDidBecomeActive(UIApplication.shared)
  }

  @Test func applicationDidBecomeActiveLaunchWithShortcut() async {
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

    await confirmation("invokeMethod must be called") { confirmed in
      flutterApi.launchActionCallback = { aString in
        #expect(aString == item.type)
        confirmed()
      }

      let launchResult = plugin.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])

      #expect(
        !launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")

      plugin.applicationDidBecomeActive(UIApplication.shared)
    }
  }

  @Test func applicationDidBecomeActiveLaunchWithShortcutBecomeActiveTwice() async {
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

    await confirmation("shortcut should be handled when application becomes active") { confirmed in
      flutterApi.launchActionCallback = { aString in
        #expect(aString == item.type)
        confirmed()
      }

      let launchResult = plugin.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])

      #expect(
        !launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")

      plugin.applicationDidBecomeActive(UIApplication.shared)
    }
    await confirmation("shortcut should only be handled once per launch", expectedCount: 0) {
      confirmed in
      flutterApi.launchActionCallback = { _ in
        confirmed()
      }

      plugin.applicationDidBecomeActive(UIApplication.shared)
    }
  }
}
