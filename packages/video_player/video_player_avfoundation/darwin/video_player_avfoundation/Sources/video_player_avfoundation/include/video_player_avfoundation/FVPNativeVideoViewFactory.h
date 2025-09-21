// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "FVPVideoPlayer.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

/// A factory class responsible for creating native video views that can be embedded in a
/// Flutter app.
@interface FVPNativeVideoViewFactory : NSObject <FlutterPlatformViewFactory>
/// Initializes a new instance of FVPNativeVideoViewFactory with the given messenger and
/// a block that provides video players associated with their identifiers.
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
       playerByIdentifierProvider:(FVPVideoPlayer * (^)(NSNumber *))playerByIdentifierProvider;
@end
