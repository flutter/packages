// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

public class IosPlatformImagesPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/ios_platform_images",
      binaryMessenger: registrar.messenger())

    let plugin = IosPlatformImagesPlugin()
    registrar.addMethodCallDelegate(plugin, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadImage":
      handleLoadImage(call, result)
    case "resolveURL":
      handleResolveURL(call, result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleLoadImage(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let name = call.arguments as? String,
      let image = UIImage(named: name),
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

  private func handleResolveURL(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [Any],
      let name = args.first as? String,
      let extensionOrNil = args.dropFirst().first as? String?,
      let url = Bundle.main.url(forResource: name, withExtension: extensionOrNil)
    else {
      result(nil)
      return
    }

    result(url.absoluteString)
  }
}
