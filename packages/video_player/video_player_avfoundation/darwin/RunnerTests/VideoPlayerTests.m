// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;

#import <OCMock/OCMock.h>
#import <video_player_avfoundation/AVAssetTrackUtils.h>
#import <video_player_avfoundation/FVPEventBridge.h>
#import <video_player_avfoundation/FVPNativeVideoViewFactory.h>
#import <video_player_avfoundation/FVPTextureBasedVideoPlayer_Test.h>
#import <video_player_avfoundation/FVPVideoPlayerPlugin_Test.h>

#if TARGET_OS_IOS
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
#endif

@interface VideoPlayerTests : XCTestCase
@end

@interface StubAVPlayer : AVPlayer
@property(readonly, nonatomic) NSNumber *beforeTolerance;
@property(readonly, nonatomic) NSNumber *afterTolerance;
@property(readonly, assign) CMTime lastSeekTime;
@end

@implementation StubAVPlayer

- (void)seekToTime:(CMTime)time
      toleranceBefore:(CMTime)toleranceBefore
       toleranceAfter:(CMTime)toleranceAfter
    completionHandler:(void (^)(BOOL finished))completionHandler {
  _beforeTolerance = [NSNumber numberWithLong:toleranceBefore.value];
  _afterTolerance = [NSNumber numberWithLong:toleranceAfter.value];
  _lastSeekTime = time;
  [super seekToTime:time
        toleranceBefore:toleranceBefore
         toleranceAfter:toleranceAfter
      completionHandler:completionHandler];
}

@end

// Convience to avoid having two copies of the StubViewProvider code.
#if TARGET_OS_OSX
#define PROVIDED_VIEW_TYPE NSView
#else
#define PROVIDED_VIEW_TYPE UIView
#endif

@interface StubViewProvider : NSObject <FVPViewProvider>
- (instancetype)initWithView:(PROVIDED_VIEW_TYPE *)view;
@property(nonatomic, nullable) PROVIDED_VIEW_TYPE *view;
@end

@implementation StubViewProvider
- (instancetype)initWithView:(PROVIDED_VIEW_TYPE *)view {
  self = [super init];
  _view = view;
  return self;
}
@end

@interface StubFVPAVFactory : NSObject <FVPAVFactory>

@property(nonatomic, strong) StubAVPlayer *stubAVPlayer;
@property(nonatomic, strong) AVPlayerItemVideoOutput *output;

- (instancetype)initWithPlayer:(StubAVPlayer *)stubAVPlayer
                        output:(AVPlayerItemVideoOutput *)output;

@end

@implementation StubFVPAVFactory

// Creates a factory that returns the given items. Any items that are nil will instead return
// a real object just as the non-test implementation would.
- (instancetype)initWithPlayer:(StubAVPlayer *)stubAVPlayer
                        output:(AVPlayerItemVideoOutput *)output {
  self = [super init];
  _stubAVPlayer = stubAVPlayer;
  _output = output;
  return self;
}

- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem {
  return _stubAVPlayer ?: [AVPlayer playerWithPlayerItem:playerItem];
}

- (AVPlayerItemVideoOutput *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes {
  return _output ?: [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:attributes];
}

@end

#pragma mark -

@interface StubFVPDisplayLink : NSObject <FVPDisplayLink>
@property(nonatomic, assign) BOOL running;
@end

@implementation StubFVPDisplayLink
- (CFTimeInterval)duration {
  return 1.0 / 60.0;
}
@end

/** Test implementation of FVPDisplayLinkFactory that returns a stub display link instance.  */
@interface StubFVPDisplayLinkFactory : NSObject <FVPDisplayLinkFactory>
/** This display link to return. */
@property(nonatomic, strong) StubFVPDisplayLink *displayLink;
@property(nonatomic, copy) void (^fireDisplayLink)(void);
@end

@implementation StubFVPDisplayLinkFactory
- (instancetype)init {
  self = [super init];
  _displayLink = [[StubFVPDisplayLink alloc] init];
  return self;
}
- (NSObject<FVPDisplayLink> *)displayLinkWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                                              callback:(void (^)(void))callback {
  self.fireDisplayLink = callback;
  return self.displayLink;
}

@end

#pragma mark -

@interface StubEventListener : NSObject <FVPVideoEventListener>

@property(nonatomic) XCTestExpectation *initializationExpectation;
@property(nonatomic) int64_t initializationDuration;
@property(nonatomic) CGSize initializationSize;

- (instancetype)initWithInitializationExpectation:(XCTestExpectation *)expectation;

@end

@implementation StubEventListener

- (instancetype)initWithInitializationExpectation:(XCTestExpectation *)expectation {
  self = [super init];
  _initializationExpectation = expectation;
  return self;
}

- (void)videoPlayerDidComplete {
}

- (void)videoPlayerDidEndBuffering {
}

- (void)videoPlayerDidErrorWithMessage:(NSString *)errorMessage {
}

- (void)videoPlayerDidInitializeWithDuration:(int64_t)duration size:(CGSize)size {
  [self.initializationExpectation fulfill];
  self.initializationDuration = duration;
  self.initializationSize = size;
}

- (void)videoPlayerDidSetPlaying:(BOOL)playing {
}

- (void)videoPlayerDidStartBuffering {
}

- (void)videoPlayerDidUpdateBufferRegions:(NSArray<NSArray<NSNumber *> *> *)regions {
}

- (void)videoPlayerWasDisposed {
}

@end

#pragma mark -

@implementation VideoPlayerTests

- (void)testBlankVideoBugWithEncryptedVideoStreamAndInvertedAspectRatioBugForSomeVideoStream {
  // This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
  // (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
  // video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
  // invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
  // for issue #1, and restore the correct width and height for issue #2.
#if TARGET_OS_OSX
  NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
  view.wantsLayer = true;
#else
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
#endif
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil output:nil]
      displayLinkFactory:nil
            viewProvider:[[StubViewProvider alloc] initWithView:view]
               registrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      httpHeaders:@{}];
  FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(identifiers);
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
  XCTAssertNotNil(player);

  XCTAssertNotNil(player.playerLayer, @"AVPlayerLayer should be present.");
  XCTAssertEqual(player.playerLayer.superlayer, view.layer,
                 @"AVPlayerLayer should be added on screen.");
}

- (void)testPlayerForPlatformViewDoesNotRegisterTexture {
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  OCMStub([registrar textures]).andReturn(mockTextureRegistry);
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  AVPlayerItemVideoOutput *mockVideoOutput = OCMPartialMock([[AVPlayerItemVideoOutput alloc] init]);
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil output:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
            viewProvider:[[StubViewProvider alloc] initWithView:nil]
               registrar:registrar];

  FlutterError *initializationError;
  [videoPlayerPlugin initialize:&initializationError];
  XCTAssertNil(initializationError);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
      httpHeaders:@{}];
  FlutterError *createError;
  [videoPlayerPlugin createPlatformViewPlayerWithOptions:create error:&createError];

  OCMVerify(never(), [mockTextureRegistry registerTexture:[OCMArg any]]);
}

- (void)testSeekToWhilePausedStartsDisplayLinkTemporarily {
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  OCMStub([registrar textures]).andReturn(mockTextureRegistry);
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  AVPlayerItemVideoOutput *mockVideoOutput = OCMPartialMock([[AVPlayerItemVideoOutput alloc] init]);
  // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
  // the player via the plugin instead of directly to include that logic in the test.
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil output:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
            viewProvider:[[StubViewProvider alloc] initWithView:nil]
               registrar:registrar];

  FlutterError *initializationError;
  [videoPlayerPlugin initialize:&initializationError];
  XCTAssertNil(initializationError);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
      httpHeaders:@{}];
  FlutterError *createError;
  FVPTexturePlayerIds *identifiers =
      [videoPlayerPlugin createTexturePlayerWithOptions:create error:&createError];
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];

  // Ensure that the video playback is paused before seeking.
  FlutterError *pauseError;
  [player pauseWithError:&pauseError];

  XCTestExpectation *seekExpectation = [self expectationWithDescription:@"seekTo completes"];
  [player seekTo:1234
      completion:^(FlutterError *_Nullable error) {
        [seekExpectation fulfill];
      }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Seeking to a new position should start the display link temporarily.
  XCTAssertTrue(stubDisplayLinkFactory.displayLink.running);

  // Simulate a buffer being available.
  OCMStub([mockVideoOutput hasNewPixelBufferForItemTime:kCMTimeZero])
      .ignoringNonObjectArgs()
      .andReturn(YES);
  CVPixelBufferRef bufferRef;
  CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
  OCMStub([mockVideoOutput copyPixelBufferForItemTime:kCMTimeZero itemTimeForDisplay:NULL])
      .ignoringNonObjectArgs()
      .andReturn(bufferRef);
  // Simulate a callback from the engine to request a new frame.
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  // Since a frame was found, and the video is paused, the display link should be paused again.
  XCTAssertFalse(stubDisplayLinkFactory.displayLink.running);
}

- (void)testInitStartsDisplayLinkTemporarily {
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  OCMStub([registrar textures]).andReturn(mockTextureRegistry);
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  AVPlayerItemVideoOutput *mockVideoOutput = OCMPartialMock([[AVPlayerItemVideoOutput alloc] init]);
  StubAVPlayer *stubAVPlayer = [[StubAVPlayer alloc] init];
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:stubAVPlayer
                                                           output:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
            viewProvider:[[StubViewProvider alloc] initWithView:nil]
               registrar:registrar];

  FlutterError *initializationError;
  [videoPlayerPlugin initialize:&initializationError];
  XCTAssertNil(initializationError);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
      httpHeaders:@{}];
  FlutterError *createError;
  FVPTexturePlayerIds *identifiers =
      [videoPlayerPlugin createTexturePlayerWithOptions:create error:&createError];

  // Init should start the display link temporarily.
  XCTAssertTrue(stubDisplayLinkFactory.displayLink.running);

  // Simulate a buffer being available.
  OCMStub([mockVideoOutput hasNewPixelBufferForItemTime:kCMTimeZero])
      .ignoringNonObjectArgs()
      .andReturn(YES);
  CVPixelBufferRef bufferRef;
  CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
  OCMStub([mockVideoOutput copyPixelBufferForItemTime:kCMTimeZero itemTimeForDisplay:NULL])
      .ignoringNonObjectArgs()
      .andReturn(bufferRef);
  // Simulate a callback from the engine to request a new frame.
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  // Since a frame was found, and the video is paused, the display link should be paused again.
  XCTAssertFalse(stubDisplayLinkFactory.displayLink.running);
}

- (void)testSeekToWhilePlayingDoesNotStopDisplayLink {
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  OCMStub([registrar textures]).andReturn(mockTextureRegistry);
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  AVPlayerItemVideoOutput *mockVideoOutput = OCMPartialMock([[AVPlayerItemVideoOutput alloc] init]);
  // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
  // the player via the plugin instead of directly to include that logic in the test.
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil output:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
            viewProvider:[[StubViewProvider alloc] initWithView:nil]
               registrar:registrar];

  FlutterError *initializationError;
  [videoPlayerPlugin initialize:&initializationError];
  XCTAssertNil(initializationError);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
      httpHeaders:@{}];
  FlutterError *createError;
  FVPTexturePlayerIds *identifiers =
      [videoPlayerPlugin createTexturePlayerWithOptions:create error:&createError];
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];

  // Ensure that the video is playing before seeking.
  FlutterError *playError;
  [player playWithError:&playError];

  XCTestExpectation *seekExpectation = [self expectationWithDescription:@"seekTo completes"];
  [player seekTo:1234
      completion:^(FlutterError *_Nullable error) {
        [seekExpectation fulfill];
      }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  XCTAssertTrue(stubDisplayLinkFactory.displayLink.running);

  // Simulate a buffer being available.
  OCMStub([mockVideoOutput hasNewPixelBufferForItemTime:kCMTimeZero])
      .ignoringNonObjectArgs()
      .andReturn(YES);
  CVPixelBufferRef bufferRef;
  CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
  OCMStub([mockVideoOutput copyPixelBufferForItemTime:kCMTimeZero itemTimeForDisplay:NULL])
      .ignoringNonObjectArgs()
      .andReturn(bufferRef);
  // Simulate a callback from the engine to request a new frame.
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  // Since the video was playing, the display link should not be paused after getting a buffer.
  XCTAssertTrue(stubDisplayLinkFactory.displayLink.running);
}

- (void)testPauseWhileWaitingForFrameDoesNotStopDisplayLink {
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  OCMStub([registrar textures]).andReturn(mockTextureRegistry);
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  AVPlayerItemVideoOutput *mockVideoOutput = OCMPartialMock([[AVPlayerItemVideoOutput alloc] init]);
  // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
  // the player via the plugin instead of directly to include that logic in the test.
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil output:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
            viewProvider:[[StubViewProvider alloc] initWithView:nil]
               registrar:registrar];

  FlutterError *initializationError;
  [videoPlayerPlugin initialize:&initializationError];
  XCTAssertNil(initializationError);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
      httpHeaders:@{}];
  FlutterError *createError;
  FVPTexturePlayerIds *identifiers =
      [videoPlayerPlugin createTexturePlayerWithOptions:create error:&createError];
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];

  // Run a play/pause cycle to force the pause codepath to run completely.
  FlutterError *playPauseError;
  [player playWithError:&playPauseError];
  [player pauseWithError:&playPauseError];

  // Since a buffer hasn't been available yet, the pause should not have stopped the display link.
  XCTAssertTrue(stubDisplayLinkFactory.displayLink.running);
}

- (void)testDeregistersFromPlayer {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      (FVPVideoPlayerPlugin *)[[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      httpHeaders:@{}];
  FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(identifiers);
  FVPVideoPlayer *player = videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
  XCTAssertNotNil(player);
  AVPlayer *avPlayer = player.player;

  [self keyValueObservingExpectationForObject:avPlayer keyPath:@"currentItem" expectedValue:nil];

  [player disposeWithError:&error];
  XCTAssertEqual(videoPlayerPlugin.playersByIdentifier.count, 0);
  XCTAssertNil(error);

  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testBufferingStateFromPlayer {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      (FVPVideoPlayerPlugin *)[[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      httpHeaders:@{}];
  FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(identifiers);
  FVPVideoPlayer *player = videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
  XCTAssertNotNil(player);
  AVPlayer *avPlayer = player.player;
  [avPlayer play];

  // TODO(stuartmorgan): Update this test to instead use a mock listener, and add separate unit
  // tests of FVPEventBridge.
  [(NSObject<FlutterStreamHandler> *)player.eventListener
      onListenWithArguments:nil
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
  StubEventListener *eventListener =
      [self sanityTestURI:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"];
  XCTAssertEqual(eventListener.initializationSize.height, 720);
  XCTAssertEqual(eventListener.initializationSize.width, 1280);
  XCTAssertEqualWithAccuracy(eventListener.initializationDuration, 4000, 200);
}

- (void)testAudioControls {
  StubEventListener *eventListener = [self
      sanityTestURI:@"https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3"];
  XCTAssertEqual(eventListener.initializationSize.height, 0);
  XCTAssertEqual(eventListener.initializationSize.width, 0);
  // Perfect precision not guaranteed.
  XCTAssertEqualWithAccuracy(eventListener.initializationDuration, 5400, 200);
}

- (void)testHLSControls {
  StubEventListener *eventListener = [self
      sanityTestURI:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"];
  XCTAssertEqual(eventListener.initializationSize.height, 720);
  XCTAssertEqual(eventListener.initializationSize.width, 1280);
  XCTAssertEqualWithAccuracy(eventListener.initializationDuration, 4000, 200);
}

- (void)testAudioOnlyHLSControls {
  XCTSkip(@"Flaky; see https://github.com/flutter/flutter/issues/164381");

  StubEventListener *eventListener =
      [self sanityTestURI:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/"
                          @"bee_audio_only.m3u8"];
  XCTAssertEqual(eventListener.initializationSize.height, 0);
  XCTAssertEqual(eventListener.initializationSize.width, 0);
  XCTAssertEqualWithAccuracy(eventListener.initializationDuration, 4000, 200);
}

#if TARGET_OS_IOS
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
#endif

- (void)testSeekToleranceWhenNotSeekingToEnd {
  StubAVPlayer *stubAVPlayer = [[StubAVPlayer alloc] init];
  StubFVPAVFactory *stubAVFactory = [[StubFVPAVFactory alloc] initWithPlayer:stubAVPlayer
                                                                      output:nil];
  FVPVideoPlayer *player =
      [[FVPVideoPlayer alloc] initWithPlayerItem:[self playerItemWithURL:self.mp4TestURL]
                                       avFactory:stubAVFactory
                                    viewProvider:[[StubViewProvider alloc] initWithView:nil]];
  NSObject<FVPVideoEventListener> *listener = OCMProtocolMock(@protocol(FVPVideoEventListener));
  player.eventListener = listener;

  XCTestExpectation *seekExpectation =
      [self expectationWithDescription:@"seekTo has zero tolerance when seeking not to end"];
  [player seekTo:1234
      completion:^(FlutterError *_Nullable error) {
        [seekExpectation fulfill];
      }];

  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  XCTAssertEqual([stubAVPlayer.beforeTolerance intValue], 0);
  XCTAssertEqual([stubAVPlayer.afterTolerance intValue], 0);
}

- (void)testSeekToleranceWhenSeekingToEnd {
  StubAVPlayer *stubAVPlayer = [[StubAVPlayer alloc] init];
  StubFVPAVFactory *stubAVFactory = [[StubFVPAVFactory alloc] initWithPlayer:stubAVPlayer
                                                                      output:nil];
  FVPVideoPlayer *player =
      [[FVPVideoPlayer alloc] initWithPlayerItem:[self playerItemWithURL:self.mp4TestURL]
                                       avFactory:stubAVFactory
                                    viewProvider:[[StubViewProvider alloc] initWithView:nil]];
  NSObject<FVPVideoEventListener> *listener = OCMProtocolMock(@protocol(FVPVideoEventListener));
  player.eventListener = listener;

  XCTestExpectation *seekExpectation =
      [self expectationWithDescription:@"seekTo has non-zero tolerance when seeking to end"];
  // The duration of this video is "0" due to the non standard initiliatazion process.
  [player seekTo:0
      completion:^(FlutterError *_Nullable error) {
        [seekExpectation fulfill];
      }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  XCTAssertGreaterThan([stubAVPlayer.beforeTolerance intValue], 0);
  XCTAssertGreaterThan([stubAVPlayer.afterTolerance intValue], 0);
}

/// Sanity checks a video player playing the given URL with the actual AVPlayer. This is essentially
/// a mini integration test of the player component.
///
/// Returns the stub event listener to allow tests to inspect the call state.
- (StubEventListener *)sanityTestURI:(NSString *)testURI {
  NSURL *testURL = [NSURL URLWithString:testURI];
  XCTAssertNotNil(testURL);
  FVPVideoPlayer *player =
      [[FVPVideoPlayer alloc] initWithPlayerItem:[self playerItemWithURL:testURL]
                                       avFactory:[[FVPDefaultAVFactory alloc] init]
                                    viewProvider:[[StubViewProvider alloc] initWithView:nil]];
  XCTAssertNotNil(player);

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"initialized"];
  StubEventListener *listener =
      [[StubEventListener alloc] initWithInitializationExpectation:initializedExpectation];
  player.eventListener = listener;
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Starts paused.
  AVPlayer *avPlayer = player.player;
  XCTAssertEqual(avPlayer.rate, 0);
  XCTAssertEqual(avPlayer.volume, 1);
  XCTAssertEqual(avPlayer.timeControlStatus, AVPlayerTimeControlStatusPaused);

  // Change playback speed.
  FlutterError *error;
  [player setPlaybackSpeed:2 error:&error];
  XCTAssertNil(error);
  [player playWithError:&error];
  XCTAssertNil(error);
  XCTAssertEqual(avPlayer.rate, 2);
  XCTAssertEqual(avPlayer.timeControlStatus, AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate);

  // Volume
  [player setVolume:0.1 error:&error];
  XCTAssertNil(error);
  XCTAssertEqual(avPlayer.volume, 0.1f);

  return listener;
}

// Checks whether [AVPlayer rate] KVO observations are correctly detached.
// - https://github.com/flutter/flutter/issues/124937
//
// Failing to de-register results in a crash in [AVPlayer willChangeValueForKey:].
- (void)testDoesNotCrashOnRateObservationAfterDisposal {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  AVPlayer *avPlayer = nil;
  __weak FVPVideoPlayer *weakPlayer = nil;

  // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
  @autoreleasepool {
    FVPVideoPlayerPlugin *videoPlayerPlugin =
        (FVPVideoPlayerPlugin *)[[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];

    FlutterError *error;
    [videoPlayerPlugin initialize:&error];
    XCTAssertNil(error);

    FVPCreationOptions *create = [FVPCreationOptions
        makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        httpHeaders:@{}];
    FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                   error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(identifiers);

    FVPVideoPlayer *player = videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
    XCTAssertNotNil(player);
    weakPlayer = player;
    avPlayer = player.player;

    [player disposeWithError:&error];
    XCTAssertNil(error);
  }

  // [FVPVideoPlayerPlugin dispose:error:] selector is dispatching the [FVPVideoPlayer dispose] call
  // with a 1-second delay keeping a strong reference to the player. The polling ensures the player
  // was truly deallocated.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
  [self expectationForPredicate:[NSPredicate predicateWithFormat:@"self != nil"]
            evaluatedWithObject:weakPlayer
                        handler:nil];
#pragma clang diagnostic pop
  [self waitForExpectationsWithTimeout:10.0 handler:nil];

  [avPlayer willChangeValueForKey:@"rate"];  // No assertions needed. Lack of crash is a success.
}

// During the hot reload:
//  1. `[FVPVideoPlayer onTextureUnregistered:]` gets called.
//  2. `[FVPVideoPlayerPlugin initialize:]` gets called.
//
// Both of these methods dispatch [FVPVideoPlayer dispose] on the main thread
// leading to a possible crash when de-registering observers twice.
- (void)testHotReloadDoesNotCrash {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  __weak FVPVideoPlayer *weakPlayer = nil;

  // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
  @autoreleasepool {
    FVPVideoPlayerPlugin *videoPlayerPlugin =
        (FVPVideoPlayerPlugin *)[[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];

    FlutterError *error;
    [videoPlayerPlugin initialize:&error];
    XCTAssertNil(error);

    FVPCreationOptions *create = [FVPCreationOptions
        makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        httpHeaders:@{}];
    FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                   error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(identifiers);

    FVPTextureBasedVideoPlayer *player =
        (FVPTextureBasedVideoPlayer *)
            videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
    XCTAssertNotNil(player);
    weakPlayer = player;

    [player onTextureUnregistered:nil];
    XCTAssertNil(error);

    [videoPlayerPlugin initialize:&error];
    XCTAssertNil(error);
  }

  // [FVPVideoPlayerPlugin dispose:error:] selector is dispatching the [FVPVideoPlayer dispose] call
  // with a 1-second delay keeping a strong reference to the player. The polling ensures the player
  // was truly deallocated.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
  [self expectationForPredicate:[NSPredicate predicateWithFormat:@"self != nil"]
            evaluatedWithObject:weakPlayer
                        handler:nil];
#pragma clang diagnostic pop
  [self waitForExpectationsWithTimeout:10.0
                               handler:nil];  // No assertions needed. Lack of crash is a success.
}

- (void)testNativeVideoViewFactoryRegistration {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));

  OCMExpect([registrar registerViewFactory:[OCMArg isKindOfClass:[FVPNativeVideoViewFactory class]]
                                    withId:@"plugins.flutter.dev/video_player_ios"]);
  [FVPVideoPlayerPlugin registerWithRegistrar:registrar];

  OCMVerifyAll(registrar);
}

- (void)testPublishesInRegistration {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  __block NSObject *publishedValue;
  OCMStub([registrar publish:[OCMArg checkWithBlock:^BOOL(id value) {
                       publishedValue = value;
                       return YES;
                     }]]);

  [FVPVideoPlayerPlugin registerWithRegistrar:registrar];

  XCTAssertNotNil(publishedValue);
  XCTAssertTrue([publishedValue isKindOfClass:[FVPVideoPlayerPlugin class]]);
}

- (void)testFailedToLoadVideoEventShouldBeAlwaysSent {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];
  FlutterError *error;

  [videoPlayerPlugin initialize:&error];

  FVPCreationOptions *create = [FVPCreationOptions makeWithUri:@"" httpHeaders:@{}];
  FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                 error:&error];
  FVPVideoPlayer *player = videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
  XCTAssertNotNil(player);

  [self keyValueObservingExpectationForObject:(id)player.player.currentItem
                                      keyPath:@"status"
                                expectedValue:@(AVPlayerItemStatusFailed)];
  [self waitForExpectationsWithTimeout:10.0 handler:nil];

  XCTestExpectation *failedExpectation = [self expectationWithDescription:@"failed"];
  // TODO(stuartmorgan): Update this test to instead use a mock listener, and add separate unit
  // tests of FVPEventBridge.
  [(NSObject<FlutterStreamHandler> *)player.eventListener
      onListenWithArguments:nil
                  eventSink:^(FlutterError *event) {
                    if ([event isKindOfClass:FlutterError.class]) {
                      [failedExpectation fulfill];
                    }
                  }];
  [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testUpdatePlayingStateShouldNotResetRate {
  FVPVideoPlayer *player = [[FVPVideoPlayer alloc]
      initWithPlayerItem:[self playerItemWithURL:self.mp4TestURL]
               avFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil output:nil]
            viewProvider:[[StubViewProvider alloc] initWithView:nil]];

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"initialized"];
  StubEventListener *listener =
      [[StubEventListener alloc] initWithInitializationExpectation:initializedExpectation];
  player.eventListener = listener;
  [self waitForExpectationsWithTimeout:10 handler:nil];

  FlutterError *error;
  [player setPlaybackSpeed:2 error:&error];
  [player playWithError:&error];
  XCTAssertEqual(player.player.rate, 2);
}

- (void)testPlayerShouldNotDropEverySecondFrame {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  OCMStub([registrar textures]).andReturn(mockTextureRegistry);

  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  AVPlayerItemVideoOutput *mockVideoOutput = OCMPartialMock([[AVPlayerItemVideoOutput alloc] init]);
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil output:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
            viewProvider:[[StubViewProvider alloc] initWithView:nil]
               registrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      httpHeaders:@{}];
  FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                 error:&error];
  NSInteger playerIdentifier = identifiers.playerId;
  NSInteger textureIdentifier = identifiers.textureId;
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(playerIdentifier)];

  __block CMTime currentTime = kCMTimeZero;
  OCMStub([mockVideoOutput itemTimeForHostTime:0])
      .ignoringNonObjectArgs()
      .andDo(^(NSInvocation *invocation) {
        [invocation setReturnValue:&currentTime];
      });
  __block NSMutableSet *pixelBuffers = NSMutableSet.new;
  OCMStub([mockVideoOutput hasNewPixelBufferForItemTime:kCMTimeZero])
      .ignoringNonObjectArgs()
      .andDo(^(NSInvocation *invocation) {
        CMTime itemTime;
        [invocation getArgument:&itemTime atIndex:2];
        BOOL has = [pixelBuffers containsObject:[NSValue valueWithCMTime:itemTime]];
        [invocation setReturnValue:&has];
      });
  OCMStub([mockVideoOutput copyPixelBufferForItemTime:kCMTimeZero
                                   itemTimeForDisplay:[OCMArg anyPointer]])
      .ignoringNonObjectArgs()
      .andDo(^(NSInvocation *invocation) {
        CMTime itemTime;
        [invocation getArgument:&itemTime atIndex:2];
        CVPixelBufferRef bufferRef = NULL;
        if ([pixelBuffers containsObject:[NSValue valueWithCMTime:itemTime]]) {
          CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
        }
        [pixelBuffers removeObject:[NSValue valueWithCMTime:itemTime]];
        [invocation setReturnValue:&bufferRef];
      });
  void (^advanceFrame)(void) = ^{
    currentTime.value++;
    [pixelBuffers addObject:[NSValue valueWithCMTime:currentTime]];
  };

  advanceFrame();
  OCMExpect([mockTextureRegistry textureFrameAvailable:textureIdentifier]);
  stubDisplayLinkFactory.fireDisplayLink();
  OCMVerifyAllWithDelay(mockTextureRegistry, 10);

  advanceFrame();
  OCMExpect([mockTextureRegistry textureFrameAvailable:textureIdentifier]);
  CFRelease([player copyPixelBuffer]);
  stubDisplayLinkFactory.fireDisplayLink();
  OCMVerifyAllWithDelay(mockTextureRegistry, 10);
}

#if TARGET_OS_IOS
- (void)testVideoPlayerShouldNotOverwritePlayAndRecordNorDefaultToSpeaker {
  NSObject<FlutterPluginRegistrar> *registrar = OCMProtocolMock(@protocol(FlutterPluginRegistrar));
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithRegistrar:registrar];
  FlutterError *error;

  [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord
                                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                       error:nil];

  [videoPlayerPlugin initialize:&error];
  [videoPlayerPlugin setMixWithOthers:true error:&error];
  XCTAssert(AVAudioSession.sharedInstance.category == AVAudioSessionCategoryPlayAndRecord,
            @"Category should be PlayAndRecord.");
  XCTAssert(
      AVAudioSession.sharedInstance.categoryOptions & AVAudioSessionCategoryOptionDefaultToSpeaker,
      @"Flag DefaultToSpeaker was removed.");
  XCTAssert(
      AVAudioSession.sharedInstance.categoryOptions & AVAudioSessionCategoryOptionMixWithOthers,
      @"Flag MixWithOthers should be set.");

  id sessionMock = OCMClassMock([AVAudioSession class]);
  OCMStub([sessionMock sharedInstance]).andReturn(sessionMock);
  OCMStub([sessionMock category]).andReturn(AVAudioSessionCategoryPlayAndRecord);
  OCMStub([sessionMock categoryOptions])
      .andReturn(AVAudioSessionCategoryOptionMixWithOthers |
                 AVAudioSessionCategoryOptionDefaultToSpeaker);
  OCMReject([sessionMock setCategory:OCMOCK_ANY withOptions:0 error:[OCMArg setTo:nil]])
      .ignoringNonObjectArgs();

  [videoPlayerPlugin setMixWithOthers:true error:&error];
}

- (void)validateTransformFixForOrientation:(UIImageOrientation)orientation {
  AVAssetTrack *track = [[FakeAVAssetTrack alloc] initWithOrientation:orientation];
  CGAffineTransform t = FVPGetStandardizedTransformForTrack(track);
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
#endif

/// Returns a test URL for creating a player from a network source.
- (nonnull NSURL *)mp4TestURL {
  return (NSURL *_Nonnull)[NSURL
      URLWithString:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"];
}

- (nonnull AVPlayerItem *)playerItemWithURL:(NSURL *)url {
  return [AVPlayerItem playerItemWithAsset:[AVURLAsset URLAssetWithURL:url options:nil]];
}

@end
