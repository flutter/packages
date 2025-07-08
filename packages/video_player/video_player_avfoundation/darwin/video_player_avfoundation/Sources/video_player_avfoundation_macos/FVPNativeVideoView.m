// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoView.h"

#import <AVFoundation/AVFoundation.h>

@interface FVPPlayerView : NSView
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@end

@implementation FVPPlayerView

- (CALayer *)makeBackingLayer {
  return [AVPlayerLayer playerLayerWithPlayer:nil];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  self.wantsLayer = YES;
  return self;
}

- (void)setPlayer:(AVPlayer *)player {
  ((AVPlayerLayer *)self.layer).player = player;
}

@end

@interface FVPNativeVideoView ()
@property(nonatomic, strong) FVPPlayerView *playerView;
@end

@implementation FVPNativeVideoView

- (instancetype)initWithPlayer:(AVPlayer *)player {
  self = [super init];
  if (self) {
    _playerView = [[FVPPlayerView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
    [_playerView setPlayer:player];
    [self addSubview:_playerView];

    // Add constraints to ensure the playerView resizes with its parent.
    _playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
      [_playerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
      [_playerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
      [_playerView.topAnchor constraintEqualToAnchor:self.topAnchor],
      [_playerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
  }
  return self;
}

- (FVPPlayerView *)view {
  return self.playerView;
}

@end
