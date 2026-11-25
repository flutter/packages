// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Protocol for looking up Flutter assets by name.
///
/// This is used to allow testing with mock assets without mocking the entire
/// Flutter plugin registrar.
protocol AssetProvider {

  /// Returns the key for the given asset.
  ///
  /// Wraps the FlutterPluginRegistrar method of the same name.
  func lookupKey(forAsset asset: String) -> String?

  /// Returns the key for the given asset from the given package.
  ///
  /// Wraps the FlutterPluginRegistrar method of the same name.
  func lookupKey(forAsset asset: String, fromPackage package: String) -> String?
}
