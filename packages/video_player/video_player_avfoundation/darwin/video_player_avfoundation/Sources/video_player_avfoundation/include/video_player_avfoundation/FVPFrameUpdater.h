// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <AVFoundation/AVFoundation.h>

@interface FVPFrameUpdater : NSObject
@property(nonatomic) int64_t textureId;
@property(nonatomic, weak, readonly) NSObject<FlutterTextureRegistry> *registry;
// The output that this updater is managing.
@property(nonatomic, weak) AVPlayerItemVideoOutput *videoOutput;
// The last time that has been validated as avaliable according to hasNewPixelBufferForItemTime:.
@property(nonatomic, assign) CMTime lastKnownAvailableTime;

- (FVPFrameUpdater *)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry;

- (void)displayLinkFired;
@end