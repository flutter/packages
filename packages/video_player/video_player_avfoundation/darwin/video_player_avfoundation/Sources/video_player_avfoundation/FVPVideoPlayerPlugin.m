// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPVideoPlayerPlugin.h"
#import "./include/video_player_avfoundation/FVPVideoPlayerPlugin_Test.h"

#import <AVFoundation/AVFoundation.h>

#import "./include/video_player_avfoundation/FVPAVFactory.h"
#import "./include/video_player_avfoundation/FVPDisplayLink.h"
#import "./include/video_player_avfoundation/FVPFrameUpdater.h"
#import "./include/video_player_avfoundation/FVPNativeVideoViewFactory.h"
#import "./include/video_player_avfoundation/FVPTextureBasedVideoPlayer.h"
#import "./include/video_player_avfoundation/FVPVideoPlayer.h"
// Relative path is needed for messages.g.h. See
// https://github.com/flutter/packages/pull/6675/#discussion_r1591210702
#import "./include/video_player_avfoundation/messages.g.h"

#if !__has_feature(objc_arc)
#error Code Requires ARC.
#endif

/// Non-test implementation of the diplay link factory.
@interface FVPDefaultDisplayLinkFactory : NSObject <FVPDisplayLinkFactory>
@end

@implementation FVPDefaultDisplayLinkFactory
- (NSObject<FVPDisplayLink> *)displayLinkWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                                              callback:(void (^)(void))callback {
#if TARGET_OS_IOS
  return [[FVPCADisplayLink alloc] initWithRegistrar:registrar callback:callback];
#else
  if (@available(macOS 14.0, *)) {
    return [[FVPCADisplayLink alloc] initWithRegistrar:registrar callback:callback];
  }
  return [[FVPCoreVideoDisplayLink alloc] initWithRegistrar:registrar callback:callback];
#endif
}

@end

#pragma mark -

@interface FVPVideoPlayerPlugin ()
@property(readonly, strong, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(nonatomic, strong) id<FVPDisplayLinkFactory> displayLinkFactory;
@property(nonatomic, strong) id<FVPAVFactory> avFactory;
@property(nonatomic, strong) NSObject<FVPViewProvider> *viewProvider;
// TODO(stuartmorgan): Decouple identifiers for platform views and texture views.
@property(nonatomic, assign) int64_t nextNonTexturePlayerIdentifier;
@end

@implementation FVPVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FVPVideoPlayerPlugin *instance = [[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];
  [registrar publish:instance];
  FVPNativeVideoViewFactory *factory = [[FVPNativeVideoViewFactory alloc]
               initWithMessenger:registrar.messenger
      playerByIdentifierProvider:^FVPVideoPlayer *(NSNumber *playerIdentifier) {
        return instance->_playersByIdentifier[playerIdentifier];
      }];
  [registrar registerViewFactory:factory withId:@"plugins.flutter.dev/video_player_ios"];
  SetUpFVPAVFoundationVideoPlayerApi(registrar.messenger, instance);
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  return [self initWithAVFactory:[[FVPDefaultAVFactory alloc] init]
              displayLinkFactory:[[FVPDefaultDisplayLinkFactory alloc] init]
                    viewProvider:[[FVPDefaultViewProvider alloc] initWithRegistrar:registrar]
                       registrar:registrar];
}

- (instancetype)initWithAVFactory:(id<FVPAVFactory>)avFactory
               displayLinkFactory:(id<FVPDisplayLinkFactory>)displayLinkFactory
                     viewProvider:(NSObject<FVPViewProvider> *)viewProvider
                        registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registrar = registrar;
  _viewProvider = viewProvider;
  _displayLinkFactory = displayLinkFactory ?: [[FVPDefaultDisplayLinkFactory alloc] init];
  _avFactory = avFactory ?: [[FVPDefaultAVFactory alloc] init];
  _viewProvider = viewProvider ?: [[FVPDefaultViewProvider alloc] initWithRegistrar:registrar];
  _playersByIdentifier = [NSMutableDictionary dictionaryWithCapacity:1];
  // Initialized to a high number to avoid collisions with texture identifiers (which are generated
  // separately).
  _nextNonTexturePlayerIdentifier = INT_MAX;
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self.playersByIdentifier.allValues
      makeObjectsPerformSelector:@selector(disposeSansEventChannel)];
  [self.playersByIdentifier removeAllObjects];
  SetUpFVPAVFoundationVideoPlayerApi(registrar.messenger, nil);
}

- (int64_t)onPlayerSetup:(FVPVideoPlayer *)player {
  FVPTextureBasedVideoPlayer *textureBasedPlayer =
      [player isKindOfClass:[FVPTextureBasedVideoPlayer class]]
          ? (FVPTextureBasedVideoPlayer *)player
          : nil;

  int64_t playerIdentifier;
  if (textureBasedPlayer) {
    playerIdentifier = [self.registrar.textures registerTexture:textureBasedPlayer];
    [textureBasedPlayer setTextureIdentifier:playerIdentifier];
  } else {
    playerIdentifier = self.nextNonTexturePlayerIdentifier--;
  }

  NSObject<FlutterBinaryMessenger> *messenger = self.registrar.messenger;
  NSString *channelSuffix = [NSString stringWithFormat:@"%lld", playerIdentifier];
  // Set up the player-specific API handler, and its onDispose unregistration.
  SetUpFVPVideoPlayerInstanceApiWithSuffix(messenger, player, channelSuffix);
  __weak typeof(self) weakSelf = self;
  BOOL isTextureBased = textureBasedPlayer != nil;
  player.onDisposed = ^() {
    SetUpFVPVideoPlayerInstanceApiWithSuffix(messenger, nil, channelSuffix);
    if (isTextureBased) {
      [weakSelf.registrar.textures unregisterTexture:playerIdentifier];
    }
  };
  // Set up the event channel.
  FlutterEventChannel *eventChannel = [FlutterEventChannel
      eventChannelWithName:[NSString stringWithFormat:@"flutter.io/videoPlayer/videoEvents%@",
                                                      channelSuffix]
           binaryMessenger:messenger];
  [eventChannel setStreamHandler:player];
  player.eventChannel = eventChannel;

  self.playersByIdentifier[@(playerIdentifier)] = player;

  // Ensure that the first frame is drawn once available, even if the video isn't played, since
  // the engine is now expecting the texture to be populated.
  [textureBasedPlayer expectFrame];

  return playerIdentifier;
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

  [self.playersByIdentifier.allValues makeObjectsPerformSelector:@selector(dispose)];
  [self.playersByIdentifier removeAllObjects];
}

- (nullable NSNumber *)createWithOptions:(nonnull FVPCreationOptions *)options
                                   error:(FlutterError **)error {
  BOOL textureBased = options.viewType == FVPPlatformVideoViewTypeTextureView;

  @try {
    FVPVideoPlayer *player = textureBased ? [self texturePlayerWithOptions:options]
                                          : [self platformViewPlayerWithOptions:options];
    return @([self onPlayerSetup:player]);
  } @catch (NSException *exception) {
    *error = [FlutterError errorWithCode:@"video_player" message:exception.reason details:nil];
    return nil;
  }
}

- (nonnull FVPTextureBasedVideoPlayer *)texturePlayerWithOptions:
    (nonnull FVPCreationOptions *)options {
  FVPFrameUpdater *frameUpdater =
      [[FVPFrameUpdater alloc] initWithRegistry:self.registrar.textures];
  NSObject<FVPDisplayLink> *displayLink =
      [self.displayLinkFactory displayLinkWithRegistrar:_registrar
                                               callback:^() {
                                                 [frameUpdater displayLinkFired];
                                               }];

  return [[FVPTextureBasedVideoPlayer alloc] initWithURL:[NSURL URLWithString:options.uri]
                                            frameUpdater:frameUpdater
                                             displayLink:displayLink
                                             httpHeaders:options.httpHeaders
                                               avFactory:self.avFactory
                                            viewProvider:self.viewProvider];
}

- (nonnull FVPVideoPlayer *)platformViewPlayerWithOptions:(nonnull FVPCreationOptions *)options {
  // FVPVideoPlayer contains all required logic for platform views.
  return [[FVPVideoPlayer alloc] initWithURL:[NSURL URLWithString:options.uri]
                                 httpHeaders:options.httpHeaders
                                   avFactory:self.avFactory
                                viewProvider:self.viewProvider];
}

- (void)disposePlayer:(NSInteger)playerIdentifier error:(FlutterError **)error {
  NSNumber *playerKey = @(playerIdentifier);
  FVPVideoPlayer *player = self.playersByIdentifier[playerKey];
  [self.playersByIdentifier removeObjectForKey:playerKey];
  [player dispose];
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

- (nullable NSString *)fileURLForAssetWithName:(NSString *)asset
                                       package:(nullable NSString *)package
                                         error:(FlutterError *_Nullable *_Nonnull)error {
  NSString *resource = package == nil
                           ? [self.registrar lookupKeyForAsset:asset]
                           : [self.registrar lookupKeyForAsset:asset fromPackage:package];

  NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:nil];
#if TARGET_OS_OSX
  // See https://github.com/flutter/flutter/issues/135302
  // TODO(stuartmorgan): Remove this if the asset APIs are adjusted to work better for macOS.
  if (!path) {
    path = [NSURL URLWithString:resource relativeToURL:NSBundle.mainBundle.bundleURL].path;
  }
#endif

  if (!path) {
    return nil;
  }
  return [NSURL fileURLWithPath:path].absoluteString;
}

@end
