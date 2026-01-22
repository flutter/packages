// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import google_maps_flutter_ios;

/// Fake implementation of FGMAssetProvider.
@interface TestAssetProvider : NSObject <FGMAssetProvider>
/// Initializes an instance that returns the given key for the given asset name, and nil for any
/// other name.
- (instancetype)initWithKey:(NSString *)key forAssetName:(NSString *)assetName;
@end
