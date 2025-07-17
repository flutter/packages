// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Creates a UIImage from Pigeon bitmap.
UIImage *_Nullable FGMIconFromBitmap(FGMPlatformBitmap *platformBitmap,
                                     NSObject<FlutterPluginRegistrar> *registrar,
                                     CGFloat screenScale);
/// Returns a BOOL indicating whether image is considered scalable with the given scale factor from
/// size.
BOOL FGMIsScalableWithScaleFactorFromSize(CGSize originalSize, CGSize targetSize);

NS_ASSUME_NONNULL_END
