// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPNativeVideoViewFactory.h"
#import "FVPNativeVideoView.h"
#import "FVPVideoPlayer.h"

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
                                         arguments:(id _Nullable)args {
  NSNumber *viewIdFromArgs = args[@"playerId"];
  FVPVideoPlayer *player = _playersByTextureId[viewIdFromArgs];
  return [[FVPNativeVideoView alloc] initWithFrame:frame
                                    viewIdentifier:viewId
                                         arguments:args
                                   binaryMessenger:_messenger
                                            player:player.player];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}
@end