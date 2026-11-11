// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Photos

/// Fetches assets from the photo library.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol RecentAssetsFetching {
  func fetchAssets(options: PHFetchOptions) -> [PHAsset]
}

/// Production implementation that forwards to PHAsset.
struct DefaultRecentAssetsFetcher: RecentAssetsFetching {
  func fetchAssets(options: PHFetchOptions) -> [PHAsset] {
    let result = PHAsset.fetchAssets(with: options)
    return result.objects(at: IndexSet(integersIn: 0..<result.count))
  }
}
