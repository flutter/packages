// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

let argumentError: String = "Argument Error"

public class LegacySharedPreferencesPlugin: NSObject, FlutterPlugin, LegacyUserDefaultsApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LegacySharedPreferencesPlugin()
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    LegacyUserDefaultsApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  func getAll(prefix: String, allowList: [String]?) -> [String: Any] {
    return getAllPrefs(prefix: prefix, allowList: allowList)
  }

  func setBool(key: String, value: Bool) {
    UserDefaults.standard.set(value, forKey: key)
  }

  func setDouble(key: String, value: Double) {
    UserDefaults.standard.set(value, forKey: key)
  }

  func setValue(key: String, value: Any) {
    UserDefaults.standard.set(value, forKey: key)
  }

  func remove(key: String) {
    UserDefaults.standard.removeObject(forKey: key)
  }

  func clear(prefix: String, allowList: [String]?) -> Bool {
    let defaults = UserDefaults.standard
    for (key, _) in getAllPrefs(prefix: prefix, allowList: allowList) {
      defaults.removeObject(forKey: key)
    }
    return true
  }

  /// Returns all preferences stored with specified prefix.
  /// If [allowList] is included, only items included will be returned.
  func getAllPrefs(prefix: String, allowList: [String]?) -> [String: Any] {
    var filteredPrefs: [String: Any] = [:]

    let prefs = try! SharedPreferencesPlugin.getAllPrefs(
      allowList: allowList, options: SharedPreferencesPigeonOptions())

    for (key, value) in prefs where (key.hasPrefix(prefix)) {
      filteredPrefs[key] = value
    }

    return filteredPrefs
  }

}

public class SharedPreferencesPlugin: NSObject, FlutterPlugin, UserDefaultsApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SharedPreferencesPlugin()
    // Workaround for https://github.com/flutter/flutter/issues/118103.
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    UserDefaultsApiSetup.setUp(binaryMessenger: messenger, api: instance)
    LegacySharedPreferencesPlugin.register(with: registrar)
  }

  static private func getUserDefaults(options: SharedPreferencesPigeonOptions) throws
    -> UserDefaults
  {
    #if os(iOS)
      if !(options.suiteName?.starts(with: "group.") ?? true) {
        throw FlutterError(
          code: argumentError,
          message:
            "The provided Suite Name '\(options.suiteName!)' does not follow the predefined requirements",
          details: "") as! Error
      }
    #endif
    let prefs = UserDefaults(suiteName: options.suiteName)

    if prefs == nil {
      throw FlutterError(
        code: argumentError,
        message: "The provided Suite Name '\(options.suiteName!)' does not exist",
        details: "") as! Error
    }
    return prefs!
  }

  func getKeys(allowList: [String]?, options: SharedPreferencesPigeonOptions) throws -> [String] {
    return Array(try getAll(allowList: allowList, options: options).keys)
  }

  func getAll(allowList: [String]?, options: SharedPreferencesPigeonOptions) throws -> [String: Any]
  {
    return try SharedPreferencesPlugin.getAllPrefs(allowList: allowList, options: options)
  }

  func set(key: String, value: Any, options: SharedPreferencesPigeonOptions) throws {
    try SharedPreferencesPlugin.getUserDefaults(options: options).set(value, forKey: key)
  }

  func getValue(key: String, options: SharedPreferencesPigeonOptions) throws -> Any? {
    let preference = try SharedPreferencesPlugin.getUserDefaults(options: options).object(
      forKey: key)
    return SharedPreferencesPlugin.isTypeCompatible(value: preference as Any) ? preference : nil
  }

  func remove(key: String, options: SharedPreferencesPigeonOptions) throws {
    try SharedPreferencesPlugin.getUserDefaults(options: options).removeObject(forKey: key)
  }

  func clear(allowList: [String]?, options: SharedPreferencesPigeonOptions) throws {
    let defaults = try SharedPreferencesPlugin.getUserDefaults(options: options)
    if let allowList = allowList {
      for (key) in allowList {
        defaults.removeObject(forKey: key)
      }
    } else {
      for key in defaults.dictionaryRepresentation().keys {
        defaults.removeObject(forKey: key)
      }
    }
  }

  /// Returns all preferences stored with specified prefix.
  /// If [allowList] is included, only items included will be returned.
  /// If no [allowList], returns supported types only.
  static func getAllPrefs(allowList: [String]?, options: SharedPreferencesPigeonOptions) throws
    -> [String: Any]
  {
    var filteredPrefs: [String: Any] = [:]
    var compatiblePrefs: [String: Any] = [:]
    let allowSet = allowList.map { Set($0) }

    // Since `getUserDefaults` is initialized with the suite name, it seems redundant to call
    // `persistentDomain` with the suite name again. However, it is necessary because
    // `dictionaryRepresentation` returns keys from the global domain.
    // Also, Apple's docs on `persistentDomain` are incorrect,
    // see: https://github.com/feedback-assistant/reports/issues/165
    if let appDomain = options.suiteName ?? Bundle.main.bundleIdentifier,
      let prefs = try getUserDefaults(options: options).persistentDomain(forName: appDomain)
    {
      if let allowSet = allowSet {
        filteredPrefs = prefs.filter { allowSet.contains($0.key) }
      } else {
        filteredPrefs = prefs
      }
      compatiblePrefs = filteredPrefs.filter { isTypeCompatible(value: $0.value) }
    }
    return compatiblePrefs
  }

  static func isTypeCompatible(value: Any) -> Bool {
    switch value {
    case is Bool:
      return true
    case is Double:
      return true
    case is String:
      return true
    case is Int:
      return true
    case is [Any]:
      if let value = value as? [Any] {
        return value.allSatisfy(isTypeCompatible)
      }
    default:
      return false
    }
    return false
  }

}
