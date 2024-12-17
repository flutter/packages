// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPFrameUpdater.h"

/// FVPFrameUpdater is responsible for notifying the Flutter texture registry
/// when a new video frame is available.
@interface FVPFrameUpdater ()
/// The Flutter texture registry used to notify about new frames.
@property(nonatomic, weak, readonly) NSObject<FlutterTextureRegistry> *registry;
@end

@implementation FVPFrameUpdater
- (FVPFrameUpdater *)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry {
  NSAssert(self, @"super init cannot be nil");
  if (self == nil) return nil;
  _registry = registry;
  _lastKnownAvailableTime = kCMTimeInvalid;
  return self;
}

- (void)displayLinkFired {
  // Only report a new frame if one is actually available.
  CMTime outputItemTime = [self.videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  if ([self.videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
    _lastKnownAvailableTime = outputItemTime;
    [_registry textureFrameAvailable:_textureId];
  }
}
@end
