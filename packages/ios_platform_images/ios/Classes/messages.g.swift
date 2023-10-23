// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v11.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

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

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

/// A serialization of a platform image's data.
///
/// Generated class from Pigeon that represents data sent in messages.
struct PlatformImageData {
  /// The image data.
  var data: FlutterStandardTypedData
  /// The image's scale factor.
  var scale: Double

  static func fromList(_ list: [Any?]) -> PlatformImageData? {
    let data = list[0] as! FlutterStandardTypedData
    let scale = list[1] as! Double

    return PlatformImageData(
      data: data,
      scale: scale
    )
  }
  func toList() -> [Any?] {
    return [
      data,
      scale,
    ]
  }
}
private class PlatformImagesApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 128:
      return PlatformImageData.fromList(self.readValue() as! [Any?])
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class PlatformImagesApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? PlatformImageData {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class PlatformImagesApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return PlatformImagesApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return PlatformImagesApiCodecWriter(data: data)
  }
}

class PlatformImagesApiCodec: FlutterStandardMessageCodec {
  static let shared = PlatformImagesApiCodec(readerWriter: PlatformImagesApiCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol PlatformImagesApi {
  /// Returns the URL for the given resource, or null if no such resource is
  /// found.
  func resolveUrl(resourceName: String, extension: String?) throws -> String?
  /// Returns the data for the image resource with the given name, or null if
  /// no such resource is found.
  func loadImage(name: String) throws -> PlatformImageData?
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class PlatformImagesApiSetup {
  /// The codec used by PlatformImagesApi.
  static var codec: FlutterStandardMessageCodec { PlatformImagesApiCodec.shared }
  /// Sets up an instance of `PlatformImagesApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: PlatformImagesApi?) {
    /// Returns the URL for the given resource, or null if no such resource is
    /// found.
    let resolveUrlChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.ios_platform_images.PlatformImagesApi.resolveUrl",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      resolveUrlChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let resourceNameArg = args[0] as! String
        let extensionArg: String? = nilOrValue(args[1])
        do {
          let result = try api.resolveUrl(resourceName: resourceNameArg, extension: extensionArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      resolveUrlChannel.setMessageHandler(nil)
    }
    /// Returns the data for the image resource with the given name, or null if
    /// no such resource is found.
    let loadImageChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.ios_platform_images.PlatformImagesApi.loadImage",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      loadImageChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let nameArg = args[0] as! String
        do {
          let result = try api.loadImage(name: nameArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      loadImageChannel.setMessageHandler(nil)
    }
  }
}
