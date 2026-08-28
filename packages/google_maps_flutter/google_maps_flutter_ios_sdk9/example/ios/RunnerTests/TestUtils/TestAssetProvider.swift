// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import google_maps_flutter_ios_sdk9

/// Fake implementation of FGMAssetProvider for unit tests.
class TestAssetProvider: NSObject, FGMAssetProvider {
  private let image: UIImage?
  private let assetName: String?
  private let package: String?

  private let testAssetKey = "testAssetKey"

  /// Initializes an instance that returns an arbitrary key for the given asset
  /// name, and the given image when using that key for imageNamed:.
  ///
  /// Returns nil for any other names.
  ///
  /// This is useful for setting up tests that need to stub out the standard
  /// flow of name -> key -> image.
  init(image: UIImage, forAssetName assetName: String, package: String?) {
    self.image = image
    self.assetName = assetName
    self.package = package
    super.init()
  }

  override init() {
    self.image = nil
    self.assetName = nil
    self.package = nil
    super.init()
  }

  func lookupKey(forAsset asset: String) -> String? {
    return asset == assetName ? testAssetKey : nil
  }

  func lookupKey(forAsset asset: String, fromPackage package: String) -> String? {
    return asset == assetName && package == self.package ? testAssetKey : nil
  }

  func imageNamed(_ name: String) -> UIImage? {
    return name == testAssetKey ? image : nil
  }
}
