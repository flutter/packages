// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoView.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@implementation FVPNativeVideoView

- (instancetype)initWithPlayer:(AVPlayer *)player {
  self = [super init];
  if (self) {
    self.wantsLayer = YES;
    ((AVPlayerLayer *)self.layer).player = player;
  }
  return self;
}

- (CALayer *)makeBackingLayer {
  return [[AVPlayerLayer alloc] init];
}

@end
