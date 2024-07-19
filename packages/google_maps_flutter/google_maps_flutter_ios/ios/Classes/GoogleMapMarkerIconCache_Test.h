// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerIconCache.h"

@interface GoogleMapMarkerIconCache (Test)

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                              screenScale:(CGFloat)screenScale;
- (UIImage*)getImage:(NSArray *)iconData;

/// Extracts an icon image from the iconData array.
///
/// @param iconData An array containing the data for the icon image.
/// @param iconCache An icon cache that stores the UI images that are unique across all markers.
/// @return A UIImage object created from the icon data.
/// @note Assert unless screenScale is greater than 0.
- (UIImage *)extractIconFromData:(NSArray *)iconData;

/// Checks if an image can be scaled from an original size to a target size using a scale factor
/// while maintaining the aspect ratio.
///
/// @param originalSize The original size of the image.
/// @param targetSize The desired target size to scale the image to.
/// @return A BOOL indicating whether the image can be scaled to the target size with scale
/// factor.
+ (BOOL)isScalableWithScaleFactorFromSize:(CGSize)originalSize toSize:(CGSize)targetSize;
@end
