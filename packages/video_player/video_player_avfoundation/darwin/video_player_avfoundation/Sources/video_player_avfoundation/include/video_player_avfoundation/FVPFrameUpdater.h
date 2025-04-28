// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPDisplayLink.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// FVPFrameUpdater is responsible for notifying the Flutter texture registry
/// when a new video frame is available.
@interface FVPFrameUpdater : NSObject
/// The texture identifier associated with the video output.
@property(nonatomic) int64_t textureIdentifier;
/// The Flutter texture registry used to notify about new frames.
@property(nonatomic, weak, readonly) NSObject<FlutterTextureRegistry> *registry;
/// The display link that drives frameUpdater.
@property(nonatomic) FVPDisplayLink *displayLink;
/// The time interval between screen refresh updates. Display link duration is in an undefined state
/// until displayLinkFired is called at least once so it should not be used directly.
@property(atomic) CFTimeInterval frameDuration;

/// Initializes a new instance of FVPFrameUpdater with the given Flutter texture registry.
- (FVPFrameUpdater *)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry;

/// Called when the display link fires. Checks if a new frame is available
/// and notifies the Flutter texture registry if a new frame is found.
- (void)displayLinkFired;
@end

NS_ASSUME_NONNULL_END
