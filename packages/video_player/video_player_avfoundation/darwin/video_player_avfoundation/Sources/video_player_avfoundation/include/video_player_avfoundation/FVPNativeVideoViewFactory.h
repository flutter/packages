// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Platform views are only supported on iOS as of now. Ifdef is used to avoid compilation errors.

#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import "FVPVideoPlayer.h"

/// A factory class responsible for creating native video views that can be embedded in a
/// Flutter app.
@interface FVPNativeVideoViewFactory : NSObject <FlutterPlatformViewFactory>
/// Initializes a new instance of FVPNativeVideoViewFactory with the given messenger and
/// a block that provides video players associated with their IDs.
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
               playerByIdProvider:(FVPVideoPlayer * (^)(NSNumber *))playerByIdProvider;
@end
