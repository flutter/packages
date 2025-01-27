// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

public final class IosPlatformImagesPlugin: NSObject, FlutterPlugin, PlatformImagesApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = IosPlatformImagesPlugin()
    let messenger = registrar.messenger()
    PlatformImagesApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  func loadImage(name: String) -> PlatformImageData? {
    guard let image = UIImage(named: name),
      let data = image.pngData()
    else {
      return nil
    }

    return PlatformImageData(
      data: FlutterStandardTypedData(bytes: data), scale: Double(image.scale))
  }

  func resolveUrl(resourceName: String, extension: String?) throws -> String? {
    guard
      let url = Bundle.main.url(
        forResource: resourceName,
        withExtension: `extension`)
    else {
      return nil
    }

    return url.absoluteString
  }

}
