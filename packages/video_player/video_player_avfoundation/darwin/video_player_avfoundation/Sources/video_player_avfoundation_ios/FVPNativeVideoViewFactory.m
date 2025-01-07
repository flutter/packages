// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoViewFactory.h"

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoView.h"
#import "../video_player_avfoundation/include/video_player_avfoundation/FVPVideoPlayer.h"
#import "../video_player_avfoundation/include/video_player_avfoundation/messages.g.h"

@implementation FVPNativeVideoViewFactory {
  NSObject<FlutterBinaryMessenger> *_messenger;
  FVPVideoPlayer * (^_playerByIdProvider)(NSNumber *);
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
               playerByIdProvider:(FVPVideoPlayer * (^)(NSNumber *))playerByIdProvider {
  self = [super init];
  if (self) {
    _messenger = messenger;
    _playerByIdProvider = [playerByIdProvider copy];
  }
  return self;
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(FVPPlatformVideoViewCreationParams *)args {
  NSNumber *playerId = @(args.playerId);
  FVPVideoPlayer *player = _playerByIdProvider(playerId);
  return [[FVPNativeVideoView alloc] initWithPlayer:player.player];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return FVPGetMessagesCodec();
}

@end