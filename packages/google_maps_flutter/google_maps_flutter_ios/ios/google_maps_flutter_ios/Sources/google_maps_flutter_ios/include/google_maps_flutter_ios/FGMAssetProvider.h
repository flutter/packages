// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Protocol for looking up Flutter assets.
///
/// This is used to allow testing with mock assets without mocking the entire
/// Flutter plugin registrar.
@protocol FGMAssetProvider <NSObject>

/// Returns the key for the given asset.
///
/// @param asset The name of the asset.
/// @return The key for the asset, or nil if not found.
- (nullable NSString *)lookupKeyForAsset:(NSString *)asset;

/// Returns the key for the given asset from the given package.
///
/// @param asset The name of the asset.
/// @param package The name of the package to load the asset from.
/// @return The key for the asset, or nil if not found.
- (nullable NSString *)lookupKeyForAsset:(NSString *)asset fromPackage:(NSString *)package;

@end

NS_ASSUME_NONNULL_END
