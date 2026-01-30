// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;

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

/// An AVPlayer subclass that records method call parameters for inspection.
// TODO(stuartmorgan): Replace with a protocol like the other classes.
@interface InspectableAVPlayer : AVPlayer
@property(readonly, nonatomic) NSNumber *beforeTolerance;
@property(readonly, nonatomic) NSNumber *afterTolerance;
@property(readonly, assign) CMTime lastSeekTime;
@end

@implementation InspectableAVPlayer

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

@interface TestAsset : NSObject <FVPAVAsset>
@property(nonatomic, readonly) CMTime duration;
@property(nonatomic, nullable, readonly) NSArray<AVAssetTrack *> *tracks;

@property(nonatomic, assign) BOOL loadedTracksAsynchronously;
@end

@implementation TestAsset
- (instancetype)init {
  return [self initWithDuration:kCMTimeZero tracks:nil];
}

- (instancetype)initWithDuration:(CMTime)duration
                          tracks:(nullable NSArray<AVAssetTrack *> *)tracks {
  self = [super init];
  _duration = duration;
  _tracks = tracks;
  return self;
}

- (AVKeyValueStatus)statusOfValueForKey:(NSString *)key
                                  error:(NSError *_Nullable *_Nullable)outError {
  return self.tracks == nil ? AVKeyValueStatusLoading : AVKeyValueStatusLoaded;
}

- (void)loadValuesAsynchronouslyForKeys:(NSArray<NSString *> *)keys
                      completionHandler:(nullable void (^NS_SWIFT_SENDABLE)(void))handler {
  if (handler) {
    handler();
  }
}

- (void)loadTracksWithMediaType:(AVMediaType)mediaType
              completionHandler:(void (^NS_SWIFT_SENDABLE)(NSArray<AVAssetTrack *> *_Nullable,
                                                           NSError *_Nullable))completionHandler
    API_AVAILABLE(macos(12.0), ios(15.0)) {
  self.loadedTracksAsynchronously = YES;
  completionHandler(_tracks, nil);
}

- (NSArray<AVAssetTrack *> *)tracksWithMediaType:(AVMediaType)mediaType
    API_DEPRECATED("Use loadTracksWithMediaType:completionHandler: instead", macos(10.7, 15.0),
                   ios(4.0, 18.0)) {
  return _tracks;
}
@end

@interface StubPlayerItem : NSObject <FVPAVPlayerItem>
@property(nonatomic, readonly) NSObject<FVPAVAsset> *asset;
@property(nonatomic, copy, nullable) AVVideoComposition *videoComposition;
@end

@implementation StubPlayerItem
- (instancetype)init {
  return [self initWithAsset:[[TestAsset alloc] init]];
}

- (instancetype)initWithAsset:(NSObject<FVPAVAsset> *)asset {
  self = [super init];
  _asset = asset;
  return self;
}
@end

@interface StubBinaryMessenger : NSObject <FlutterBinaryMessenger>
@end

@implementation StubBinaryMessenger

- (void)sendOnChannel:(NSString *)channel message:(NSData *_Nullable)message {
}
- (void)sendOnChannel:(NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
}
- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  return 0;
}
- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
}
@end

@interface TestTextureRegistry : NSObject <FlutterTextureRegistry>
@property(nonatomic, assign) BOOL registeredTexture;
@property(nonatomic, assign) BOOL unregisteredTexture;
@property(nonatomic, assign) int textureFrameAvailableCount;
@end

@implementation TestTextureRegistry
- (int64_t)registerTexture:(NSObject<FlutterTexture> *)texture {
  self.registeredTexture = true;
  return 1;
}

- (void)unregisterTexture:(int64_t)textureId {
  if (textureId != 1) {
    XCTFail(@"Unregistering texture with wrong ID");
  }
  self.unregisteredTexture = true;
}

- (void)textureFrameAvailable:(int64_t)textureId {
  if (textureId != 1) {
    XCTFail(@"Texture frame available with wrong ID");
  }
  self.textureFrameAvailableCount++;
}
@end

@interface StubViewProvider : NSObject <FVPViewProvider>
#if TARGET_OS_IOS
- (instancetype)initWithViewController:(UIViewController *)viewController;
@property(nonatomic, nullable) UIViewController *viewController;
#else
- (instancetype)initWithView:(NSView *)view;
@property(nonatomic, nullable) NSView *view;
#endif
@end

@implementation StubViewProvider
#if TARGET_OS_IOS
- (instancetype)initWithViewController:(UIViewController *)viewController {
  self = [super init];
  _viewController = viewController;
  return self;
}
#else
- (instancetype)initWithView:(NSView *)view {
  self = [super init];
  _view = view;
  return self;
}
#endif
@end

@interface StubAssetProvider : NSObject <FVPAssetProvider>
@end

@implementation StubAssetProvider
- (NSString *)lookupKeyForAsset:(NSString *)asset {
  return asset;
}

- (NSString *)lookupKeyForAsset:(NSString *)asset fromPackage:(NSString *)package {
  return asset;
}
@end

@interface TestPixelBufferSource : NSObject <FVPPixelBufferSource>
@property(nonatomic) CVPixelBufferRef pixelBuffer;
@property(nonatomic, readonly) AVPlayerItemVideoOutput *videoOutput;
@end

@implementation TestPixelBufferSource
- (instancetype)init {
  self = [super init];
  // Create an arbitrary video output to for attaching to actual AVFoundation
  // objects. The attributes don't matter since this isn't used to implement
  // the methods called by the plugin.
  _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:@{
    (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
    (id)kCVPixelBufferIOSurfacePropertiesKey : @{}
  }];
  return self;
}

- (void)dealloc {
  CVPixelBufferRelease(_pixelBuffer);
}

- (void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer {
  CVPixelBufferRelease(_pixelBuffer);
  _pixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

- (CMTime)itemTimeForHostTime:(CFTimeInterval)hostTimeInSeconds {
  return CMTimeMakeWithSeconds(hostTimeInSeconds, 1000);
}

- (BOOL)hasNewPixelBufferForItemTime:(CMTime)itemTime {
  return _pixelBuffer != NULL;
}

- (nullable CVPixelBufferRef)copyPixelBufferForItemTime:(CMTime)itemTime
                                     itemTimeForDisplay:(nullable CMTime *)outItemTimeForDisplay {
  CVPixelBufferRef pixelBuffer = _pixelBuffer;
  // Ownership is transferred to the caller.
  _pixelBuffer = NULL;
  return pixelBuffer;
}
@end

#if TARGET_OS_IOS
@interface TestAudioSession : NSObject <FVPAVAudioSession>
@property(nonatomic, readwrite) AVAudioSessionCategory category;
@property(nonatomic, assign) AVAudioSessionCategoryOptions categoryOptions;

/// Tracks whether setCategory:withOptions:error: has been called.
@property(nonatomic, assign) BOOL setCategoryCalled;
@end

@implementation TestAudioSession
- (BOOL)setCategory:(AVAudioSessionCategory)category
        withOptions:(AVAudioSessionCategoryOptions)options
              error:(NSError **)outError {
  self.setCategoryCalled = YES;
  self.category = category;
  self.categoryOptions = options;
  return YES;
}
@end
#endif

@interface StubFVPAVFactory : NSObject <FVPAVFactory>

@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) NSObject<FVPAVPlayerItem> *playerItem;
@property(nonatomic, strong) NSObject<FVPPixelBufferSource> *pixelBufferSource;
@property(nonatomic, strong) NSObject<FVPAVAudioSession> *audioSession;

@end

@implementation StubFVPAVFactory

// Creates a factory that returns the given items. Any items that are nil will instead return
// a real object just as the non-test implementation would.
- (instancetype)initWithPlayer:(nullable AVPlayer *)player
                    playerItem:(nullable NSObject<FVPAVPlayerItem> *)playerItem
             pixelBufferSource:(nullable NSObject<FVPPixelBufferSource> *)pixelBufferSource {
  self = [super init];
  // Create a player with a dummy item so that the player is valid, since most tests won't work
  // without a valid player.
  // TODO(stuartmorgan): Introduce a protocol for AVPlayer and use a stub here instead.
  _player =
      player
          ?: [[AVPlayer alloc]
                 initWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:@""]]];
  _playerItem = playerItem ?: [[StubPlayerItem alloc] init];
  _pixelBufferSource = pixelBufferSource;
  _audioSession = [[TestAudioSession alloc] init];
  return self;
}

- (NSObject<FVPAVAsset> *)URLAssetWithURL:(NSURL *)URL
                                  options:(nullable NSDictionary<NSString *, id> *)options {
  return self.playerItem.asset;
}

- (NSObject<FVPAVPlayerItem> *)playerItemWithAsset:(NSObject<FVPAVAsset> *)asset {
  return self.playerItem;
}

- (AVPlayer *)playerWithPlayerItem:(NSObject<FVPAVPlayerItem> *)playerItem {
  return self.player;
}

- (NSObject<FVPPixelBufferSource> *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes {
  return self.pixelBufferSource ?: [[TestPixelBufferSource alloc] init];
}

#if TARGET_OS_IOS
- (NSObject<FVPAVAudioSession> *)sharedAudioSession {
  return self.audioSession;
}
#endif

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
- (NSObject<FVPDisplayLink> *)displayLinkWithViewProvider:(NSObject<FVPViewProvider> *)viewProvider
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
  id<FVPViewProvider> viewProvider = [[StubViewProvider alloc] initWithView:view];
#else
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  UIViewController *viewController = [[UIViewController alloc] init];
  viewController.view = view;
  id<FVPViewProvider> viewProvider =
      [[StubViewProvider alloc] initWithViewController:viewController];
#endif
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                                                    playerItem:nil
                                                                             pixelBufferSource:nil]
                                   displayLinkFactory:nil
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:viewProvider
                                        assetProvider:[[StubAssetProvider alloc] init]];

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
  TestTextureRegistry *mockTextureRegistry = [[TestTextureRegistry alloc] init];
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                                                    playerItem:nil
                                                                             pixelBufferSource:nil]
                                   displayLinkFactory:stubDisplayLinkFactory
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:mockTextureRegistry
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];

  FlutterError *initializationError;
  [videoPlayerPlugin initialize:&initializationError];
  XCTAssertNil(initializationError);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
      httpHeaders:@{}];
  FlutterError *createError;
  [videoPlayerPlugin createPlatformViewPlayerWithOptions:create error:&createError];

  XCTAssertFalse(mockTextureRegistry.registeredTexture);
}

- (void)testSeekToWhilePausedStartsDisplayLinkTemporarily {
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  TestPixelBufferSource *mockVideoOutput = [[TestPixelBufferSource alloc] init];
  // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
  // the player via the plugin instead of directly to include that logic in the test.
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                       playerItem:nil
                                                pixelBufferSource:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
         binaryMessenger:[[StubBinaryMessenger alloc] init]
         textureRegistry:[[TestTextureRegistry alloc] init]
            viewProvider:[[StubViewProvider alloc] init]
           assetProvider:[[StubAssetProvider alloc] init]];

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
  CVPixelBufferRef bufferRef;
  CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
  mockVideoOutput.pixelBuffer = bufferRef;
  CVPixelBufferRelease(bufferRef);
  // Simulate a callback from the engine to request a new frame.
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  // Since a frame was found, and the video is paused, the display link should be paused again.
  XCTAssertFalse(stubDisplayLinkFactory.displayLink.running);
}

- (void)testInitStartsDisplayLinkTemporarily {
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  TestPixelBufferSource *mockVideoOutput = [[TestPixelBufferSource alloc] init];
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                       playerItem:nil
                                                pixelBufferSource:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
         binaryMessenger:[[StubBinaryMessenger alloc] init]
         textureRegistry:[[TestTextureRegistry alloc] init]
            viewProvider:[[StubViewProvider alloc] init]
           assetProvider:[[StubAssetProvider alloc] init]];

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
  CVPixelBufferRef bufferRef;
  CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
  mockVideoOutput.pixelBuffer = bufferRef;
  CVPixelBufferRelease(bufferRef);
  // Simulate a callback from the engine to request a new frame.
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(identifiers.playerId)];
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  // Since a frame was found, and the video is paused, the display link should be paused again.
  XCTAssertFalse(stubDisplayLinkFactory.displayLink.running);
}

- (void)testSeekToWhilePlayingDoesNotStopDisplayLink {
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  TestPixelBufferSource *mockVideoOutput = [[TestPixelBufferSource alloc] init];
  // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
  // the player via the plugin instead of directly to include that logic in the test.
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                       playerItem:nil
                                                pixelBufferSource:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
         binaryMessenger:[[StubBinaryMessenger alloc] init]
         textureRegistry:[[TestTextureRegistry alloc] init]
            viewProvider:[[StubViewProvider alloc] init]
           assetProvider:[[StubAssetProvider alloc] init]];

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
  CVPixelBufferRef bufferRef;
  CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
  mockVideoOutput.pixelBuffer = bufferRef;
  CVPixelBufferRelease(bufferRef);
  // Simulate a callback from the engine to request a new frame.
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  // Since the video was playing, the display link should not be paused after getting a buffer.
  XCTAssertTrue(stubDisplayLinkFactory.displayLink.running);
}

- (void)testPauseWhileWaitingForFrameDoesNotStopDisplayLink {
  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
  // the player via the plugin instead of directly to include that logic in the test.
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                                                    playerItem:nil
                                                                             pixelBufferSource:nil]
                                   displayLinkFactory:stubDisplayLinkFactory
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];

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
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                                                    playerItem:nil
                                                                             pixelBufferSource:nil]
                                   displayLinkFactory:nil
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];

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

  [player disposeWithError:&error];
  XCTAssertEqual(videoPlayerPlugin.playersByIdentifier.count, 0);
  XCTAssertNil(error);
}

- (void)testBufferingStateFromPlayer {
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:realObjectFactory
                                   displayLinkFactory:nil
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];

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
  InspectableAVPlayer *inspectableAVPlayer = [[InspectableAVPlayer alloc] init];
  StubFVPAVFactory *stubAVFactory = [[StubFVPAVFactory alloc] initWithPlayer:inspectableAVPlayer
                                                                  playerItem:nil
                                                           pixelBufferSource:nil];
  FVPVideoPlayer *player =
      [[FVPVideoPlayer alloc] initWithPlayerItem:[[StubPlayerItem alloc] init]
                                       avFactory:stubAVFactory
                                    viewProvider:[[StubViewProvider alloc] init]];
  NSObject<FVPVideoEventListener> *listener = [[StubEventListener alloc] init];
  player.eventListener = listener;

  XCTestExpectation *seekExpectation =
      [self expectationWithDescription:@"seekTo has zero tolerance when seeking not to end"];
  [player seekTo:1234
      completion:^(FlutterError *_Nullable error) {
        [seekExpectation fulfill];
      }];

  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  XCTAssertEqual([inspectableAVPlayer.beforeTolerance intValue], 0);
  XCTAssertEqual([inspectableAVPlayer.afterTolerance intValue], 0);
}

- (void)testSeekToleranceWhenSeekingToEnd {
  InspectableAVPlayer *inspectableAVPlayer = [[InspectableAVPlayer alloc] init];
  StubFVPAVFactory *stubAVFactory = [[StubFVPAVFactory alloc] initWithPlayer:inspectableAVPlayer
                                                                  playerItem:nil
                                                           pixelBufferSource:nil];
  FVPVideoPlayer *player =
      [[FVPVideoPlayer alloc] initWithPlayerItem:[[StubPlayerItem alloc] init]
                                       avFactory:stubAVFactory
                                    viewProvider:[[StubViewProvider alloc] init]];
  NSObject<FVPVideoEventListener> *listener = [[StubEventListener alloc] init];
  player.eventListener = listener;

  XCTestExpectation *seekExpectation =
      [self expectationWithDescription:@"seekTo has non-zero tolerance when seeking to end"];
  // The duration of this video is "0" due to the non standard initiliatazion process.
  [player seekTo:0
      completion:^(FlutterError *_Nullable error) {
        [seekExpectation fulfill];
      }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
  XCTAssertGreaterThan([inspectableAVPlayer.beforeTolerance intValue], 0);
  XCTAssertGreaterThan([inspectableAVPlayer.afterTolerance intValue], 0);
}

/// Sanity checks a video player playing the given URL with the actual AVPlayer. This is essentially
/// a mini integration test of the player component.
///
/// Returns the stub event listener to allow tests to inspect the call state.
- (StubEventListener *)sanityTestURI:(NSString *)testURI {
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  NSURL *testURL = [NSURL URLWithString:testURI];
  XCTAssertNotNil(testURL);
  FVPVideoPlayer *player = [[FVPVideoPlayer alloc]
      initWithPlayerItem:[self playerItemWithURL:testURL factory:realObjectFactory]
               avFactory:realObjectFactory
            viewProvider:[[StubViewProvider alloc] init]];
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
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];

  AVPlayer *avPlayer = nil;
  __weak FVPVideoPlayer *weakPlayer = nil;

  // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
  @autoreleasepool {
    FVPVideoPlayerPlugin *videoPlayerPlugin =
        [[FVPVideoPlayerPlugin alloc] initWithAVFactory:realObjectFactory
                                     displayLinkFactory:nil
                                        binaryMessenger:[[StubBinaryMessenger alloc] init]
                                        textureRegistry:[[TestTextureRegistry alloc] init]
                                           viewProvider:[[StubViewProvider alloc] init]
                                          assetProvider:[[StubAssetProvider alloc] init]];

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
  __weak FVPVideoPlayer *weakPlayer = nil;

  // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
  @autoreleasepool {
    FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
         initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                         playerItem:nil
                                                  pixelBufferSource:nil]
        displayLinkFactory:nil
           binaryMessenger:[[StubBinaryMessenger alloc] init]
           textureRegistry:[[TestTextureRegistry alloc] init]
              viewProvider:[[StubViewProvider alloc] init]
             assetProvider:[[StubAssetProvider alloc] init]];

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

- (void)testFailedToLoadVideoEventShouldBeAlwaysSent {
  // Use real objects to test a real failure flow.
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:realObjectFactory
                                   displayLinkFactory:nil
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];
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
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  FVPVideoPlayer *player = [[FVPVideoPlayer alloc]
      initWithPlayerItem:[self playerItemWithURL:self.mp4TestURL factory:realObjectFactory]
               avFactory:realObjectFactory
            viewProvider:[[StubViewProvider alloc] init]];

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
  TestTextureRegistry *mockTextureRegistry = [[TestTextureRegistry alloc] init];

  StubFVPDisplayLinkFactory *stubDisplayLinkFactory = [[StubFVPDisplayLinkFactory alloc] init];
  TestPixelBufferSource *mockVideoOutput = [[TestPixelBufferSource alloc] init];
  FVPVideoPlayerPlugin *videoPlayerPlugin = [[FVPVideoPlayerPlugin alloc]
       initWithAVFactory:[[StubFVPAVFactory alloc] initWithPlayer:nil
                                                       playerItem:nil
                                                pixelBufferSource:mockVideoOutput]
      displayLinkFactory:stubDisplayLinkFactory
         binaryMessenger:[[StubBinaryMessenger alloc] init]
         textureRegistry:mockTextureRegistry
            viewProvider:[[StubViewProvider alloc] init]
           assetProvider:[[StubAssetProvider alloc] init]];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);
  FVPCreationOptions *create = [FVPCreationOptions
      makeWithUri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
      httpHeaders:@{}];
  FVPTexturePlayerIds *identifiers = [videoPlayerPlugin createTexturePlayerWithOptions:create
                                                                                 error:&error];
  NSInteger playerIdentifier = identifiers.playerId;
  FVPTextureBasedVideoPlayer *player =
      (FVPTextureBasedVideoPlayer *)videoPlayerPlugin.playersByIdentifier[@(playerIdentifier)];

  void (^addFrame)(void) = ^{
    CVPixelBufferRef bufferRef;
    CVPixelBufferCreate(NULL, 1, 1, kCVPixelFormatType_32BGRA, NULL, &bufferRef);
    mockVideoOutput.pixelBuffer = bufferRef;
    CVPixelBufferRelease(bufferRef);
  };

  addFrame();
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  XCTAssertEqual(mockTextureRegistry.textureFrameAvailableCount, 1);

  addFrame();
  stubDisplayLinkFactory.fireDisplayLink();
  CFRelease([player copyPixelBuffer]);
  XCTAssertEqual(mockTextureRegistry.textureFrameAvailableCount, 2);
}

- (void)testVideoOutputIsAddedWhenAVPlayerItemBecomesReady {
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:realObjectFactory
                                   displayLinkFactory:nil
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];
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

  AVPlayerItem *item = player.player.currentItem;
  [self keyValueObservingExpectationForObject:(id)item
                                      keyPath:@"status"
                                expectedValue:@(AVPlayerItemStatusReadyToPlay)];
  [self waitForExpectationsWithTimeout:10.0 handler:nil];
  // Video output is added as soon as the status becomes ready to play.
  XCTAssertEqual(item.outputs.count, 1);
}

#if TARGET_OS_IOS
- (void)testVideoPlayerShouldNotOverwritePlayAndRecordNorDefaultToSpeaker {
  StubFVPAVFactory *stubFactory = [[StubFVPAVFactory alloc] initWithPlayer:nil
                                                                playerItem:nil
                                                         pixelBufferSource:nil];
  TestAudioSession *audioSession = [[TestAudioSession alloc] init];
  stubFactory.audioSession = audioSession;
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:stubFactory
                                   displayLinkFactory:nil
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];

  audioSession.category = AVAudioSessionCategoryPlayAndRecord;
  audioSession.categoryOptions = AVAudioSessionCategoryOptionDefaultToSpeaker;

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  [videoPlayerPlugin setMixWithOthers:true error:&error];
  XCTAssert(audioSession.category == AVAudioSessionCategoryPlayAndRecord,
            @"Category should be PlayAndRecord.");
  XCTAssert(audioSession.categoryOptions & AVAudioSessionCategoryOptionDefaultToSpeaker,
            @"Flag DefaultToSpeaker was removed.");
  XCTAssert(audioSession.categoryOptions & AVAudioSessionCategoryOptionMixWithOthers,
            @"Flag MixWithOthers should be set.");
}

- (void)testSetMixWithOthersShouldNoOpWhenNoChangesAreRequired {
  StubFVPAVFactory *stubFactory = [[StubFVPAVFactory alloc] initWithPlayer:nil
                                                                playerItem:nil
                                                         pixelBufferSource:nil];
  TestAudioSession *audioSession = [[TestAudioSession alloc] init];
  stubFactory.audioSession = audioSession;
  FVPVideoPlayerPlugin *videoPlayerPlugin =
      [[FVPVideoPlayerPlugin alloc] initWithAVFactory:stubFactory
                                   displayLinkFactory:nil
                                      binaryMessenger:[[StubBinaryMessenger alloc] init]
                                      textureRegistry:[[TestTextureRegistry alloc] init]
                                         viewProvider:[[StubViewProvider alloc] init]
                                        assetProvider:[[StubAssetProvider alloc] init]];

  audioSession.category = AVAudioSessionCategoryPlayAndRecord;
  audioSession.categoryOptions =
      AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker;

  FlutterError *error;
  [videoPlayerPlugin setMixWithOthers:true error:&error];

  XCTAssertFalse(audioSession.setCategoryCalled);
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

- (nonnull NSObject<FVPAVPlayerItem> *)playerItemWithURL:(NSURL *)url
                                                 factory:(NSObject<FVPAVFactory> *)factory {
  return [factory playerItemWithAsset:[factory URLAssetWithURL:url options:nil]];
}

#pragma mark - Audio Track Tests

// Tests getAudioTracks with a regular MP4 video file using real AVFoundation.
// Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
- (void)testGetAudioTracksWithRealMP4Video {
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  FVPVideoPlayer *player = [[FVPVideoPlayer alloc]
      initWithPlayerItem:[self playerItemWithURL:self.mp4TestURL factory:realObjectFactory]
               avFactory:realObjectFactory
            viewProvider:[[StubViewProvider alloc] init]];
  XCTAssertNotNil(player);

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"initialized"];
  StubEventListener *listener =
      [[StubEventListener alloc] initWithInitializationExpectation:initializedExpectation];
  player.eventListener = listener;
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Now test getAudioTracks
  FlutterError *error = nil;
  NSArray<FVPMediaSelectionAudioTrackData *> *result = [player getAudioTracks:&error];

  XCTAssertNil(error);
  XCTAssertNotNil(result);

  // Regular MP4 files do not have media selection groups for audio.
  // getAudioTracks only returns selectable audio tracks from HLS streams.
  XCTAssertEqual(result.count, 0);

  [player disposeWithError:&error];
}

// Tests getAudioTracks with an HLS stream using real AVFoundation.
// HLS streams use media selection groups for audio track selection.
- (void)testGetAudioTracksWithRealHLSStream {
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  NSURL *hlsURL = [NSURL
      URLWithString:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"];
  XCTAssertNotNil(hlsURL);

  FVPVideoPlayer *player = [[FVPVideoPlayer alloc]
      initWithPlayerItem:[self playerItemWithURL:hlsURL factory:realObjectFactory]
               avFactory:realObjectFactory
            viewProvider:[[StubViewProvider alloc] init]];
  XCTAssertNotNil(player);

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"initialized"];
  StubEventListener *listener =
      [[StubEventListener alloc] initWithInitializationExpectation:initializedExpectation];
  player.eventListener = listener;
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Now test getAudioTracks
  FlutterError *error = nil;
  NSArray<FVPMediaSelectionAudioTrackData *> *result = [player getAudioTracks:&error];

  XCTAssertNil(error);
  XCTAssertNotNil(result);

  // For HLS streams with multiple audio options, we get media selection tracks.
  // The bee.m3u8 stream may or may not have multiple audio tracks.
  // We verify the method returns valid data without crashing.
  for (FVPMediaSelectionAudioTrackData *track in result) {
    XCTAssertNotNil(track.displayName);
    XCTAssertGreaterThanOrEqual(track.index, 0);
  }

  [player disposeWithError:&error];
}

// Tests that getAudioTracks returns valid data for audio-only files.
// Regular audio files do not have media selection groups, so getAudioTracks returns an empty array.
- (void)testGetAudioTracksWithRealAudioFile {
  // TODO(stuartmorgan): Add more use of protocols in FVPVideoPlayer so that this test
  // can use a fake item/asset instead of loading an actual remote asset.
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  NSURL *audioURL = [NSURL
      URLWithString:@"https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3"];
  XCTAssertNotNil(audioURL);

  FVPVideoPlayer *player = [[FVPVideoPlayer alloc]
      initWithPlayerItem:[self playerItemWithURL:audioURL factory:realObjectFactory]
               avFactory:realObjectFactory
            viewProvider:[[StubViewProvider alloc] init]];
  XCTAssertNotNil(player);

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"initialized"];
  StubEventListener *listener =
      [[StubEventListener alloc] initWithInitializationExpectation:initializedExpectation];
  player.eventListener = listener;
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Now test getAudioTracks
  FlutterError *error = nil;
  NSArray<FVPMediaSelectionAudioTrackData *> *result = [player getAudioTracks:&error];

  XCTAssertNil(error);
  XCTAssertNotNil(result);

  // Regular audio files do not have media selection groups.
  // getAudioTracks only returns selectable audio tracks from HLS streams.
  XCTAssertEqual(result.count, 0);

  [player disposeWithError:&error];
}

// Tests that getAudioTracks works correctly through the plugin API with a real video.
// Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
- (void)testGetAudioTracksViaPluginWithRealVideo {
  // TODO(stuartmorgan): Add more use of protocols in FVPVideoPlayer so that this test
  // can use a fake item/asset instead of loading an actual remote asset.
  NSObject<FVPAVFactory> *realObjectFactory = [[FVPDefaultAVFactory alloc] init];
  NSURL *testURL =
      [NSURL URLWithString:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"];
  XCTAssertNotNil(testURL);
  FVPVideoPlayer *player = [[FVPVideoPlayer alloc]
      initWithPlayerItem:[self playerItemWithURL:testURL factory:realObjectFactory]
               avFactory:realObjectFactory
            viewProvider:[[StubViewProvider alloc] init]];

  // Wait for player item to become ready
  AVPlayerItem *item = player.player.currentItem;
  [self keyValueObservingExpectationForObject:(id)item
                                      keyPath:@"status"
                                expectedValue:@(AVPlayerItemStatusReadyToPlay)];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Now test getAudioTracks
  FlutterError *error;
  NSArray<FVPMediaSelectionAudioTrackData *> *result = [player getAudioTracks:&error];

  XCTAssertNil(error);
  XCTAssertNotNil(result);

  // Regular MP4 files do not have media selection groups.
  // getAudioTracks only returns selectable audio tracks from HLS streams.
  XCTAssertEqual(result.count, 0);

  [player disposeWithError:&error];
}

- (void)testLoadTracksWithMediaTypeIsCalledOnNewerOS {
  if (@available(iOS 15.0, macOS 12.0, *)) {
    TestAsset *mockAsset = [[TestAsset alloc] initWithDuration:CMTimeMake(1, 1) tracks:@[]];
    NSObject<FVPAVPlayerItem> *item = [[StubPlayerItem alloc] initWithAsset:mockAsset];

    StubFVPAVFactory *stubAVFactory = [[StubFVPAVFactory alloc] initWithPlayer:nil
                                                                    playerItem:item
                                                             pixelBufferSource:nil];
    StubViewProvider *stubViewProvider =
#if TARGET_OS_OSX
        [[StubViewProvider alloc] initWithView:nil];
#else
        [[StubViewProvider alloc] initWithViewController:nil];
#endif
    FVPVideoPlayer *player = [[FVPVideoPlayer alloc] initWithPlayerItem:item
                                                              avFactory:stubAVFactory
                                                           viewProvider:stubViewProvider];
    XCTAssertTrue(mockAsset.loadedTracksAsynchronously);
  }
}

@end
