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
       playerByIdentifierProvider:(FVPVideoPlayer * (^)(NSNumber *))playerByIdProvider {
  self = [super init];
  if (self) {
    _messenger = messenger;
    _playerByIdProvider = [playerByIdProvider copy];
  }
  return self;
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewIdentifier
                                         arguments:(FVPPlatformVideoViewCreationParams *)args {
  NSNumber *playerIdentifier = @(args.playerId);
  FVPVideoPlayer *player = self.playerByIdProvider(playerIdentifier);
  return [[FVPNativeVideoView alloc] initWithPlayer:player.player];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return FVPGetMessagesCodec();
}

@end
