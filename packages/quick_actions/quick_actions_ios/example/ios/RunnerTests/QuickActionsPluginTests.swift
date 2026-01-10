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

  @Test func handleMethodCall_setShortcutItems() {
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

  @Test func handleMethodCall_clearShortcutItems() {
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

  @Test func applicationDidFinishLaunchingWithOptions_launchWithShortcut() {
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

  @Test func applicationDidFinishLaunchingWithOptions_launchWithoutShortcut() {
    let flutterApi: MockFlutterApi = MockFlutterApi()
    let mockShortcutItemProvider = MockShortcutItemProvider()

    let plugin = QuickActionsPlugin(
      flutterApi: flutterApi,
      shortcutItemProvider: mockShortcutItemProvider)

    let launchResult = plugin.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
    #expect(
      launchResult, "didFinishLaunchingWithOptions must return true if not launched from shortcut.")
  }

  @Test func applicationDidBecomeActive_launchWithoutShortcut() {
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

  @Test func applicationDidBecomeActive_launchWithShortcut() async {
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

  @Test func applicationDidBecomeActive_launchWithShortcut_becomeActiveTwice() async {
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

    var invokeMethodCount = 0
    await confirmation("invokeMethod must be called") { confirmed in
      flutterApi.launchActionCallback = { aString in
        #expect(aString == item.type)
        invokeMethodCount += 1
        if invokeMethodCount == 1 {
          confirmed()
        }
      }

      let launchResult = plugin.application(
        UIApplication.shared,
        didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.shortcutItem: item])

      #expect(
        !launchResult, "didFinishLaunchingWithOptions must return false if launched from shortcut.")

      plugin.applicationDidBecomeActive(UIApplication.shared)
    }

    #expect(invokeMethodCount == 1)
  }
}
