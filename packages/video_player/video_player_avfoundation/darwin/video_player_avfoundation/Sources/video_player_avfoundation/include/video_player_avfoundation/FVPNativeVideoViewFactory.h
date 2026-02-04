// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

#import "FVPVideoPlayer.h"

#if TARGET_OS_OSX
@import FlutterMacOS;
#else
@import Flutter;
#endif

/// A factory class responsible for creating native video views that can be embedded in a
/// Flutter app.
@interface FVPNativeVideoViewFactory : NSObject <FlutterPlatformViewFactory>
/// Initializes a new instance of FVPNativeVideoViewFactory with the given messenger and
/// a block that provides video players associated with their identifiers.
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
       playerByIdentifierProvider:(FVPVideoPlayer * (^)(NSNumber *))playerByIdentifierProvider;
@end
