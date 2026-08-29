// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/// Protocol for looking up Flutter assets and resolving them to images.
///
/// This is used to allow testing with mock assets without mocking the entire
/// Flutter plugin registrar and UIImage class.
@protocol FGMAssetProvider <NSObject>

/// Returns the key for the given asset.
///
/// Wraps the FlutterPluginRegistrar method of the same name.
///
/// @param asset The name of the asset.
/// @return The key for the asset, or nil if not found.
- (nullable NSString *)lookupKeyForAsset:(NSString *)asset;

/// Returns the key for the given asset from the given package.
///
/// Wraps the FlutterPluginRegistrar method of the same name.
///
/// @param asset The name of the asset.
/// @param package The name of the package to load the asset from.
/// @return The key for the asset, or nil if not found.
- (nullable NSString *)lookupKeyForAsset:(NSString *)asset fromPackage:(NSString *)package;

/// Returns the image for the given named asset.
///
/// Wraps the UIImage method of the same name.
///
/// @param name The name of the image asset or file.
/// @return The image, or nil if not found.
- (nullable UIImage *)imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
