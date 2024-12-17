// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPVideoPlayerPlugin.h"
#import "./include/video_player_avfoundation/FVPVideoPlayerPlugin_Test.h"

#import <AVFoundation/AVFoundation.h>

#import "./include/video_player_avfoundation/FVPAVFactory.h"
#import "./include/video_player_avfoundation/FVPDisplayLink.h"
#import "./include/video_player_avfoundation/FVPFrameUpdater.h"
#import "./include/video_player_avfoundation/FVPVideoPlayer.h"
#import "./include/video_player_avfoundation/messages.g.h"

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
@end

@implementation FVPVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FVPVideoPlayerPlugin *instance = [[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];
  [registrar publish:instance];
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
  _playersByTextureId = [NSMutableDictionary dictionaryWithCapacity:1];
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [self.playersByTextureId.allValues makeObjectsPerformSelector:@selector(disposeSansEventChannel)];
  [self.playersByTextureId removeAllObjects];
  SetUpFVPAVFoundationVideoPlayerApi(registrar.messenger, nil);
}

- (int64_t)onPlayerSetup:(FVPVideoPlayer *)player frameUpdater:(FVPFrameUpdater *)frameUpdater {
  int64_t textureId = [self.registry registerTexture:player];
  frameUpdater.textureId = textureId;
  FlutterEventChannel *eventChannel = [FlutterEventChannel
      eventChannelWithName:[NSString stringWithFormat:@"flutter.io/videoPlayer/videoEvents%lld",
                                                      textureId]
           binaryMessenger:_messenger];
  [eventChannel setStreamHandler:player];
  player.eventChannel = eventChannel;
  self.playersByTextureId[@(textureId)] = player;

  // Ensure that the first frame is drawn once available, even if the video isn't played, since
  // the engine is now expecting the texture to be populated.
  [player expectFrame];

  return textureId;
}

- (void)initialize:(FlutterError *__autoreleasing *)error {
#if TARGET_OS_IOS
  // Allow audio playback when the Ring/Silent switch is set to silent
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
#endif

  [self.playersByTextureId
      enumerateKeysAndObjectsUsingBlock:^(NSNumber *textureId, FVPVideoPlayer *player, BOOL *stop) {
        [self.registry unregisterTexture:textureId.unsignedIntegerValue];
        [player dispose];
      }];
  [self.playersByTextureId removeAllObjects];
}

- (nullable NSNumber *)createWithOptions:(nonnull FVPCreationOptions *)options
                                   error:(FlutterError **)error {
  FVPFrameUpdater *frameUpdater = [[FVPFrameUpdater alloc] initWithRegistry:_registry];
  FVPDisplayLink *displayLink =
      [self.displayLinkFactory displayLinkWithRegistrar:_registrar
                                               callback:^() {
                                                 [frameUpdater displayLinkFired];
                                               }];

  FVPVideoPlayer *player;
  if (options.asset) {
    NSString *assetPath;
    if (options.packageName) {
      assetPath = [_registrar lookupKeyForAsset:options.asset fromPackage:options.packageName];
    } else {
      assetPath = [_registrar lookupKeyForAsset:options.asset];
    }
    @try {
      player = [[FVPVideoPlayer alloc] initWithAsset:assetPath
                                        frameUpdater:frameUpdater
                                         displayLink:displayLink
                                           avFactory:_avFactory
                                           registrar:self.registrar];
      return @([self onPlayerSetup:player frameUpdater:frameUpdater]);
    } @catch (NSException *exception) {
      *error = [FlutterError errorWithCode:@"video_player" message:exception.reason details:nil];
      return nil;
    }
  } else if (options.uri) {
    player = [[FVPVideoPlayer alloc] initWithURL:[NSURL URLWithString:options.uri]
                                    frameUpdater:frameUpdater
                                     displayLink:displayLink
                                     httpHeaders:options.httpHeaders
                                       avFactory:_avFactory
                                       registrar:self.registrar];
    return @([self onPlayerSetup:player frameUpdater:frameUpdater]);
  } else {
    *error = [FlutterError errorWithCode:@"video_player" message:@"not implemented" details:nil];
    return nil;
  }
}

- (void)disposePlayer:(NSInteger)textureId error:(FlutterError **)error {
  NSNumber *playerKey = @(textureId);
  FVPVideoPlayer *player = self.playersByTextureId[playerKey];
  [self.registry unregisterTexture:textureId];
  [self.playersByTextureId removeObjectForKey:playerKey];
  if (!player.disposed) {
    [player dispose];
  }
}

- (void)setLooping:(BOOL)isLooping forPlayer:(NSInteger)textureId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersByTextureId[@(textureId)];
  player.isLooping = isLooping;
}

- (void)setVolume:(double)volume forPlayer:(NSInteger)textureId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersByTextureId[@(textureId)];
  [player setVolume:volume];
}

- (void)setPlaybackSpeed:(double)speed forPlayer:(NSInteger)textureId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersByTextureId[@(textureId)];
  [player setPlaybackSpeed:speed];
}

- (void)playPlayer:(NSInteger)textureId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersByTextureId[@(textureId)];
  [player play];
}

- (nullable NSNumber *)positionForPlayer:(NSInteger)textureId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersByTextureId[@(textureId)];
  return @([player position]);
}

- (void)seekTo:(NSInteger)position
     forPlayer:(NSInteger)textureId
    completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  FVPVideoPlayer *player = self.playersByTextureId[@(textureId)];
  [player seekTo:position
      completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(nil);
        });
      }];
}

- (void)pausePlayer:(NSInteger)textureId error:(FlutterError **)error {
  FVPVideoPlayer *player = self.playersByTextureId[@(textureId)];
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
