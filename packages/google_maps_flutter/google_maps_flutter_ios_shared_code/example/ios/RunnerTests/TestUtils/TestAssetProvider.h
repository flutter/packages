// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import google_maps_flutter_ios;

NS_ASSUME_NONNULL_BEGIN

/// Fake implementation of FGMAssetProvider for unit tests.
@interface TestAssetProvider : NSObject <FGMAssetProvider>
/// Initializes an instance that returns an arbitrary key for the given asset
/// name, and the given image when when using that key for imageNamed:.
///
/// Returns nil for any other names.
///
/// This is useful for setting up tests that need to stub out the standard
/// flow of name -> key -> image.
- (instancetype)initWithImage:(UIImage *)image
                 forAssetName:(NSString *)assetName
                      package:(nullable NSString *)package;
@end

NS_ASSUME_NONNULL_END
