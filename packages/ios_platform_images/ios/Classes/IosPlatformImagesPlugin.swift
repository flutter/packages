// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

public final class IosPlatformImagesPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/ios_platform_images",
      binaryMessenger: registrar.messenger())

    let instance = IosPlatformImagesPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadImage":
      loadImage(call, result)
    case "resolveURL":
      resolveURL(call, result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func loadImage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let name = call.arguments as? String else {
      result(nil)
      return
    }

    guard let image = UIImage(named: name),
      let data = image.pngData()
    else {
      result(nil)
      return
    }

    let imageResult: [String: Any] = [
      "scale": image.scale,
      "data": FlutterStandardTypedData(bytes: data),
    ]

    result(imageResult)
  }

    private func resolveURL(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String?] else {
      return result(nil)
    }

    let name = args[0]
    let extesnsionName = args.count > 1 && args[1] != nil ? args[1] : nil

    guard let url = Bundle.main.url(forResource: name, withExtension: extesnsionName) else {
      return result(nil)
    }
      
    result(url)

  }

}
