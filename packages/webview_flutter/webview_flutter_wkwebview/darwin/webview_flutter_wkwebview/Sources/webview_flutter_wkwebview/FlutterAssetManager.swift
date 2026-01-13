// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

open class FlutterAssetManager {
  let bundle: Bundle

  init(bundle: Bundle = Bundle.main) {
    self.bundle = bundle
  }

  func lookupKeyForAsset(_ asset: String) -> String? {
    return FlutterDartProject.lookupKey(forAsset: asset)
  }

  func urlForAsset(_ asset: String) -> URL? {
    let assetFilePath: String? = lookupKeyForAsset(asset)

    guard let assetFilePath = assetFilePath else {
      return nil
    }

    var url: URL? = bundle.url(
      forResource: (assetFilePath as NSString).deletingPathExtension,
      withExtension: (assetFilePath as NSString).pathExtension)

    #if os(macOS)
      // See https://github.com/flutter/flutter/issues/135302
      // TODO(stuartmorgan): Remove this if the asset APIs are adjusted to work better for macOS.
      if url == nil {
        url = URL(string: assetFilePath, relativeTo: bundle.bundleURL)
      }
    #endif

    return url
  }
}
