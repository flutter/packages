// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoViewFactory.h"

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoView.h"
#import "../video_player_avfoundation/include/video_player_avfoundation/FVPVideoPlayer.h"
#import "../video_player_avfoundation/include/video_player_avfoundation/messages.g.h"

@interface FVPNativeVideoViewFactory ()
@property(nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;
@property(nonatomic, copy) FVPVideoPlayer * (^playerByIdProvider)(NSNumber *);
@end

@implementation FVPNativeVideoViewFactory

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
               playerByIdProvider:(FVPVideoPlayer * (^)(NSNumber *))playerByIdProvider {
  self = [super init];
  if (self) {
    _messenger = messenger;
    _playerByIdProvider = [playerByIdProvider copy];
  }
  return self;
}

- (NSView *)createWithViewIdentifier:(int64_t)viewId
                           arguments:(FVPPlatformVideoViewCreationParams *)args {
  NSNumber *playerId = @(args.playerId);
  FVPVideoPlayer *player = self.playerByIdProvider(playerId);
  return [[FVPNativeVideoView alloc] initWithPlayer:player.player];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return FVPGetMessagesCodec();
}

@end
