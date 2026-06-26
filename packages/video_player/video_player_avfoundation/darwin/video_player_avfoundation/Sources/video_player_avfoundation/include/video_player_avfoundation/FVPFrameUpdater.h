// Copyright 2013 The Flutter Authors
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
@property(nonatomic) NSObject<FVPDisplayLink> *displayLink;
/// The time interval between screen refresh updates. Display link duration is in an undefined state
/// until displayLinkFired is called at least once so it should not be used directly.
@property(atomic) CFTimeInterval frameDuration;
/// The interval between video frames at the asset's content rate (1 / nominalFrameRate), or 0 if
/// the content rate is unknown. When set, displayLinkFired uses it as frameDuration instead of the
/// CADisplayLink's duration, which on ProMotion reports the 120 Hz nominal interval even when the
/// link is throttled to the content rate — the mismatch otherwise breaks copyPixelBuffer's sampling.
@property(atomic) CFTimeInterval contentFrameDuration;
/// The number of consecutive display link ticks for which the engine has not pulled a pixel buffer.
/// Reset to 0 by the player whenever copyPixelBuffer is called. When it grows large the texture is
/// not being composited (e.g. the player scrolled offscreen) and displayLinkFired stops the display
/// link so it stops forcing redundant platform-view recomposites on the raster thread.
@property(atomic, assign) NSUInteger unconsumedFrameCount;

/// Initializes a new instance of FVPFrameUpdater with the given Flutter texture registry.
- (FVPFrameUpdater *)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry;

/// Called when the display link fires. Checks if a new frame is available
/// and notifies the Flutter texture registry if a new frame is found.
- (void)displayLinkFired;
@end

NS_ASSUME_NONNULL_END
