// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.6.4), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Error class for passing custom error details to Dart side.
final class PigeonError: Error {
  let code: String
  let message: String?
  let details: Any?

  init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  var localizedDescription: String {
    return
      "PigeonError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>")"
  }
}

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let pigeonError = error as? PigeonError {
    return [
      pigeonError.code,
      pigeonError.message,
      pigeonError.details,
    ]
  }
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

enum DirectoryType: Int {
  case applicationDocuments = 0
  case applicationSupport = 1
  case downloads = 2
  case library = 3
  case temp = 4
  case applicationCache = 5
}

private class messagesPigeonCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 129:
      let enumResultAsInt: Int? = nilOrValue(self.readValue() as! Int?)
      if let enumResultAsInt = enumResultAsInt {
        return DirectoryType(rawValue: enumResultAsInt)
      }
      return nil
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class messagesPigeonCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? DirectoryType {
      super.writeByte(129)
      super.writeValue(value.rawValue)
    } else {
      super.writeValue(value)
    }
  }
}

private class messagesPigeonCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return messagesPigeonCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return messagesPigeonCodecWriter(data: data)
  }
}

class messagesPigeonCodec: FlutterStandardMessageCodec, @unchecked Sendable {
  static let shared = messagesPigeonCodec(readerWriter: messagesPigeonCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol PathProviderApi {
  func getDirectoryPath(type: DirectoryType) throws -> String?
  func getContainerPath(appGroupIdentifier: String) throws -> String?
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class PathProviderApiSetup {
  static var codec: FlutterStandardMessageCodec { messagesPigeonCodec.shared }
  /// Sets up an instance of `PathProviderApi` to handle messages through the `binaryMessenger`.
  static func setUp(
    binaryMessenger: FlutterBinaryMessenger, api: PathProviderApi?,
    messageChannelSuffix: String = ""
  ) {
    let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
    let getDirectoryPathChannel = FlutterBasicMessageChannel(
      name:
        "dev.flutter.pigeon.path_provider_foundation.PathProviderApi.getDirectoryPath\(channelSuffix)",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      getDirectoryPathChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let typeArg = args[0] as! DirectoryType
        do {
          let result = try api.getDirectoryPath(type: typeArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      getDirectoryPathChannel.setMessageHandler(nil)
    }
    let getContainerPathChannel = FlutterBasicMessageChannel(
      name:
        "dev.flutter.pigeon.path_provider_foundation.PathProviderApi.getContainerPath\(channelSuffix)",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      getContainerPathChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let appGroupIdentifierArg = args[0] as! String
        do {
          let result = try api.getContainerPath(appGroupIdentifier: appGroupIdentifierArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      getContainerPathChannel.setMessageHandler(nil)
    }
  }
}
