// Copyright 2013 The Flutter Authors. All rights reserved.
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
  func lookupKeyForAsset(_ asset: String) -> String {
    return FlutterDartProject.lookupKey(forAsset: asset)
  }
}
