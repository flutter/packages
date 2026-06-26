// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPFrameUpdater.h"

// If the engine has not pulled a pixel buffer for this many consecutive display link ticks, assume
// the texture is not being composited and stop driving frame updates. At 120 Hz this is ~1s; at
// 60 Hz ~2s — far above the normal one- or two-tick latency between marking a frame available and
// copyPixelBuffer being called, so an onscreen, actively-composited video never reaches it.
static const NSUInteger kFVPMaxUnconsumedFrames = 120;

@implementation FVPFrameUpdater
- (FVPFrameUpdater *)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry {
  NSAssert(self, @"super init cannot be nil");
  if (self == nil) return nil;
  _registry = registry;
  return self;
}

- (void)displayLinkFired {
  // Prefer the asset's content frame interval when known. The CADisplayLink's own duration reports
  // the display's nominal max-rate interval (e.g. 8.3 ms at 120 Hz) even when the link is throttled
  // to the content rate, so using it directly would make copyPixelBuffer's targetTime sampling drift.
  CFTimeInterval contentDuration = self.contentFrameDuration;
  self.frameDuration = contentDuration > 0 ? contentDuration : _displayLink.duration;

  // The display link keeps running as long as the player believes it should (isPlaying ||
  // waitingForFrame), but the player has no signal for whether the texture is actually onscreen. An
  // offscreen player therefore pumps textureFrameAvailable every vsync, forcing a full platform-view
  // recomposite on the raster thread for a texture nobody is displaying. copyPixelBuffer — where the
  // player would otherwise stop the link — is never called while offscreen, so detect the lack of
  // consumption here and stop the link. It is restarted by the player (play/seek/expectFrame) when
  // the texture is needed again.
  if (self.unconsumedFrameCount >= kFVPMaxUnconsumedFrames) {
    _displayLink.running = NO;
    self.unconsumedFrameCount = 0;
    return;
  }
  self.unconsumedFrameCount++;

  [_registry textureFrameAvailable:_textureIdentifier];
}
@end
