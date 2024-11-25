// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPVideoPlayer.h"

#import "./include/FVPNativeVideoView.h"
#import "./include/FVPNativeVideoViewFactory.h"

@implementation FVPNativeVideoViewFactory {
  NSObject<FlutterBinaryMessenger> *_messenger;
  NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *_playersByTextureId;
}
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
               playersByTextureId:
                   (NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *)playersByTextureId {
  self = [super init];
  if (self) {
    _messenger = messenger;
    _playersByTextureId = playersByTextureId;
  }
  return self;
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(FVPPlatformVideoViewCreationParams *)args {
  NSNumber *playerId = @(args.playerId);
  FVPVideoPlayer *player = _playersByTextureId[playerId];
  return [[FVPNativeVideoView alloc] initWithPlayer:player.player];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return FVPGetMessagesCodec();
}
@end
