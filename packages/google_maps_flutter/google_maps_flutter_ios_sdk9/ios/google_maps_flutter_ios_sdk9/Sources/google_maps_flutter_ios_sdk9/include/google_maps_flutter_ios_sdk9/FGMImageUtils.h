// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import GoogleMaps;

#import "google_maps_flutter_pigeon_messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Creates a UIImage from Pigeon bitmap.
UIImage *_Nullable FGMIconFromBitmap(FGMPlatformBitmap *platformBitmap,
                                     NSObject<FlutterPluginRegistrar> *registrar,
                                     CGFloat screenScale);
/// Returns a BOOL indicating whether image is considered scalable with the given scale factor from
/// size.
BOOL FGMIsScalableWithScaleFactorFromSize(CGSize originalSize, CGSize targetSize);

NS_ASSUME_NONNULL_END
