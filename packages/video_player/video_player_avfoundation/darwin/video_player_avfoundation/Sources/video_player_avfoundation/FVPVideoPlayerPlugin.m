// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPVideoPlayerPlugin.h"
#import "./include/video_player_avfoundation/FVPVideoPlayerPlugin_Test.h"

#import <AVFoundation/AVFoundation.h>

#import "./include/video_player_avfoundation/FVPAVFactory.h"
#import "./include/video_player_avfoundation/FVPDisplayLink.h"
#import "./include/video_player_avfoundation/FVPFrameUpdater.h"
#import "./include/video_player_avfoundation/FVPTextureBasedVideoPlayer.h"
#import "./include/video_player_avfoundation/FVPVideoPlayer.h"
// Relative path is needed for messages.g.h. See
// https://github.com/flutter/packages/pull/6675/#discussion_r1591210702
#import "./include/video_player_avfoundation/messages.g.h"

#if TARGET_OS_IOS
// Platform views are only supported on iOS as of now.
#import "./include/video_player_avfoundation/FVPNativeVideoViewFactory.h"
#endif

#if !__has_feature(objc_arc)
#error Code Requires ARC.
#endif

/// Non-test implementation of the diplay link factory.
@interface FVPDefaultDisplayLinkFactory : NSObject <FVPDisplayLinkFactory>
@end

@implementation FVPDefaultDisplayLinkFactory
- (FVPDisplayLink *)displayLinkWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                                    callback:(void (^)(void))callback {
  return [[FVPDisplayLink alloc] initWithRegistrar:registrar callback:callback];
}

@end

#pragma mark -

/// The next non-texture player ID, initialized to a high number to avoid collisions with
/// texture IDs (which are generated separately).
static int64_t nextNonTexturePlayerId = INT_MAX;

@interface FVPVideoPlayerPlugin ()
@property(readonly, weak, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, weak, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, strong, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) id<FVPDisplayLinkFactory> displayLinkFactory;
@property(nonatomic, strong) id<FVPAVFactory> avFactory;
@end

@implementation FVPVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FVPVideoPlayerPlugin *instance = [[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];
  [registrar publish:instance];
#if TARGET_OS_IOS
  // Platform views are only supported on iOS as of now.
  FVPNativeVideoViewFactory *factory =
      [[FVPNativeVideoViewFactory alloc] initWithMessenger:registrar.messenger
                                        playerByIdProvider:^FVPVideoPlayer *(NSNumber *playerId) {
                                          return instance->_playersById[playerId];
                                        }];
  [registrar registerViewFactory:factory withId:@"plugins.flutter.dev/video_player_ios"];
#endif
  SetUpFVPAVFoundationVideoPlayerApi(registrar.messenger, instance);
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  return [self initWithAVFactory:[[FVPDefaultAVFactory alloc] init]
              displayLinkFactory:[[FVPDefaultDisplayLinkFactory alloc] init]
                       registrar:registrar];
}

- (instancetype)initWithAVFactory:(id<FVPAVFactory>)avFactory
               displayLinkFactory:(id<FVPDisplayLinkFactory>)displayLinkFactory
                        registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = [registrar textures];
  _messenger = [registrar messenger];
  _registrar = registrar;
  _displayLinkFactory = displayLinkFactory ?: [[FVPDefaultDisplayLinkFactory alloc] init];
  _avFactory = avFactory ?: [[FVPDefaultAVFactory alloc] init];
  _playersById = [NSMutableDictionary dictionaryWithCapacity:1];
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self.playersById.allValues makeObjectsPerformSelector:@selector(disposeSansEventChannel)];
  [self.playersById removeAllObjects];
  SetUpFVPAVFoundationVideoPlayerApi(registrar.messenger, nil);
}

- (int64_t)onPlayerSetup:(FVPVideoPlayer *)player frameUpdater:(FVPFrameUpdater *)frameUpdater {
  BOOL textureBased =
      frameUpdater != nil && [player isKindOfClass:[FVPTextureBasedVideoPlayer class]];
  int64_t playerId;
  if (textureBased) {
    playerId = [self.registry registerTexture:(FVPTextureBasedVideoPlayer *)player];
    frameUpdater.textureId = playerId;
  } else {
    @synchronized(self) {
      playerId = nextNonTexturePlayerId--;
    }
  }

  FlutterEventChannel *eventChannel = [FlutterEventChannel
      eventChannelWithName:[NSString
                               stringWithFormat:@"flutter.io/videoPlayer/videoEvents%lld", playerId]
           binaryMessenger:_messenger];
  [eventChannel setStreamHandler:player];
  player.eventChannel = eventChannel;
  self.playersById[@(playerId)] = player;

  if (textureBased) {
    // Ensure that the first frame is drawn once available, even if the video isn't played, since
    // the engine is now expecting the texture to be populated.
    [(FVPTextureBasedVideoPlayer *)player expectFrame];
  }

  return playerId;
}

- (void)initialize:(FlutterError *__autoreleasing *)error {
#if TARGET_OS_IOS
  // Allow audio playback when the Ring/Silent switch is set to silent
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
#endif

  [self.playersById
      enumerateKeysAndObjectsUsingBlock:^(NSNumber *textureId, FVPVideoPlayer *player, BOOL *stop) {
        [self.registry unregisterTexture:textureId.unsignedIntegerValue];
        [player dispose];
      }];
  [self.playersById removeAllObjects];
}

- (nullable NSNumber *)createWithOptions:(nonnull FVPCreationOptions *)options
                                   error:(FlutterError **)error {
  BOOL textureBased = options.viewType == FVPPlatformVideoViewTypeTextureView;
  FVPFrameUpdater *frameUpdater;
  FVPDisplayLink *displayLink;
  if (textureBased) {
    frameUpdater = [[FVPFrameUpdater alloc] initWithRegistry:_registry];
    displayLink = [self.displayLinkFactory displayLinkWithRegistrar:_registrar
                                                           callback:^() {
                                                             [frameUpdater displayLinkFired];
                                                           }];
  }

  FVPVideoPlayer *player;
  if (options.asset) {
    NSString *assetPath;
    if (options.packageName) {
      assetPath = [_registrar lookupKeyForAsset:options.asset fromPackage:options.packageName];
    } else {
      assetPath = [_registrar lookupKeyForAsset:options.asset];
    }
    @try {
      if (textureBased) {
        player = [[FVPTextureBasedVideoPlayer alloc] initWithAsset:assetPath
                                                      frameUpdater:frameUpdater
                                                       displayLink:displayLink
                                                         avFactory:_avFactory
                                                         registrar:self.registrar];
      } else {
        player = [[FVPVideoPlayer alloc] initWithAsset:assetPath
                                             avFactory:_avFactory
                                             registrar:self.registrar];
      }
      return @([self onPlayerSetup:player frameUpdater:frameUpdater]);
    } @catch (NSException *exception) {
      *error = [FlutterError errorWithCode:@"video_player" message:exception.reason details:nil];
      return nil;
    }
  } else if (options.uri) {
    if (textureBased) {
      player = [[FVPTextureBasedVideoPlayer alloc] initWithURL:[NSURL URLWithString:options.uri]
                                                  frameUpdater:frameUpdater
                                                   displayLink:displayLink
                                                   httpHeaders:options.httpHeaders
                                                     avFactory:_avFactory
                                                     registrar:self.registrar];
    } else {
      player = [[FVPVideoPlayer alloc] initWithURL:[NSURL URLWithString:options.uri]
                                       httpHeaders:options.httpHeaders
                                         avFactory:_avFactory
                                         registrar:self.registrar];
    }
    return @([self onPlayerSetup:player frameUpdater:frameUpdater]);
  } else {
    *error = [FlutterError errorWithCode:@"video_player" message:@"not implemented" details:nil];
    return nil;
  }
}

- (void)disposePlayer:(NSInteger)playerId error:(FlutterError **)error {
  NSNumber *playerKey = @(playerId);
  FVPVideoPlayer *player = self.playersById[playerKey];
  if ([player isKindOfClass:[FVPTextureBasedVideoPlayer class]]) {
    [self.registry unregisterTexture:playerId];
  }
  [self.playersById removeObjectForKey:playerKey];
  if (!player.disposed) {
    [player dispose];
  }
}

- (void)setLooping:(BOOL)isLooping forPlayer:(NSInteger)playerId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersById[@(playerId)];
  player.isLooping = isLooping;
}

- (void)setVolume:(double)volume forPlayer:(NSInteger)playerId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersById[@(playerId)];
  [player setVolume:volume];
}

- (void)setPlaybackSpeed:(double)speed forPlayer:(NSInteger)playerId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersById[@(playerId)];
  [player setPlaybackSpeed:speed];
}

- (void)playPlayer:(NSInteger)playerId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersById[@(playerId)];
  [player play];
}

- (nullable NSNumber *)positionForPlayer:(NSInteger)playerId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersById[@(playerId)];
  return @([player position]);
}

- (void)seekTo:(NSInteger)position
     forPlayer:(NSInteger)playerId
    completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FVPVideoPlayer *player = self.playersById[@(playerId)];
  [player seekTo:position
      completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(nil);
        });
      }];
}

- (void)pausePlayer:(NSInteger)playerId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersById[@(playerId)];
  [player pause];
}

- (void)setMixWithOthers:(BOOL)mixWithOthers
                   error:(FlutterError *_Nullable __autoreleasing *)error {
#if TARGET_OS_OSX
  // AVAudioSession doesn't exist on macOS, and audio always mixes, so just no-op.
#else
  if (mixWithOthers) {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                           error:nil];
  } else {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
  }
#endif
}

@end
