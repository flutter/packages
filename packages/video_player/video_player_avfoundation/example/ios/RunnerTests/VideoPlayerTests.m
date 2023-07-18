// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;

#import <OCMock/OCMock.h>
#import <video_player_avfoundation/AVAssetTrackUtils.h>
#import <video_player_avfoundation/FLTVideoPlayerPlugin_Test.h>

@interface FLTVideoPlayer : NSObject <FlutterStreamHandler>
@property(readonly, nonatomic) AVPlayer *player;
@property(readonly, nonatomic) AVPlayerLayer *playerLayer;
@property(readonly, nonatomic) int64_t position;

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture;
@end

@interface FLTVideoPlayerPlugin (Test) <FLTAVFoundationVideoPlayerApi>
@property(readonly, strong, nonatomic)
    NSMutableDictionary<NSNumber *, FLTVideoPlayer *> *playersByTextureId;
@end

@interface FakeAVAssetTrack : AVAssetTrack
@property(readonly, nonatomic) CGAffineTransform preferredTransform;
@property(readonly, nonatomic) CGSize naturalSize;
@property(readonly, nonatomic) UIImageOrientation orientation;
- (instancetype)initWithOrientation:(UIImageOrientation)orientation;
@end

@implementation FakeAVAssetTrack

- (instancetype)initWithOrientation:(UIImageOrientation)orientation {
  _orientation = orientation;
  _naturalSize = CGSizeMake(800, 600);
  return self;
}

- (CGAffineTransform)preferredTransform {
  switch (_orientation) {
    case UIImageOrientationUp:
      return CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    case UIImageOrientationDown:
      return CGAffineTransformMake(-1, 0, 0, -1, 0, 0);
    case UIImageOrientationLeft:
      return CGAffineTransformMake(0, -1, 1, 0, 0, 0);
    case UIImageOrientationRight:
      return CGAffineTransformMake(0, 1, -1, 0, 0, 0);
    case UIImageOrientationUpMirrored:
      return CGAffineTransformMake(-1, 0, 0, 1, 0, 0);
    case UIImageOrientationDownMirrored:
      return CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    case UIImageOrientationLeftMirrored:
      return CGAffineTransformMake(0, -1, -1, 0, 0, 0);
    case UIImageOrientationRightMirrored:
      return CGAffineTransformMake(0, 1, 1, 0, 0, 0);
  }
}

@end

@interface VideoPlayerTests : XCTestCase
@end

@interface StubAVPlayer : AVPlayer
@property(readonly, nonatomic) NSNumber *beforeTolerance;
@property(readonly, nonatomic) NSNumber *afterTolerance;
@end

@implementation StubAVPlayer

- (void)seekToTime:(CMTime)time
      toleranceBefore:(CMTime)toleranceBefore
       toleranceAfter:(CMTime)toleranceAfter
    completionHandler:(void (^)(BOOL finished))completionHandler {
  _beforeTolerance = [NSNumber numberWithLong:toleranceBefore.value];
  _afterTolerance = [NSNumber numberWithLong:toleranceAfter.value];
  completionHandler(YES);
}

@end

@interface StubFVPPlayerFactory : NSObject <FVPPlayerFactory>

@property(nonatomic, strong) StubAVPlayer *stubAVPlayer;

- (instancetype)initWithPlayer:(StubAVPlayer *)stubAVPlayer;

@end

@implementation StubFVPPlayerFactory

- (instancetype)initWithPlayer:(StubAVPlayer *)stubAVPlayer {
  self = [super init];
  _stubAVPlayer = stubAVPlayer;
  return self;
}

- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem {
  return _stubAVPlayer;
}

@end

@implementation VideoPlayerTests

- (void)testBlankVideoBugWithEncryptedVideoStreamAndInvertedAspectRatioBugForSomeVideoStream {
  // This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
  // (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
  // video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
  // invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
  // for issue #1, and restore the correct width and height for issue #2.
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"testPlayerLayerWorkaround"];
  FLTVideoPlayerPlugin *videoPlayerPlugin =
      [[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [FLTCreateMessage
      makeWithAsset:nil
                uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        packageName:nil
         formatHint:nil
        httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(textureMessage);
  FLTVideoPlayer *player = videoPlayerPlugin.playersByTextureId[textureMessage.textureId];
  XCTAssertNotNil(player);

  XCTAssertNotNil(player.playerLayer, @"AVPlayerLayer should be present.");
  XCTAssertNotNil(player.playerLayer.superlayer, @"AVPlayerLayer should be added on screen.");
}

- (void)testSeekToInvokesTextureFrameAvailableOnTextureRegistry {
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"SeekToInvokestextureFrameAvailable"];
  NSObject<FlutterPluginRegistrar> *partialRegistrar = OCMPartialMock(registrar);
  OCMStub([partialRegistrar textures]).andReturn(mockTextureRegistry);
  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:partialRegistrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);
  FLTCreateMessage *create = [FLTCreateMessage
      makeWithAsset:nil
                uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
        packageName:nil
         formatHint:nil
        httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];
  NSNumber *textureId = textureMessage.textureId;

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"seekTo completes"];
  FLTPositionMessage *message = [FLTPositionMessage makeWithTextureId:textureId position:@1234];
  [videoPlayerPlugin seekTo:message
                 completion:^(FlutterError *_Nullable error) {
                   [initializedExpectation fulfill];
                 }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  OCMVerify([mockTextureRegistry textureFrameAvailable:message.textureId.intValue]);

  FLTVideoPlayer *player = videoPlayerPlugin.playersByTextureId[textureId];
  XCTAssertEqual([player position], 1234);
}

- (void)testDeregistersFromPlayer {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"testDeregistersFromPlayer"];
  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [FLTCreateMessage
      makeWithAsset:nil
                uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        packageName:nil
         formatHint:nil
        httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(textureMessage);
  FLTVideoPlayer *player = videoPlayerPlugin.playersByTextureId[textureMessage.textureId];
  XCTAssertNotNil(player);
  AVPlayer *avPlayer = player.player;

  [videoPlayerPlugin dispose:textureMessage error:&error];
  XCTAssertEqual(videoPlayerPlugin.playersByTextureId.count, 0);
  XCTAssertNil(error);

  [self keyValueObservingExpectationForObject:avPlayer keyPath:@"currentItem" expectedValue:nil];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBufferingStateFromPlayer {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"testLiveStreamBufferEndFromPlayer"];
  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [FLTCreateMessage
      makeWithAsset:nil
                uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        packageName:nil
         formatHint:nil
        httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(textureMessage);
  FLTVideoPlayer *player = videoPlayerPlugin.playersByTextureId[textureMessage.textureId];
  XCTAssertNotNil(player);
  AVPlayer *avPlayer = player.player;
  [avPlayer play];

  [player onListenWithArguments:nil
                      eventSink:^(NSDictionary<NSString *, id> *event) {
                        if ([event[@"event"] isEqualToString:@"bufferingEnd"]) {
                          XCTAssertTrue(avPlayer.currentItem.isPlaybackLikelyToKeepUp);
                        }

                        if ([event[@"event"] isEqualToString:@"bufferingStart"]) {
                          XCTAssertFalse(avPlayer.currentItem.isPlaybackLikelyToKeepUp);
                        }
                      }];
  XCTestExpectation *bufferingStateExpectation =
      [self expectationWithDescription:@"bufferingState"];
  NSTimeInterval timeout = 10;
  dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC);
  dispatch_after(delay, dispatch_get_main_queue(), ^{
    [bufferingStateExpectation fulfill];
  });
  [self waitForExpectationsWithTimeout:timeout + 1 handler:nil];
}

- (void)testVideoControls {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar = [registry registrarForPlugin:@"TestVideoControls"];

  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  NSDictionary<NSString *, id> *videoInitialization =
      [self testPlugin:videoPlayerPlugin
                   uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"];
  XCTAssertEqualObjects(videoInitialization[@"height"], @720);
  XCTAssertEqualObjects(videoInitialization[@"width"], @1280);
  XCTAssertEqualWithAccuracy([videoInitialization[@"duration"] intValue], 4000, 200);
}

- (void)testAudioControls {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar = [registry registrarForPlugin:@"TestAudioControls"];

  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  NSDictionary<NSString *, id> *audioInitialization =
      [self testPlugin:videoPlayerPlugin
                   uri:@"https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3"];
  XCTAssertEqualObjects(audioInitialization[@"height"], @0);
  XCTAssertEqualObjects(audioInitialization[@"width"], @0);
  // Perfect precision not guaranteed.
  XCTAssertEqualWithAccuracy([audioInitialization[@"duration"] intValue], 5400, 200);
}

- (void)testHLSControls {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar = [registry registrarForPlugin:@"TestHLSControls"];

  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  NSDictionary<NSString *, id> *videoInitialization =
      [self testPlugin:videoPlayerPlugin
                   uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"];
  XCTAssertEqualObjects(videoInitialization[@"height"], @720);
  XCTAssertEqualObjects(videoInitialization[@"width"], @1280);
  XCTAssertEqualWithAccuracy([videoInitialization[@"duration"] intValue], 4000, 200);
}

- (void)testTransformFix {
  [self validateTransformFixForOrientation:UIImageOrientationUp];
  [self validateTransformFixForOrientation:UIImageOrientationDown];
  [self validateTransformFixForOrientation:UIImageOrientationLeft];
  [self validateTransformFixForOrientation:UIImageOrientationRight];
  [self validateTransformFixForOrientation:UIImageOrientationUpMirrored];
  [self validateTransformFixForOrientation:UIImageOrientationDownMirrored];
  [self validateTransformFixForOrientation:UIImageOrientationLeftMirrored];
  [self validateTransformFixForOrientation:UIImageOrientationRightMirrored];
}

- (void)testSeekToleranceWhenNotSeekingToEnd {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar = [registry registrarForPlugin:@"TestSeekTolerance"];

  StubAVPlayer *stubAVPlayer = [[StubAVPlayer alloc] init];
  StubFVPPlayerFactory *stubFVPPlayerFactory =
      [[StubFVPPlayerFactory alloc] initWithPlayer:stubAVPlayer];
  FLTVideoPlayerPlugin *pluginWithMockAVPlayer =
      [[FLTVideoPlayerPlugin alloc] initWithPlayerFactory:stubFVPPlayerFactory registrar:registrar];

  FlutterError *error;
  [pluginWithMockAVPlayer initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [FLTCreateMessage
      makeWithAsset:nil
                uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        packageName:nil
         formatHint:nil
        httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [pluginWithMockAVPlayer create:create error:&error];
  NSNumber *textureId = textureMessage.textureId;

  XCTestExpectation *initializedExpectation =
      [self expectationWithDescription:@"seekTo has zero tolerance when seeking not to end"];
  FLTPositionMessage *message = [FLTPositionMessage makeWithTextureId:textureId position:@1234];
  [pluginWithMockAVPlayer seekTo:message
                      completion:^(FlutterError *_Nullable error) {
                        [initializedExpectation fulfill];
                      }];

  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  XCTAssertEqual([stubAVPlayer.beforeTolerance intValue], 0);
  XCTAssertEqual([stubAVPlayer.afterTolerance intValue], 0);
}

- (void)testSeekToleranceWhenSeekingToEnd {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"TestSeekToEndTolerance"];

  StubAVPlayer *stubAVPlayer = [[StubAVPlayer alloc] init];
  StubFVPPlayerFactory *stubFVPPlayerFactory =
      [[StubFVPPlayerFactory alloc] initWithPlayer:stubAVPlayer];
  FLTVideoPlayerPlugin *pluginWithMockAVPlayer =
      [[FLTVideoPlayerPlugin alloc] initWithPlayerFactory:stubFVPPlayerFactory registrar:registrar];

  FlutterError *error;
  [pluginWithMockAVPlayer initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [FLTCreateMessage
      makeWithAsset:nil
                uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        packageName:nil
         formatHint:nil
        httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [pluginWithMockAVPlayer create:create error:&error];
  NSNumber *textureId = textureMessage.textureId;

  XCTestExpectation *initializedExpectation =
      [self expectationWithDescription:@"seekTo has non-zero tolerance when seeking to end"];
  // The duration of this video is "0" due to the non standard initiliatazion process.
  FLTPositionMessage *message = [FLTPositionMessage makeWithTextureId:textureId position:@0];
  [pluginWithMockAVPlayer seekTo:message
                      completion:^(FlutterError *_Nullable error) {
                        [initializedExpectation fulfill];
                      }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  XCTAssertGreaterThan([stubAVPlayer.beforeTolerance intValue], 0);
  XCTAssertGreaterThan([stubAVPlayer.afterTolerance intValue], 0);
}

- (NSDictionary<NSString *, id> *)testPlugin:(FLTVideoPlayerPlugin *)videoPlayerPlugin
                                         uri:(NSString *)uri {
  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [FLTCreateMessage makeWithAsset:nil
                                                         uri:uri
                                                 packageName:nil
                                                  formatHint:nil
                                                 httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];

  NSNumber *textureId = textureMessage.textureId;
  FLTVideoPlayer *player = videoPlayerPlugin.playersByTextureId[textureId];
  XCTAssertNotNil(player);

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"initialized"];
  __block NSDictionary<NSString *, id> *initializationEvent;
  [player onListenWithArguments:nil
                      eventSink:^(NSDictionary<NSString *, id> *event) {
                        if ([event[@"event"] isEqualToString:@"initialized"]) {
                          initializationEvent = event;
                          XCTAssertEqual(event.count, 4);
                          [initializedExpectation fulfill];
                        }
                      }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Starts paused.
  AVPlayer *avPlayer = player.player;
  XCTAssertEqual(avPlayer.rate, 0);
  XCTAssertEqual(avPlayer.volume, 1);
  XCTAssertEqual(avPlayer.timeControlStatus, AVPlayerTimeControlStatusPaused);

  // Change playback speed.
  FLTPlaybackSpeedMessage *playback = [FLTPlaybackSpeedMessage makeWithTextureId:textureId
                                                                           speed:@2];
  [videoPlayerPlugin setPlaybackSpeed:playback error:&error];
  XCTAssertNil(error);
  XCTAssertEqual(avPlayer.rate, 2);
  XCTAssertEqual(avPlayer.timeControlStatus, AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate);

  // Volume
  FLTVolumeMessage *volume = [FLTVolumeMessage makeWithTextureId:textureId volume:@0.1];
  [videoPlayerPlugin setVolume:volume error:&error];
  XCTAssertNil(error);
  XCTAssertEqual(avPlayer.volume, 0.1f);

  [player onCancelWithArguments:nil];

  return initializationEvent;
}

// Checks whether [AVPlayer rate] KVO observations are correctly detached.
// - https://github.com/flutter/flutter/issues/124937
//
// Failing to de-register results in a crash in [AVPlayer willChangeValueForKey:].
- (void)testDoesNotCrashOnRateObservationAfterDisposal {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"testDoesNotCrashOnRateObservationAfterDisposal"];

  AVPlayer *avPlayer = nil;
  __weak FLTVideoPlayer *player = nil;

  // Autoreleasepool is needed to simulate conditions of FLTVideoPlayer deallocation.
  @autoreleasepool {
    FLTVideoPlayerPlugin *videoPlayerPlugin =
        (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

    FlutterError *error;
    [videoPlayerPlugin initialize:&error];
    XCTAssertNil(error);

    FLTCreateMessage *create = [FLTCreateMessage
        makeWithAsset:nil
                  uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
          packageName:nil
           formatHint:nil
          httpHeaders:@{}];
    FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(textureMessage);

    player = videoPlayerPlugin.playersByTextureId[textureMessage.textureId];
    XCTAssertNotNil(player);
    avPlayer = player.player;

    [videoPlayerPlugin dispose:textureMessage error:&error];
    XCTAssertNil(error);
  }

  // [FLTVideoPlayerPlugin dispose:error:] selector is dispatching the [FLTVideoPlayer dispose] call
  // with a 1-second delay keeping a strong reference to the player. The polling ensures the player
  // was truly deallocated.
  [self expectationForPredicate:[NSPredicate predicateWithFormat:@"self != nil"]
            evaluatedWithObject:player
                        handler:nil];
  [self waitForExpectationsWithTimeout:10.0 handler:nil];

  [avPlayer willChangeValueForKey:@"rate"];  // No assertions needed. Lack of crash is a success.
}

// During the hot reload:
//  1. `[FLTVideoPlayer onTextureUnregistered:]` gets called.
//  2. `[FLTVideoPlayerPlugin initialize:]` gets called.
//
// Both of these methods dispatch [FLTVideoPlayer dispose] on the main thread
// leading to a possible crash when de-registering observers twice.
- (void)testHotReloadDoesNotCrash {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"testHotReloadDoesNotCrash"];

  __weak FLTVideoPlayer *player = nil;

  // Autoreleasepool is needed to simulate conditions of FLTVideoPlayer deallocation.
  @autoreleasepool {
    FLTVideoPlayerPlugin *videoPlayerPlugin =
        (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

    FlutterError *error;
    [videoPlayerPlugin initialize:&error];
    XCTAssertNil(error);

    FLTCreateMessage *create = [FLTCreateMessage
        makeWithAsset:nil
                  uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
          packageName:nil
           formatHint:nil
          httpHeaders:@{}];
    FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(textureMessage);

    player = videoPlayerPlugin.playersByTextureId[textureMessage.textureId];
    XCTAssertNotNil(player);

    [player onTextureUnregistered:nil];
    XCTAssertNil(error);

    [videoPlayerPlugin initialize:&error];
    XCTAssertNil(error);
  }

  // [FLTVideoPlayerPlugin dispose:error:] selector is dispatching the [FLTVideoPlayer dispose] call
  // with a 1-second delay keeping a strong reference to the player. The polling ensures the player
  // was truly deallocated.
  [self expectationForPredicate:[NSPredicate predicateWithFormat:@"self != nil"]
            evaluatedWithObject:player
                        handler:nil];
  [self waitForExpectationsWithTimeout:10.0
                               handler:nil];  // No assertions needed. Lack of crash is a success.
}

- (void)validateTransformFixForOrientation:(UIImageOrientation)orientation {
  AVAssetTrack *track = [[FakeAVAssetTrack alloc] initWithOrientation:orientation];
  CGAffineTransform t = FLTGetStandardizedTransformForTrack(track);
  CGSize size = track.naturalSize;
  CGFloat expectX, expectY;
  switch (orientation) {
    case UIImageOrientationUp:
      expectX = 0;
      expectY = 0;
      break;
    case UIImageOrientationDown:
      expectX = size.width;
      expectY = size.height;
      break;
    case UIImageOrientationLeft:
      expectX = 0;
      expectY = size.width;
      break;
    case UIImageOrientationRight:
      expectX = size.height;
      expectY = 0;
      break;
    case UIImageOrientationUpMirrored:
      expectX = size.width;
      expectY = 0;
      break;
    case UIImageOrientationDownMirrored:
      expectX = 0;
      expectY = size.height;
      break;
    case UIImageOrientationLeftMirrored:
      expectX = size.height;
      expectY = size.width;
      break;
    case UIImageOrientationRightMirrored:
      expectX = 0;
      expectY = 0;
      break;
  }
  XCTAssertEqual(t.tx, expectX);
  XCTAssertEqual(t.ty, expectY);
}

@end
