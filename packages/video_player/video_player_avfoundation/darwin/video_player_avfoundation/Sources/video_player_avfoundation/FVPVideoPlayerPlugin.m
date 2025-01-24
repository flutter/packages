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

@interface FVPVideoPlayerPlugin ()
@property(readonly, weak, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, weak, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, strong, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) id<FVPDisplayLinkFactory> displayLinkFactory;
@property(nonatomic, strong) id<FVPAVFactory> avFactory;
// TODO(stuartmorgan): Decouple IDs for platform views and texture views.
@property(nonatomic, assign) int64_t nextNonTexturePlayerId;
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
  // Initialized to a high number to avoid collisions with texture IDs (which are generated
  // separately).
  _nextNonTexturePlayerId = INT_MAX;
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self.playersById.allValues makeObjectsPerformSelector:@selector(disposeSansEventChannel)];
  [self.playersById removeAllObjects];
  SetUpFVPAVFoundationVideoPlayerApi(registrar.messenger, nil);
}

- (int64_t)onPlayerSetup:(FVPVideoPlayer *)player {
  BOOL textureBased = [player isKindOfClass:[FVPTextureBasedVideoPlayer class]];
  int64_t playerId;
  if (textureBased) {
    playerId = [self.registry registerTexture:(FVPTextureBasedVideoPlayer *)player];
    [(FVPTextureBasedVideoPlayer *)player setTextureId:playerId];
  } else {
    playerId = self.nextNonTexturePlayerId--;
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

// This function, although slightly modified, is also in camera_avfoundation.
// Both need to do the same thing and run on the same thread (for example main thread).
// Do not overwrite PlayAndRecord with Playback which causes inability to record
// audio, do not overwrite all options.
// Only change category if it is considered an upgrade which means it can only enable
// ability to play in silent mode or ability to record audio but never disables it,
// that could affect other plugins which depend on this global state. Only change
// category or options if there is change to prevent unnecessary lags and silence.
#if TARGET_OS_IOS
static void upgradeAudioSessionCategory(AVAudioSessionCategory requestedCategory,
                                        AVAudioSessionCategoryOptions options,
                                        AVAudioSessionCategoryOptions clearOptions) {
  NSSet *playCategories = [NSSet
      setWithObjects:AVAudioSessionCategoryPlayback, AVAudioSessionCategoryPlayAndRecord, nil];
  NSSet *recordCategories =
      [NSSet setWithObjects:AVAudioSessionCategoryRecord, AVAudioSessionCategoryPlayAndRecord, nil];
  NSSet *requiredCategories =
      [NSSet setWithObjects:requestedCategory, AVAudioSession.sharedInstance.category, nil];
  BOOL requiresPlay = [requiredCategories intersectsSet:playCategories];
  BOOL requiresRecord = [requiredCategories intersectsSet:recordCategories];
  if (requiresPlay && requiresRecord) {
    requestedCategory = AVAudioSessionCategoryPlayAndRecord;
  } else if (requiresPlay) {
    requestedCategory = AVAudioSessionCategoryPlayback;
  } else if (requiresRecord) {
    requestedCategory = AVAudioSessionCategoryRecord;
  }
  options = (AVAudioSession.sharedInstance.categoryOptions & ~clearOptions) | options;
  if ([requestedCategory isEqualToString:AVAudioSession.sharedInstance.category] &&
      options == AVAudioSession.sharedInstance.categoryOptions) {
    return;
  }
  [AVAudioSession.sharedInstance setCategory:requestedCategory withOptions:options error:nil];
}
#endif

- (void)initialize:(FlutterError *__autoreleasing *)error {
#if TARGET_OS_IOS
  // Allow audio playback when the Ring/Silent switch is set to silent
  upgradeAudioSessionCategory(AVAudioSessionCategoryPlayback, 0, 0);
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

  @try {
    FVPVideoPlayer *player;
    if (textureBased) {
      player = [self createTextureBasedPlayerFromOptions:options];
    } else {
      player = [self createRegularPlayerFromOptions:options];
    }

    if (player == nil) {
      *error = [FlutterError errorWithCode:@"video_player" message:@"not implemented" details:nil];
      return nil;
    }

    return @([self onPlayerSetup:player]);
  } @catch (NSException *exception) {
    *error = [FlutterError errorWithCode:@"video_player" message:exception.reason details:nil];
    return nil;
  }
}

- (nullable NSNumber *)createTextureBasedPlayerFromOptions:(nonnull FVPCreationOptions *)options {
  FVPFrameUpdater *frameUpdater = [[FVPFrameUpdater alloc] initWithRegistry:_registry];
  FVPDisplayLink *displayLink =
      [self.displayLinkFactory displayLinkWithRegistrar:_registrar
                                               callback:^() {
                                                 [frameUpdater displayLinkFired];
                                               }];

  void (^onDisposed)(int64_t) = ^(int64_t textureId) {
    [self.registry unregisterTexture:textureId];
  };

  if (options.asset) {
    NSString *assetPath = [self prepareAssetPathFromCreationOptions:options];
    return [[FVPTextureBasedVideoPlayer alloc] initWithAsset:assetPath
                                                frameUpdater:frameUpdater
                                                 displayLink:displayLink
                                                   avFactory:_avFactory
                                                   registrar:self.registrar
                                                  onDisposed:onDisposed];
  } else if (options.uri) {
    return [[FVPTextureBasedVideoPlayer alloc] initWithURL:[NSURL URLWithString:options.uri]
                                              frameUpdater:frameUpdater
                                               displayLink:displayLink
                                               httpHeaders:options.httpHeaders
                                                 avFactory:_avFactory
                                                 registrar:self.registrar
                                                onDisposed:onDisposed];
  }

  return nil;
}

- (nullable NSNumber *)createRegularPlayerFromOptions:(nonnull FVPCreationOptions *)options {
  if (options.asset) {
    NSString *assetPath = [self prepareAssetPathFromCreationOptions:options];
    return [[FVPVideoPlayer alloc] initWithAsset:assetPath
                                       avFactory:_avFactory
                                       registrar:self.registrar];
  } else if (options.uri) {
    return [[FVPVideoPlayer alloc] initWithURL:[NSURL URLWithString:options.uri]
                                   httpHeaders:options.httpHeaders
                                     avFactory:_avFactory
                                     registrar:self.registrar];
  }

  return nil;
}

- (NSString *)prepareAssetPathFromCreationOptions:(nonnull FVPCreationOptions *)options {
  NSString *assetPath;
  if (options.packageName) {
    assetPath = [self.registrar lookupKeyForAsset:options.asset fromPackage:options.packageName];
  } else {
    assetPath = [self.registrar lookupKeyForAsset:options.asset];
  }
  return assetPath;
}

- (void)disposePlayer:(NSInteger)playerId error:(FlutterError **)error {
  NSNumber *playerKey = @(playerId);
  FVPVideoPlayer *player = self.playersById[playerKey];
  [self.playersById removeObjectForKey:playerKey];
  [player dispose];
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
    upgradeAudioSessionCategory(AVAudioSession.sharedInstance.category,
                                AVAudioSessionCategoryOptionMixWithOthers, 0);
  } else {
    upgradeAudioSessionCategory(AVAudioSession.sharedInstance.category, 0,
                                AVAudioSessionCategoryOptionMixWithOthers);
  }
#endif
}

@end
