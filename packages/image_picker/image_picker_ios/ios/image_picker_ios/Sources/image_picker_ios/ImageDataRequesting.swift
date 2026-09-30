// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import Photos

/// Requests image bytes for a `PHAsset`.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol ImageDataRequesting {
  func requestImageDataAndOrientation(
    for asset: PHAsset,
    options: PHImageRequestOptions?,
    resultHandler:
      @escaping (Data?, String?, CGImagePropertyOrientation, [AnyHashable: Any]?) -> Void
  )
}

/// Production implementation that forwards to `PHImageManager`.
struct DefaultImageDataRequester: ImageDataRequesting {
  func requestImageDataAndOrientation(
    for asset: PHAsset,
    options: PHImageRequestOptions?,
    resultHandler:
      @escaping (Data?, String?, CGImagePropertyOrientation, [AnyHashable: Any]?) -> Void
  ) {
    PHImageManager.default().requestImageDataAndOrientation(
      for: asset, options: options, resultHandler: resultHandler)
  }
}
