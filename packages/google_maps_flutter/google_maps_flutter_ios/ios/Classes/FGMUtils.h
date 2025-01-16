// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

@interface FGMUtils : NSObject
+ (UIImage *)iconFromBitmap:(FGMPlatformBitmap *)platformBitmap
                  registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                screenScale:(CGFloat)screenScale;
+ (BOOL)isScalableWithScaleFactorFromSize:(CGSize)originalSize toSize:(CGSize)targetSize;
@end

NS_ASSUME_NONNULL_END
