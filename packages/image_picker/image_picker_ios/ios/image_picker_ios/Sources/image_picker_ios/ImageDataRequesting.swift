// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import ImageIO
import Photos

/// Parameters match `PHImageManager.requestImageDataAndOrientation`'s result handler.
typealias ImageDataHandler = (
  _ imageData: Data?,
  _ dataUTI: String?,
  _ orientation: CGImagePropertyOrientation,
  _ info: [AnyHashable: Any]?
) -> Void

/// Requests image bytes for a `PHAsset`.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol ImageDataRequesting {
  func requestImageDataAndOrientation(
    for asset: PHAsset,
    options: PHImageRequestOptions?,
    resultHandler: @escaping ImageDataHandler
  )
}

/// Production implementation that forwards to `PHImageManager`.
struct DefaultImageDataRequester: ImageDataRequesting {
  func requestImageDataAndOrientation(
    for asset: PHAsset,
    options: PHImageRequestOptions?,
    resultHandler: @escaping ImageDataHandler
  ) {
    PHImageManager.default().requestImageDataAndOrientation(
      for: asset, options: options, resultHandler: resultHandler)
  }
}
