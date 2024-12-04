// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/// FVPFrameUpdater is responsible for notifying the Flutter texture registry
/// when a new video frame is available.
@interface FVPFrameUpdater : NSObject
/// The texture ID associated with the video output.
@property(nonatomic) int64_t textureId;
/// The output that this updater is managing.
@property(nonatomic, weak) AVPlayerItemVideoOutput *videoOutput;
/// The last time that has been validated as avaliable according to hasNewPixelBufferForItemTime:.
@property(readonly, nonatomic, assign) CMTime lastKnownAvailableTime;

/// Initializes a new instance of FVPFrameUpdater with the given Flutter texture registry.
- (FVPFrameUpdater *)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry;

/// Called when the display link fires. Checks if a new frame is available
/// and notifies the Flutter texture registry if a new frame is found.
- (void)displayLinkFired;
@end

NS_ASSUME_NONNULL_END
