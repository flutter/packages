// Copyright 2013 The Flutter Authors
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

#pragma mark - FlutterPlatformViewFactory

#if TARGET_OS_OSX
- (NSView *)createWithViewIdentifier:(int64_t)viewIdentifier
                           arguments:(FVPPlatformVideoViewCreationParams *)args {
#else
- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewIdentifier
                                         arguments:(FVPPlatformVideoViewCreationParams *)args {
#endif
  NSNumber *playerIdentifier = @(args.playerId);
  FVPVideoPlayer *player = self.playerByIdProvider(playerIdentifier);
  return [[FVPNativeVideoView alloc] initWithPlayer:player.player];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return FVPGetMessagesCodec();
}

@end
