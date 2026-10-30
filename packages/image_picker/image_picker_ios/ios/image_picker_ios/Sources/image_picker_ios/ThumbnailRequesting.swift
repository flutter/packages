// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Photos
import UIKit

/// Requests a thumbnail image for a PHAsset.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol ThumbnailRequesting {
  func requestImage(
    for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode,
    options: PHImageRequestOptions?,
    resultHandler: @escaping (UIImage?, [AnyHashable: Any]?) -> Void)
}

/// Production implementation that forwards to PHImageManager.
struct DefaultThumbnailRequester: ThumbnailRequesting {
  func requestImage(
    for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode,
    options: PHImageRequestOptions?,
    resultHandler: @escaping (UIImage?, [AnyHashable: Any]?) -> Void
  ) {
    PHImageManager.default().requestImage(
      for: asset, targetSize: targetSize, contentMode: contentMode, options: options,
      resultHandler: resultHandler)
  }
}
