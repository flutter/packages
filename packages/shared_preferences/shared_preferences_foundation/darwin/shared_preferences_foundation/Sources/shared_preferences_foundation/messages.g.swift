// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v16.0.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let flutterError = error as? FlutterError {
    return [
      flutterError.code,
      flutterError.message,
      flutterError.details,
    ]
  }
  return [
    "\(error)",
    "\(type(of: error))",
    "Stacktrace: \(Thread.callStackSymbols)",
  ]
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

/// Generated class from Pigeon that represents data sent in messages.
struct SharedPreferencesPigeonOptions {
  var suiteName: String? = nil

  static func fromList(_ list: [Any?]) -> SharedPreferencesPigeonOptions? {
    let suiteName: String? = nilOrValue(list[0])

    return SharedPreferencesPigeonOptions(
      suiteName: suiteName
    )
  }
  func toList() -> [Any?] {
    return [
      suiteName
    ]
  }
}
private class LegacyUserDefaultsApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 128:
      return SharedPreferencesPigeonOptions.fromList(self.readValue() as! [Any?])
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class LegacyUserDefaultsApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? SharedPreferencesPigeonOptions {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class LegacyUserDefaultsApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return LegacyUserDefaultsApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return LegacyUserDefaultsApiCodecWriter(data: data)
  }
}

class LegacyUserDefaultsApiCodec: FlutterStandardMessageCodec {
  static let shared = LegacyUserDefaultsApiCodec(
    readerWriter: LegacyUserDefaultsApiCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol LegacyUserDefaultsApi {
  func remove(key: String) throws
  func setBool(key: String, value: Bool) throws
  func setDouble(key: String, value: Double) throws
  func setValue(key: String, value: Any) throws
  func getAll(prefix: String, allowList: [String]?) throws -> [String?: Any?]
  func clear(prefix: String, allowList: [String]?) throws -> Bool
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class LegacyUserDefaultsApiSetup {
  /// The codec used by LegacyUserDefaultsApi.
  static var codec: FlutterStandardMessageCodec { LegacyUserDefaultsApiCodec.shared }
  /// Sets up an instance of `LegacyUserDefaultsApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: LegacyUserDefaultsApi?) {
    let removeChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.remove",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      removeChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let keyArg = args[0] as! String
        do {
          try api.remove(key: keyArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      removeChannel.setMessageHandler(nil)
    }
    let setBoolChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.setBool",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      setBoolChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let keyArg = args[0] as! String
        let valueArg = args[1] as! Bool
        do {
          try api.setBool(key: keyArg, value: valueArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      setBoolChannel.setMessageHandler(nil)
    }
    let setDoubleChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.setDouble",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      setDoubleChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let keyArg = args[0] as! String
        let valueArg = args[1] as! Double
        do {
          try api.setDouble(key: keyArg, value: valueArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      setDoubleChannel.setMessageHandler(nil)
    }
    let setValueChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.setValue",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      setValueChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let keyArg = args[0] as! String
        let valueArg = args[1]!
        do {
          try api.setValue(key: keyArg, value: valueArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      setValueChannel.setMessageHandler(nil)
    }
    let getAllChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.getAll",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      getAllChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let prefixArg = args[0] as! String
        let allowListArg: [String]? = nilOrValue(args[1])
        do {
          let result = try api.getAll(prefix: prefixArg, allowList: allowListArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      getAllChannel.setMessageHandler(nil)
    }
    let clearChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.LegacyUserDefaultsApi.clear",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      clearChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let prefixArg = args[0] as! String
        let allowListArg: [String]? = nilOrValue(args[1])
        do {
          let result = try api.clear(prefix: prefixArg, allowList: allowListArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      clearChannel.setMessageHandler(nil)
    }
  }
}
private class UserDefaultsApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 128:
      return SharedPreferencesPigeonOptions.fromList(self.readValue() as! [Any?])
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class UserDefaultsApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? SharedPreferencesPigeonOptions {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class UserDefaultsApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return UserDefaultsApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return UserDefaultsApiCodecWriter(data: data)
  }
}

class UserDefaultsApiCodec: FlutterStandardMessageCodec {
  static let shared = UserDefaultsApiCodec(readerWriter: UserDefaultsApiCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol UserDefaultsApi {
  /// Adds property to shared preferences data set of type String.
  func set(key: String, value: Any, options: SharedPreferencesPigeonOptions) throws
  /// Removes all properties from shared preferences data set with matching prefix.
  func clear(allowList: [String]?, options: SharedPreferencesPigeonOptions) throws
  /// Gets all properties from shared preferences data set with matching prefix.
  func getAll(allowList: [String]?, options: SharedPreferencesPigeonOptions) throws -> [String: Any]
  /// Gets individual value stored with [key], if any.
  func getValue(key: String, options: SharedPreferencesPigeonOptions) throws -> Any?
  /// Gets all properties from shared preferences data set with matching prefix.
  func getKeys(allowList: [String]?, options: SharedPreferencesPigeonOptions) throws -> [String]
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class UserDefaultsApiSetup {
  /// The codec used by UserDefaultsApi.
  static var codec: FlutterStandardMessageCodec { UserDefaultsApiCodec.shared }
  /// Sets up an instance of `UserDefaultsApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: UserDefaultsApi?) {
    /// Adds property to shared preferences data set of type String.
    let setChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.UserDefaultsApi.set",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      setChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let keyArg = args[0] as! String
        let valueArg = args[1]!
        let optionsArg = args[2] as! SharedPreferencesPigeonOptions
        do {
          try api.set(key: keyArg, value: valueArg, options: optionsArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      setChannel.setMessageHandler(nil)
    }
    /// Removes all properties from shared preferences data set with matching prefix.
    let clearChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.UserDefaultsApi.clear",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      clearChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let allowListArg: [String]? = nilOrValue(args[0])
        let optionsArg = args[1] as! SharedPreferencesPigeonOptions
        do {
          try api.clear(allowList: allowListArg, options: optionsArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      clearChannel.setMessageHandler(nil)
    }
    /// Gets all properties from shared preferences data set with matching prefix.
    let getAllChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.UserDefaultsApi.getAll",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      getAllChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let allowListArg: [String]? = nilOrValue(args[0])
        let optionsArg = args[1] as! SharedPreferencesPigeonOptions
        do {
          let result = try api.getAll(allowList: allowListArg, options: optionsArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      getAllChannel.setMessageHandler(nil)
    }
    /// Gets individual value stored with [key], if any.
    let getValueChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.UserDefaultsApi.getValue",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      getValueChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let keyArg = args[0] as! String
        let optionsArg = args[1] as! SharedPreferencesPigeonOptions
        do {
          let result = try api.getValue(key: keyArg, options: optionsArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      getValueChannel.setMessageHandler(nil)
    }
    /// Gets all properties from shared preferences data set with matching prefix.
    let getKeysChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.shared_preferences_foundation.UserDefaultsApi.getKeys",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      getKeysChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let allowListArg: [String]? = nilOrValue(args[0])
        let optionsArg = args[1] as! SharedPreferencesPigeonOptions
        do {
          let result = try api.getKeys(allowList: allowListArg, options: optionsArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      getKeysChannel.setMessageHandler(nil)
    }
  }
}
