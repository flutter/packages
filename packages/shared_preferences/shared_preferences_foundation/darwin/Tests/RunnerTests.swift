// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import shared_preferences_foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

// The shared preferences API is thread-safe.
// Serially mutate shared preferences
// so tests don't stomp on each other.
@Suite(.serialized)
struct RunnerTests {
  let testKey = "foo"
  let testKeyTwo = "baz"
  let testValue = "bar"

  // Legacy system tests.

  @Test(arguments: ["aPrefix", ""])
  func setAndGet(prefix: String) throws {
    let plugin = LegacySharedPreferencesPlugin()

    plugin.setBool(key: "\(prefix)aBool", value: true)
    plugin.setDouble(key: "\(prefix)aDouble", value: 3.14)
    plugin.setValue(key: "\(prefix)anInt", value: 42)
    plugin.setValue(key: "\(prefix)aString", value: "hello world")
    plugin.setValue(key: "\(prefix)aStringList", value: ["hello", "world"])

    let storedValues = plugin.getAll(prefix: prefix, allowList: nil)
    #expect(storedValues["\(prefix)aBool"] as? Bool == true)

    let doubleValue = try #require(storedValues["\(prefix)aDouble"] as? Double)
    #expect(abs(doubleValue - 3.14) < 0.0001)

    #expect(storedValues["\(prefix)anInt"] as? Int == 42)
    #expect(storedValues["\(prefix)aString"] as? String == "hello world")
    #expect(storedValues["\(prefix)aStringList"] as? [String] == ["hello", "world"])
  }

  @Test(arguments: ["aPrefix", ""])
  func getWithAllowList(prefix: String) throws {
    let plugin = LegacySharedPreferencesPlugin()

    plugin.setBool(key: "\(prefix)aBool", value: true)
    plugin.setDouble(key: "\(prefix)aDouble", value: 3.14)
    plugin.setValue(key: "\(prefix)anInt", value: 42)
    plugin.setValue(key: "\(prefix)aString", value: "hello world")
    plugin.setValue(key: "\(prefix)aStringList", value: ["hello", "world"])

    let storedValues = plugin.getAll(prefix: prefix, allowList: ["\(prefix)aBool"])
    #expect(storedValues["\(prefix)aBool"] as? Bool == true)
    #expect(storedValues["\(prefix)aDouble"] == nil)
    #expect(storedValues["\(prefix)anInt"] == nil)
    #expect(storedValues["\(prefix)aString"] == nil)
    #expect(storedValues["\(prefix)aStringList"] == nil)
  }

  @Test(arguments: ["aPrefix", ""])
  func remove(prefix: String) throws {
    let plugin = LegacySharedPreferencesPlugin()
    let key = "\(prefix)\(testKey)"
    plugin.setValue(key: key, value: 42)

    // Make sure there is something to remove, so the test can't pass due to a set failure.
    let preRemovalValues = plugin.getAll(prefix: prefix, allowList: nil)
    #expect(preRemovalValues[key] as? Int == 42)

    // Then verify that removing it works.
    plugin.remove(key: key)

    let finalValues = plugin.getAll(prefix: prefix, allowList: nil)
    #expect(finalValues[key] == nil)
  }

  @Test(arguments: ["aPrefix", ""])
  func clearWithNoAllowlist(prefix: String) throws {
    let plugin = LegacySharedPreferencesPlugin()
    let key = "\(prefix)\(testKey)"
    plugin.setValue(key: key, value: 42)

    // Make sure there is something to clear, so the test can't pass due to a set failure.
    let preRemovalValues = plugin.getAll(prefix: prefix, allowList: nil)
    #expect(preRemovalValues[key] as? Int == 42)

    // Then verify that clearing works.
    #expect(plugin.clear(prefix: prefix, allowList: nil) == true)

    let finalValues = plugin.getAll(prefix: prefix, allowList: nil)
    #expect(finalValues[key] == nil)
  }

  @Test(arguments: ["aPrefix", ""])
  func clearWithAllowlist(prefix: String) throws {
    let plugin = LegacySharedPreferencesPlugin()
    let key = "\(prefix)\(testKey)"
    plugin.setValue(key: key, value: 42)

    // Make sure there is something to clear, so the test can't pass due to a set failure.
    let preRemovalValues = plugin.getAll(prefix: prefix, allowList: nil)
    #expect(preRemovalValues[key] as? Int == 42)

    #expect(plugin.clear(prefix: prefix, allowList: ["\(prefix)\(testKeyTwo)"]) == true)

    let finalValues = plugin.getAll(prefix: prefix, allowList: nil)
    #expect(finalValues[key] as? Int == 42)
  }

  // Async system tests.

  let emptyOptions = SharedPreferencesPigeonOptions()
  let optionsWithSuiteName = SharedPreferencesPigeonOptions(
    suiteName: "group.example.sharedPreferencesFoundationExample")

  @Test func asyncSetAndGet() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aBool", value: true, options: emptyOptions)
    try plugin.set(key: "aDouble", value: 3.14, options: emptyOptions)
    try plugin.set(key: "anInt", value: 42, options: emptyOptions)
    try plugin.set(key: "aString", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aStringList", value: ["hello", "world"], options: emptyOptions)

    #expect((try plugin.getValue(key: "aBool", options: emptyOptions)) != nil)
    let doubleVal = try #require(plugin.getValue(key: "aDouble", options: emptyOptions) as? Double)
    #expect(abs(doubleVal - 3.14) < 0.0001)

    #expect(try plugin.getValue(key: "anInt", options: emptyOptions) as? Int == 42)
    #expect(try plugin.getValue(key: "aString", options: emptyOptions) as? String == "hello world")
    #expect(
      try plugin.getValue(key: "aStringList", options: emptyOptions) as? [String] == [
        "hello", "world",
      ])
  }

  @Test func asyncGetAll() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aBool", value: true, options: emptyOptions)
    try plugin.set(key: "aDouble", value: 3.14, options: emptyOptions)
    try plugin.set(key: "anInt", value: 42, options: emptyOptions)
    try plugin.set(key: "aString", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aStringList", value: ["hello", "world"], options: emptyOptions)

    let storedValues = try plugin.getAll(allowList: nil, options: emptyOptions)
    #expect(storedValues["aBool"] as? Bool == true)

    let doubleVal = try #require(storedValues["aDouble"] as? Double)
    #expect(abs(doubleVal - 3.14) < 0.0001)

    #expect(storedValues["anInt"] as? Int == 42)
    #expect(storedValues["aString"] as? String == "hello world")
    #expect(storedValues["aStringList"] as? [String] == ["hello", "world"])
  }

  @Test func asyncGetAllWithAndWithoutSuiteName() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aKey", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aKeySuite", value: "hello world with suite", options: optionsWithSuiteName)

    let storedValues = try plugin.getAll(allowList: nil, options: emptyOptions)
    #expect(storedValues["aKey"] as? String == "hello world")

    let storedValuesWithGroup = try plugin.getAll(allowList: nil, options: optionsWithSuiteName)
    #expect(storedValuesWithGroup["aKeySuite"] as? String == "hello world with suite")
  }

  @Test func asyncGetAllWithAllowList() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: "aBool", value: true, options: emptyOptions)
    try plugin.set(key: "aDouble", value: 3.14, options: emptyOptions)
    try plugin.set(key: "anInt", value: 42, options: emptyOptions)
    try plugin.set(key: "aString", value: "hello world", options: emptyOptions)
    try plugin.set(key: "aStringList", value: ["hello", "world"], options: emptyOptions)

    let storedValues = try plugin.getAll(allowList: ["aBool"], options: emptyOptions)
    #expect(storedValues["aBool"] as? Bool == true)
    #expect(storedValues["aDouble"] == nil)
    #expect(storedValues["anInt"] == nil)
    #expect(storedValues["aString"] == nil)
    #expect(storedValues["aStringList"] == nil)
  }

  @Test func asyncRemove() throws {
    let plugin = SharedPreferencesPlugin()
    try plugin.set(key: testKey, value: testValue, options: emptyOptions)

    // Make sure there is something to remove, so the test can't pass due to a set failure.
    let preRemovalValue = try plugin.getValue(key: testKey, options: emptyOptions) as? String
    #expect(preRemovalValue == testValue)

    // Then verify that removing it works.
    try plugin.remove(key: testKey, options: emptyOptions)

    let finalValue = try plugin.getValue(key: testKey, options: emptyOptions)
    #expect(finalValue == nil)
  }

  @Test func asyncClearWithNoAllowlist() throws {
    let plugin = SharedPreferencesPlugin()
    try plugin.set(key: testKey, value: testValue, options: emptyOptions)

    // Make sure there is something to remove, so the test can't pass due to a set failure.
    let preRemovalValue = try plugin.getValue(key: testKey, options: emptyOptions) as? String
    #expect(preRemovalValue == testValue)

    // Then verify that clearing works.
    try plugin.clear(allowList: nil, options: emptyOptions)

    let finalValue = try plugin.getValue(key: testKey, options: emptyOptions)
    #expect(finalValue == nil)
  }

  @Test func asyncClearWithAllowlist() throws {
    let plugin = SharedPreferencesPlugin()

    try plugin.set(key: testKey, value: testValue, options: emptyOptions)
    try plugin.set(key: testKeyTwo, value: testValue, options: emptyOptions)

    // Make sure there is something to clear, so the test can't pass due to a set failure.
    let preRemovalValue = try plugin.getValue(key: testKey, options: emptyOptions) as? String
    #expect(preRemovalValue == testValue)

    try plugin.clear(allowList: [testKey], options: emptyOptions)

    let finalValueNil = try plugin.getValue(key: testKey, options: emptyOptions)
    #expect(finalValueNil == nil)
    let finalValueNotNil = try plugin.getValue(key: testKeyTwo, options: emptyOptions) as? String
    #expect(finalValueNotNil == testValue)
  }

  @Test func detachingSecondaryEnginePreservesPrimaryRegistrations() throws {
    let registrar1 = StubPluginRegistrar(engineIdentifier: 1 << 40)
    let registrar2 = StubPluginRegistrar(engineIdentifier: (1 << 40) + 1)
    SharedPreferencesPlugin.register(with: registrar1)
    let primaryUserDefaults = UserDefaultsApiSetup.pigeonResolveInstance(
      engineId: Int64.min, affinityKey: Int64.min)
    let primaryLegacy = LegacyUserDefaultsApiSetup.pigeonResolveInstance(
      engineId: Int64.min, affinityKey: Int64.min)
    #expect(primaryUserDefaults != nil)
    #expect(primaryLegacy != nil)

    SharedPreferencesPlugin.register(with: registrar2)
    #expect(
      UserDefaultsApiSetup.pigeonResolveInstance(engineId: Int64.min, affinityKey: Int64.min)
        !== primaryUserDefaults)
    #expect(
      LegacyUserDefaultsApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
        !== primaryLegacy)

    let secondaryPlugin = try #require(
      registrar2.valuePublished(byPlugin: "SharedPreferencesPlugin") as? SharedPreferencesPlugin)
    secondaryPlugin.detachFromEngine(for: registrar2)

    #expect(
      UserDefaultsApiSetup.pigeonResolveInstance(engineId: Int64.min, affinityKey: Int64.min)
        === primaryUserDefaults)
    #expect(
      LegacyUserDefaultsApiSetup.pigeonResolveInstance(
        engineId: Int64.min, affinityKey: Int64.min)
        === primaryLegacy)

    let primaryPlugin = try #require(
      registrar1.valuePublished(byPlugin: "SharedPreferencesPlugin") as? SharedPreferencesPlugin)
    primaryPlugin.detachFromEngine(for: registrar1)
  }
}

private final class StubBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(
    onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {}
  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection { 0 }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

private final class StubTextureRegistry: NSObject, FlutterTextureRegistry {
  func register(_ texture: FlutterTexture) -> Int64 { 0 }
  func textureFrameAvailable(_ textureId: Int64) {}
  func unregisterTexture(_ textureId: Int64) {}
}

private final class StubPluginRegistrar: NSObject, FlutterPluginRegistrar {
  let stubMessenger: FlutterBinaryMessenger = StubBinaryMessenger()
  let stubTextures: FlutterTextureRegistry = StubTextureRegistry()
  @objc var engineIdentifier: Int64
  var published: NSObject?

  init(engineIdentifier: Int64) {
    self.engineIdentifier = engineIdentifier
    super.init()
  }

  func publish(_ value: NSObject) { published = value }
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}
  func lookupKey(forAsset asset: String) -> String { asset }
  func lookupKey(forAsset asset: String, fromPackage package: String) -> String { asset }
  func valuePublished(byPlugin pluginKey: String) -> NSObject? { published }
  func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String) {}

  #if os(iOS)
    var viewController: UIViewController? { nil }
    func messenger() -> FlutterBinaryMessenger { stubMessenger }
    func textures() -> FlutterTextureRegistry { stubTextures }
    func addApplicationDelegate(_ delegate: FlutterPlugin) {}
    func addSceneDelegate(_ delegate: FlutterSceneLifeCycleDelegate) {}
    func register(
      _ factory: FlutterPlatformViewFactory, withId factoryId: String,
      gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy
    ) {}
  #elseif os(macOS)
    var messenger: FlutterBinaryMessenger { stubMessenger }
    var textures: FlutterTextureRegistry { stubTextures }
    var view: NSView? { nil }
    var viewController: NSViewController? { nil }
    func addApplicationDelegate(_ delegate: FlutterAppLifecycleDelegate) {}
  #endif
}
