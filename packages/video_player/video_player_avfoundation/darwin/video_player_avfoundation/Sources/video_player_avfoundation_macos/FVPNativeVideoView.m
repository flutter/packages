// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoView.h"

#import <AVFoundation/AVFoundation.h>

@interface FVPPlayerView : NSView
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@end

@implementation FVPPlayerView

+ (Class)layerClass {
  return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    self.wantsLayer = YES;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
    [self.layer addSublayer:self.playerLayer];
  }
  return self;
}

- (void)setPlayer:(AVPlayer *)player {
  self.playerLayer.player = player;
  self.playerLayer.frame = self.bounds;
}

- (void)layout {
  [super layout];

  // Disable implicit player animations to size the player layer to the view bounds without a delay.
  [CATransaction begin];
  [CATransaction setDisableActions:YES];

  self.playerLayer.frame = self.bounds;

  [CATransaction commit];

  [self.playerLayer displayIfNeeded];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface FVPNativeVideoView ()
@property(nonatomic, strong) FVPPlayerView *playerView;
@end

@implementation FVPNativeVideoView

- (instancetype)initWithPlayer:(AVPlayer *)player {
  self = [super init];
  if (self) {
    _playerView = [[FVPPlayerView alloc] initWithFrame:NSMakeRect(0, 0, 640, 480)];
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