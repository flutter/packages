// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// We only support platform views on iOS as of now. Ifdef is used to avoid compilation errors.

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
/// playersById dictionary which stores the video players associated with their IDs.
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                      playersById:(NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *)playersById;
@end
