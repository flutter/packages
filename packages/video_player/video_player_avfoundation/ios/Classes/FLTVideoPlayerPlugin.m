// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTVideoPlayerPlugin.h"

#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>

#import "AVAssetTrackUtils.h"
#import "messages.g.h"

#if !__has_feature(objc_arc)
#error Code Requires ARC.
#endif

@interface FLTFrameUpdater : NSObject
@property(nonatomic) int64_t textureId;
@property(nonatomic, weak, readonly) NSObject<FlutterTextureRegistry> *registry;
- (void)onDisplayLink:(CADisplayLink *)link;
@end

@implementation FLTFrameUpdater
- (FLTFrameUpdater *)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry {
    NSAssert(self, @"super init cannot be nil");
    if (self == nil) return nil;
    _registry = registry;
    return self;
}

- (void)onDisplayLink:(CADisplayLink *)link {
    [_registry textureFrameAvailable:_textureId];
}
@end

@interface FLTVideoPlayer : NSObject <FlutterTexture, FlutterStreamHandler>
@property(readonly, nonatomic) AVPlayer *player;
@property(readonly, nonatomic) AVPlayerItemVideoOutput *videoOutput;
// This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
// (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some video
// streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116).
// An invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
// for issue #1, and restore the correct width and height for issue #2.
@property(readonly, nonatomic) AVPlayerLayer *playerLayer;
@property(readonly, nonatomic) CADisplayLink *displayLink;
@property(nonatomic) FlutterEventChannel *eventChannel;
@property(nonatomic) FlutterEventSink eventSink;
@property(nonatomic) CGAffineTransform preferredTransform;
@property(nonatomic, readonly) BOOL disposed;
@property(nonatomic, readonly) BOOL isPlaying;
@property(nonatomic) BOOL isLooping;
@property(nonatomic, readonly) BOOL isInitialized;
- (instancetype)initWithURL:(NSURL *)url
               frameUpdater:(FLTFrameUpdater *)frameUpdater
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers;
@end

static void *timeRangeContext = &timeRangeContext;
static void *statusContext = &statusContext;
static void *presentationSizeContext = &presentationSizeContext;
static void *durationContext = &durationContext;
static void *playbackLikelyToKeepUpContext = &playbackLikelyToKeepUpContext;
static void *playbackBufferEmptyContext = &playbackBufferEmptyContext;
static void *playbackBufferFullContext = &playbackBufferFullContext;

@implementation FLTVideoPlayer
- (instancetype)initWithAsset:(NSString *)asset frameUpdater:(FLTFrameUpdater *)frameUpdater {
    NSString *path = [[NSBundle mainBundle] pathForResource:asset ofType:nil];
    return [self initWithURL:[NSURL fileURLWithPath:path] frameUpdater:frameUpdater httpHeaders:@{}];
}

- (void)addObservers:(AVPlayerItem *)item {
    [item addObserver:self
           forKeyPath:@"loadedTimeRanges"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:timeRangeContext];
    [item addObserver:self
           forKeyPath:@"status"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:statusContext];
    [item addObserver:self
           forKeyPath:@"presentationSize"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:presentationSizeContext];
    [item addObserver:self
           forKeyPath:@"duration"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:durationContext];
    [item addObserver:self
           forKeyPath:@"playbackLikelyToKeepUp"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:playbackLikelyToKeepUpContext];
    [item addObserver:self
           forKeyPath:@"playbackBufferEmpty"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:playbackBufferEmptyContext];
    [item addObserver:self
           forKeyPath:@"playbackBufferFull"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:playbackBufferFullContext];

    // Add an observer that will respond to itemDidPlayToEndTime
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:item];
}

- (void)itemDidPlayToEndTime:(NSNotification *)notification {
    if (_isLooping) {
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero completionHandler:nil];
    } else {
        if (_eventSink) {
            _eventSink(@{@"event" : @"completed"});
        }
    }
}

const int64_t TIME_UNSET = -9223372036854775807;

NS_INLINE int64_t FLTCMTimeToMillis(CMTime time) {
    // When CMTIME_IS_INDEFINITE return a value that matches TIME_UNSET from ExoPlayer2 on Android.
    // Fixes https://github.com/flutter/flutter/issues/48670
    if (CMTIME_IS_INDEFINITE(time)) return TIME_UNSET;
    if (time.timescale == 0) return 0;
    return time.value * 1000 / time.timescale;
}

NS_INLINE CGFloat radiansToDegrees(CGFloat radians) {
    // Input range [-pi, pi] or [-180, 180]
    CGFloat degrees = GLKMathRadiansToDegrees((float)radians);
    if (degrees < 0) {
        // Convert -90 to 270 and -180 to 180
        return degrees + 360;
    }
    // Output degrees in between [0, 360]
    return degrees;
};

NS_INLINE UIViewController *rootViewController() {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // TODO: (hellohuanlin) Provide a non-deprecated codepath. See
    // https://github.com/flutter/flutter/issues/104117
    return UIApplication.sharedApplication.keyWindow.rootViewController;
#pragma clang diagnostic pop
}

- (AVMutableVideoComposition *)getVideoCompositionWithTransform:(CGAffineTransform)transform
                                                      withAsset:(AVAsset *)asset
                                                 withVideoTrack:(AVAssetTrack *)videoTrack {
    AVMutableVideoCompositionInstruction *instruction =
            [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);
    AVMutableVideoCompositionLayerInstruction *layerInstruction =
            [AVMutableVideoCompositionLayerInstruction
                    videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInstruction setTransform:_preferredTransform atTime:kCMTimeZero];

    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    instruction.layerInstructions = @[ layerInstruction ];
    videoComposition.instructions = @[ instruction ];

    // If in portrait mode, switch the width and height of the video
    CGFloat width = videoTrack.naturalSize.width;
    CGFloat height = videoTrack.naturalSize.height;
    NSInteger rotationDegrees =
            (NSInteger)round(radiansToDegrees(atan2(_preferredTransform.b, _preferredTransform.a)));
    if (rotationDegrees == 90 || rotationDegrees == 270) {
        width = videoTrack.naturalSize.height;
        height = videoTrack.naturalSize.width;
    }
    videoComposition.renderSize = CGSizeMake(width, height);

    // TODO(@recastrodiaz): should we use videoTrack.nominalFrameRate ?
    // Currently set at a constant 30 FPS
    videoComposition.frameDuration = CMTimeMake(1, 30);

    return videoComposition;
}

- (void)createVideoOutputAndDisplayLink:(FLTFrameUpdater *)frameUpdater {
    NSDictionary *pixBuffAttributes = @{
            (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
            (id)kCVPixelBufferIOSurfacePropertiesKey : @{}
    };
    _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];

    _displayLink = [CADisplayLink displayLinkWithTarget:frameUpdater
                                               selector:@selector(onDisplayLink:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.paused = YES;
}

- (instancetype)initWithURL:(NSURL *)url
               frameUpdater:(FLTFrameUpdater *)frameUpdater
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers {
    NSDictionary<NSString *, id> *options = nil;
    if ([headers count] != 0) {
        options = @{@"AVURLAssetHTTPHeaderFieldsKey" : headers};
    }
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:options];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:urlAsset];
    return [self initWithPlayerItem:item frameUpdater:frameUpdater];
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                      frameUpdater:(FLTFrameUpdater *)frameUpdater {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");

    AVAsset *asset = [item asset];
    void (^assetCompletionHandler)(void) = ^{
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                AVAssetTrack *videoTrack = tracks[0];
                void (^trackCompletionHandler)(void) = ^{
                    if (self->_disposed) return;
                    if ([videoTrack statusOfValueForKey:@"preferredTransform"
                                                  error:nil] == AVKeyValueStatusLoaded) {
                        // Rotate the video by using a videoComposition and the preferredTransform
                        self->_preferredTransform = FLTGetStandardizedTransformForTrack(videoTrack);
                        // Note:
                        // https://developer.apple.com/documentation/avfoundation/avplayeritem/1388818-videocomposition
                        // Video composition can only be used with file-based media and is not supported for
                        // use with media served using HTTP Live Streaming.
                        AVMutableVideoComposition *videoComposition =
                                [self getVideoCompositionWithTransform:self->_preferredTransform
                                                             withAsset:asset
                                                        withVideoTrack:videoTrack];
                        item.videoComposition = videoComposition;
                    }
                };
                [videoTrack loadValuesAsynchronouslyForKeys:@[ @"preferredTransform" ]
                                          completionHandler:trackCompletionHandler];
            }
        }
    };

    _player = [AVPlayer playerWithPlayerItem:item];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

    // This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
    // (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
    // video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
    // invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
    // for issue #1, and restore the correct width and height for issue #2.
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [rootViewController().view.layer addSublayer:_playerLayer];

    [self createVideoOutputAndDisplayLink:frameUpdater];

    [self addObservers:item];

    [asset loadValuesAsynchronouslyForKeys:@[ @"tracks" ] completionHandler:assetCompletionHandler];

    return self;
}

- (void)observeValueForKeyPath:(NSString *)path
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == timeRangeContext) {
        if (_eventSink != nil) {
            NSMutableArray<NSArray<NSNumber *> *> *values = [[NSMutableArray alloc] init];
            for (NSValue *rangeValue in [object loadedTimeRanges]) {
                CMTimeRange range = [rangeValue CMTimeRangeValue];
                int64_t start = FLTCMTimeToMillis(range.start);
                int64_t durationStartAt = [self durationStartAt];
                // Androidを合わせる形で対応
                // iOSはライブ配信を開始した時間を元に計算してる
                // positionに対してbufferが行われている範囲を追加する
                // See Also: https://github.com/WinTicket/ios/blob/f81dc5e5c77cfb2e102277b1ebf5f3395ceda004/WinTicket/Sources/Components/Video/VideoState.swift#L313
                [values addObject:@[ @(start - durationStartAt), @(start + FLTCMTimeToMillis(range.duration) - durationStartAt) ]];
            }
            _eventSink(@{@"event" : @"bufferingUpdate", @"values" : values});
        }
    } else if (context == statusContext) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        switch (item.status) {
            case AVPlayerItemStatusFailed:
                if (_eventSink != nil) {
                    _eventSink([FlutterError
                                       errorWithCode:@"VideoError"
                                             message:[@"Failed to load video: "
                                                     stringByAppendingString:[item.error localizedDescription]]
                                             details:nil]);
                }
                break;
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                [item addOutput:_videoOutput];
                [self setupEventSinkIfReadyToPlay];
                [self updatePlayingState];
                break;
        }
    } else if (context == presentationSizeContext || context == durationContext) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            // Due to an apparent bug, when the player item is ready, it still may not have determined
            // its presentation size or duration. When these properties are finally set, re-check if
            // all required properties and instantiate the event sink if it is not already set up.
            [self setupEventSinkIfReadyToPlay];
            [self updatePlayingState];
        }
    } else if (context == playbackLikelyToKeepUpContext) {
        if ([[_player currentItem] isPlaybackLikelyToKeepUp]) {
            [self updatePlayingState];
            if (_eventSink != nil) {
                _eventSink(@{@"event" : @"bufferingEnd"});
            }
        }
    } else if (context == playbackBufferEmptyContext) {
        if (_eventSink != nil) {
            _eventSink(@{@"event" : @"bufferingStart"});
        }
    } else if (context == playbackBufferFullContext) {
        if (_eventSink != nil) {
            _eventSink(@{@"event" : @"bufferingEnd"});
        }
    }
}

- (void)updatePlayingState {
    if (!_isInitialized) {
        return;
    }
    if (_isPlaying) {
        [_player play];
    } else {
        [_player pause];
    }
    _displayLink.paused = !_isPlaying;
}

- (void)setupEventSinkIfReadyToPlay {
    if (_eventSink && !_isInitialized) {
        AVPlayerItem *currentItem = self.player.currentItem;
        CGSize size = currentItem.presentationSize;
        CGFloat width = size.width;
        CGFloat height = size.height;

        // Wait until tracks are loaded to check duration or if there are any videos.
        AVAsset *asset = currentItem.asset;
        if ([asset statusOfValueForKey:@"tracks" error:nil] != AVKeyValueStatusLoaded) {
            void (^trackCompletionHandler)(void) = ^{
                if ([asset statusOfValueForKey:@"tracks" error:nil] != AVKeyValueStatusLoaded) {
                    // Cancelled, or something failed.
                    return;
                }
                // This completion block will run on an AVFoundation background queue.
                // Hop back to the main thread to set up event sink.
                [self performSelector:_cmd onThread:NSThread.mainThread withObject:self waitUntilDone:NO];
            };
            [asset loadValuesAsynchronouslyForKeys:@[ @"tracks" ]
                                 completionHandler:trackCompletionHandler];
            return;
        }

        BOOL hasVideoTracks = [asset tracksWithMediaType:AVMediaTypeVideo].count != 0;
        BOOL hasNoTracks = asset.tracks.count == 0;

        // The player has not yet initialized when it has no size, unless it is an audio-only track.
        // HLS m3u8 video files never load any tracks, and are also not yet initialized until they have
        // a size.
        if ((hasVideoTracks || hasNoTracks) && height == CGSizeZero.height &&
            width == CGSizeZero.width) {
            return;
        }
        // The player may be initialized but still needs to determine the duration.
        int64_t duration = [self duration];
        if (duration == 0) {
            return;
        }

        _isInitialized = YES;
        _eventSink(@{
                           @"event" : @"initialized",
                           @"duration" : @(duration),
                           @"width" : @(width),
                           @"height" : @(height)
                   });
    }
}

- (void)play {
    _isPlaying = YES;
    [self updatePlayingState];
}

- (void)pause {
    _isPlaying = NO;
    [self updatePlayingState];
}

- (int64_t)position {
    return FLTCMTimeToMillis([_player currentTime]);
}

- (void)setBuffer:(double)buffer {
    AVPlayerItem *currentItem = self.player.currentItem;
    currentItem.preferredForwardBufferDuration = buffer;
}

- (BOOL)getLatestIsPlaying {
    return _player.rate > 0;
}

- (int64_t)duration {
    // AndroidのDurationはライブ配信と過去動画でいい感じに数字を返してくれるが
    // iOSでは
    // - ライブ配信: seekableTimeRanges
    // - mp4の動画: duration
    // を利用する必要がある。seekableTimeRangesが有無で条件分岐する
    NSValue *seekableRange = _player.currentItem.seekableTimeRanges.lastObject;
    if (seekableRange) {
        CMTimeRange seekableDuration = [seekableRange CMTimeRangeValue];
        return FLTCMTimeToMillis(seekableDuration.duration);
    }
    else {
        return FLTCMTimeToMillis(_player.currentItem.asset.duration);
    }
}

- (int64_t)durationStartAt {
    NSValue *seekableRange = _player.currentItem.seekableTimeRanges.lastObject;
    if (seekableRange) {
        CMTimeRange seekableDuration = [seekableRange CMTimeRangeValue];
        return FLTCMTimeToMillis(seekableDuration.start);
    }
    else {
        return FLTCMTimeToMillis(_player.currentItem.asset.duration);
    }
}

- (void)seekTo:(int)location completionHandler:(void (^)(BOOL))completionHandler  {
    // TODO(stuartmorgan): Update this to use completionHandler: to only return
    // once the seek operation is complete once the Pigeon API is updated to a
    // version that handles async calls.
    [_player seekToTime:CMTimeMake(location, 1000)
        toleranceBefore:kCMTimeZero
         toleranceAfter:kCMTimeZero
      completionHandler:completionHandler];
}

- (void)setIsLooping:(BOOL)isLooping {
    _isLooping = isLooping;
}

- (void)setVolume:(double)volume {
    _player.volume = (float)((volume < 0.0) ? 0.0 : ((volume > 1.0) ? 1.0 : volume));
}

- (void)setPlaybackSpeed:(double)speed {
    // See https://developer.apple.com/library/archive/qa/qa1772/_index.html for an explanation of
    // these checks.
    if (speed > 2.0 && !_player.currentItem.canPlayFastForward) {
        if (_eventSink != nil) {
            _eventSink([FlutterError errorWithCode:@"VideoError"
                                           message:@"Video cannot be fast-forwarded beyond 2.0x"
                                           details:nil]);
        }
        return;
    }

    if (speed < 1.0 && !_player.currentItem.canPlaySlowForward) {
        if (_eventSink != nil) {
            _eventSink([FlutterError errorWithCode:@"VideoError"
                                           message:@"Video cannot be slow-forwarded"
                                           details:nil]);
        }
        return;
    }

    _player.rate = speed;
}

- (CVPixelBufferRef)copyPixelBuffer {
    CMTime outputItemTime = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
    if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        return [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
    } else {
        return NULL;
    }
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dispose];
    });
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    // TODO(@recastrodiaz): remove the line below when the race condition is resolved:
    // https://github.com/flutter/flutter/issues/21483
    // This line ensures the 'initialized' event is sent when the event
    // 'AVPlayerItemStatusReadyToPlay' fires before _eventSink is set (this function
    // onListenWithArguments is called)
    [self setupEventSinkIfReadyToPlay];
    return nil;
}

/// This method allows you to dispose without touching the event channel.  This
/// is useful for the case where the Engine is in the process of deconstruction
/// so the channel is going to die or is already dead.
- (void)disposeSansEventChannel {
    _disposed = YES;
    [_playerLayer removeFromSuperlayer];
    [_displayLink invalidate];
    AVPlayerItem *currentItem = self.player.currentItem;
    [currentItem removeObserver:self forKeyPath:@"status"];
    [currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [currentItem removeObserver:self forKeyPath:@"presentationSize"];
    [currentItem removeObserver:self forKeyPath:@"duration"];
    [currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];

    [self.player replaceCurrentItemWithPlayerItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dispose {
    [self disposeSansEventChannel];
    [_eventChannel setStreamHandler:nil];
}

@end

@interface FLTVideoPlayerPlugin () <FLTAVFoundationVideoPlayerApi>
@property(readonly, weak, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, weak, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, strong, nonatomic)
NSMutableDictionary<NSNumber *, FLTVideoPlayer *> *playersByTextureId;
@property(readonly, strong, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@end

@implementation FLTVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FLTVideoPlayerPlugin *instance = [[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];
    [registrar publish:instance];
    FLTAVFoundationVideoPlayerApiSetup(registrar.messenger, instance);
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _registry = [registrar textures];
    _messenger = [registrar messenger];
    _registrar = registrar;
    _playersByTextureId = [NSMutableDictionary dictionaryWithCapacity:1];
    return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    [self.playersByTextureId.allValues makeObjectsPerformSelector:@selector(disposeSansEventChannel)];
    [self.playersByTextureId removeAllObjects];
    // TODO(57151): This should be commented out when 57151's fix lands on stable.
    // This is the correct behavior we never did it in the past and the engine
    // doesn't currently support it.
    // FLTAVFoundationVideoPlayerApiSetup(registrar.messenger, nil);
}

- (FLTTextureMessage *)onPlayerSetup:(FLTVideoPlayer *)player
                        frameUpdater:(FLTFrameUpdater *)frameUpdater {
    int64_t textureId = [self.registry registerTexture:player];
    frameUpdater.textureId = textureId;
    FlutterEventChannel *eventChannel = [FlutterEventChannel
            eventChannelWithName:[NSString stringWithFormat:@"flutter.io/videoPlayer/videoEvents%lld",
                                                            textureId]
                 binaryMessenger:_messenger];
    [eventChannel setStreamHandler:player];
    player.eventChannel = eventChannel;
    self.playersByTextureId[@(textureId)] = player;
    FLTTextureMessage *result = [FLTTextureMessage makeWithTextureId:@(textureId)];
    return result;
}

- (void)initialize:(FlutterError *__autoreleasing *)error {
    // Allow audio playback when the Ring/Silent switch is set to silent
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    [self.playersByTextureId
            enumerateKeysAndObjectsUsingBlock:^(NSNumber *textureId, FLTVideoPlayer *player, BOOL *stop) {
                [self.registry unregisterTexture:textureId.unsignedIntegerValue];
                [player dispose];
            }];
    [self.playersByTextureId removeAllObjects];
}

- (FLTTextureMessage *)create:(FLTCreateMessage *)input error:(FlutterError **)error {
    FLTFrameUpdater *frameUpdater = [[FLTFrameUpdater alloc] initWithRegistry:_registry];
    FLTVideoPlayer *player;
    if (input.asset) {
        NSString *assetPath;
        if (input.packageName) {
            assetPath = [_registrar lookupKeyForAsset:input.asset fromPackage:input.packageName];
        } else {
            assetPath = [_registrar lookupKeyForAsset:input.asset];
        }
        player = [[FLTVideoPlayer alloc] initWithAsset:assetPath frameUpdater:frameUpdater];
        return [self onPlayerSetup:player frameUpdater:frameUpdater];
    } else if (input.uri) {
        player = [[FLTVideoPlayer alloc] initWithURL:[NSURL URLWithString:input.uri]
                                        frameUpdater:frameUpdater
                                         httpHeaders:input.httpHeaders];
        return [self onPlayerSetup:player frameUpdater:frameUpdater];
    } else {
        *error = [FlutterError errorWithCode:@"video_player" message:@"not implemented" details:nil];
        return nil;
    }
}

- (void)dispose:(FLTTextureMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    [self.registry unregisterTexture:input.textureId.intValue];
    [self.playersByTextureId removeObjectForKey:input.textureId];
    // If the Flutter contains https://github.com/flutter/engine/pull/12695,
    // the `player` is disposed via `onTextureUnregistered` at the right time.
    // Without https://github.com/flutter/engine/pull/12695, there is no guarantee that the
    // texture has completed the un-reregistration. It may leads a crash if we dispose the
    // `player` before the texture is unregistered. We add a dispatch_after hack to make sure the
    // texture is unregistered before we dispose the `player`.
    //
    // TODO(cyanglaz): Remove this dispatch block when
    // https://github.com/flutter/flutter/commit/8159a9906095efc9af8b223f5e232cb63542ad0b is in
    // stable And update the min flutter version of the plugin to the stable version.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                if (!player.disposed) {
                    [player dispose];
                }
            });
}

- (void)setLooping:(FLTLoopingMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    player.isLooping = input.isLooping.boolValue;
}

- (void)setVolume:(FLTVolumeMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    [player setVolume:input.volume.doubleValue];
}

- (void)setPlaybackSpeed:(FLTPlaybackSpeedMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    [player setPlaybackSpeed:input.speed.doubleValue];
}

- (void)play:(FLTTextureMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    [player play];
}

- (FLTPositionMessage *)position:(FLTTextureMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    FLTPositionMessage *result = [FLTPositionMessage makeWithTextureId:input.textureId
                                                              position:@([player position])];
    return result;
}

- (FLTDurationMessage *)duration:(FLTTextureMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    FLTDurationMessage *result = [FLTDurationMessage makeWithTextureId:input.textureId
                                                              duration:@([player duration])];
    return result;
}

- (FLTStartMessage *)start:(FLTTextureMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    FLTStartMessage *result = [FLTStartMessage makeWithTextureId:input.textureId
                                                           start:@([player durationStartAt])];
    return result;
}

- (void)seekTo:(FLTPositionMessage *)msg completion:(void(^)(FlutterError *_Nullable))completion {
    FLTVideoPlayer *player = self.playersByTextureId[msg.textureId];
    [player seekTo:msg.position.intValue completionHandler:^(BOOL isFinished) {
        if (completion) {
            completion(nil);
        }
    }];
    [self.registry textureFrameAvailable:msg.textureId.intValue];
}

- (void)pause:(FLTTextureMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    [player pause];
}

- (void)setMixWithOthers:(FLTMixWithOthersMessage *)input
                   error:(FlutterError *_Nullable __autoreleasing *)error {
    if (input.mixWithOthers.boolValue) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                         withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                               error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)setBuffer:(FLTBufferMessage *)input error:(FlutterError *_Nullable *_Nonnull)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    [player setBuffer:input.second.doubleValue];
}

- (FLTIsPlayingMessage *)isPlaying:(FLTTextureMessage *)input error:(FlutterError **)error {
    FLTVideoPlayer *player = self.playersByTextureId[input.textureId];
    FLTIsPlayingMessage *result = [FLTIsPlayingMessage makeWithTextureId:input.textureId
                                                               isPlaying:@([player getLatestIsPlaying])];
    return result;
}

@end
