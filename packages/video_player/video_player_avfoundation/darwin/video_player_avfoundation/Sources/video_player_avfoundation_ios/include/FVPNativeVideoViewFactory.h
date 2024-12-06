// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "FVPVideoPlayer.h"

/// A factory class responsible for creating native video views that can be embedded in a
/// Flutter app.
@interface FVPNativeVideoViewFactory : NSObject <FlutterPlatformViewFactory>
/// Initializes a new instance of FVPNativeVideoViewFactory with the given messenger and
/// playersById dictionary which stores the video players associated with their IDs.
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                      playersById:(NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *)playersById;
@end
