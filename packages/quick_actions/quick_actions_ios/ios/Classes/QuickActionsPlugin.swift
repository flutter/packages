// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

public final class QuickActionsPlugin: NSObject, FlutterPlugin, IosQuickActionsApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let instance = QuickActionsPlugin(messenger: messenger)
    IosQuickActionsApiSetup.setUp(binaryMessenger: messenger, api: instance)
    registrar.addApplicationDelegate(instance)
  }

  private let shortcutItemProvider: ShortcutItemProviding
  private let shortcutItemParser: ShortcutItemParser
  private let flutterApi: IosQuickActionsFlutterApi
  /// The type of the shortcut item selected when launching the app.
  private var launchingShortcutType: String? = nil

  init(
    messenger: FlutterBinaryMessenger,
    shortcutItemProvider: ShortcutItemProviding = UIApplication.shared,
    shortcutItemParser: ShortcutItemParser = DefaultShortcutItemParser()
  ) {
    self.shortcutItemProvider = shortcutItemProvider
    self.shortcutItemParser = shortcutItemParser
    self.flutterApi = IosQuickActionsFlutterApi(binaryMessenger: messenger)
  }

  var testStub: (() -> Void)? = nil

  func setShortcutItems(itemsList: [ShortcutItemMessage]) throws {
    shortcutItemProvider.shortcutItems = shortcutItemParser.parseShortcutItems(itemsList)
  }

  func clearShortcutItems() throws {
    shortcutItemProvider.shortcutItems = []
  }

  public func application(
    _ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) -> Bool {
    handleShortcut(shortcutItem.type)
    return true
  }

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
  ) -> Bool {
    if let shortcutItem = launchOptions[UIApplication.LaunchOptionsKey.shortcutItem]
      as? UIApplicationShortcutItem
    {
      // Keep hold of the shortcut type and handle it in the
      // `applicationDidBecomeActive:` method once the Dart MethodChannel
      // is initialized.
      launchingShortcutType = shortcutItem.type

      // Return false to indicate we handled the quick action to ensure
      // the `application:performActionFor:` method is not called (as
      // per Apple's documentation:
      // https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622935-application).
      return false
    }
    return true
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    if let shortcutType = launchingShortcutType {
      handleShortcut(shortcutType)
      self.launchingShortcutType = nil
    }
  }

  func handleShortcut(_ shortcut: String) {
    self.testStub?()
    flutterApi.launchAction(action: shortcut) {
      // noop
    }
  }
}
