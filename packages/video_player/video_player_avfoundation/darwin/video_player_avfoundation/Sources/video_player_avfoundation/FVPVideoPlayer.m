// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPVideoPlayer.h"
#import "./include/video_player_avfoundation/FVPVideoPlayer_Internal.h"

#import <GLKit/GLKit.h>

#import "./include/video_player_avfoundation/AVAssetTrackUtils.h"

static void *timeRangeContext = &timeRangeContext;
static void *statusContext = &statusContext;
static void *playbackLikelyToKeepUpContext = &playbackLikelyToKeepUpContext;
static void *rateContext = &rateContext;

@implementation FVPVideoPlayer
- (instancetype)initWithAsset:(NSString *)asset
                    avFactory:(id<FVPAVFactory>)avFactory
                 viewProvider:(NSObject<FVPViewProvider> *)viewProvider {
  return [self initWithURL:[NSURL fileURLWithPath:[FVPVideoPlayer absolutePathForAssetName:asset]]
               httpHeaders:@{}
                 avFactory:avFactory
              viewProvider:viewProvider];
}

- (instancetype)initWithURL:(NSURL *)url
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers
                  avFactory:(id<FVPAVFactory>)avFactory
               viewProvider:(NSObject<FVPViewProvider> *)viewProvider {
  NSDictionary<NSString *, id> *options = nil;
  if ([headers count] != 0) {
    options = @{@"AVURLAssetHTTPHeaderFieldsKey" : headers};
  }
  AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:options];
  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:urlAsset];
  return [self initWithPlayerItem:item avFactory:avFactory viewProvider:viewProvider];
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                         avFactory:(id<FVPAVFactory>)avFactory
                      viewProvider:(NSObject<FVPViewProvider> *)viewProvider {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");

  _viewProvider = viewProvider;

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
            self->_preferredTransform = FVPGetStandardizedTransformForTrack(videoTrack);
            // Do not use video composition when it is not needed.
            if (CGAffineTransformIsIdentity(self->_preferredTransform)) {
              return;
            }
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

  _player = [avFactory playerWithPlayerItem:item];
  _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

  // Configure output.
  NSDictionary *pixBuffAttributes = @{
    (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
    (id)kCVPixelBufferIOSurfacePropertiesKey : @{}
  };
  _videoOutput = [avFactory videoOutputWithPixelBufferAttributes:pixBuffAttributes];

  [self addObserversForItem:item player:_player];

  [asset loadValuesAsynchronouslyForKeys:@[ @"tracks" ] completionHandler:assetCompletionHandler];

  return self;
}

- (void)dealloc {
  if (!_disposed) {
    [self removeKeyValueObservers];
  }
}

/// This method allows you to dispose without touching the event channel. This
/// is useful for the case where the Engine is in the process of deconstruction
/// so the channel is going to die or is already dead.
- (void)disposeSansEventChannel {
  _disposed = YES;
  [self removeKeyValueObservers];

  [self.player replaceCurrentItemWithPlayerItem:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dispose {
  [self disposeSansEventChannel];
  if (_onDisposed) {
    _onDisposed();
  }
  [_eventChannel setStreamHandler:nil];
}

+ (NSString *)absolutePathForAssetName:(NSString *)assetName {
  NSString *path = [[NSBundle mainBundle] pathForResource:assetName ofType:nil];
#if TARGET_OS_OSX
  // See https://github.com/flutter/flutter/issues/135302
  // TODO(stuartmorgan): Remove this if the asset APIs are adjusted to work better for macOS.
  if (!path) {
    path = [NSURL URLWithString:assetName relativeToURL:NSBundle.mainBundle.bundleURL].path;
  }
#endif

  return path;
}

- (void)addObserversForItem:(AVPlayerItem *)item player:(AVPlayer *)player {
  [item addObserver:self
         forKeyPath:@"loadedTimeRanges"
            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
            context:timeRangeContext];
  [item addObserver:self
         forKeyPath:@"status"
            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
            context:statusContext];
  [item addObserver:self
         forKeyPath:@"playbackLikelyToKeepUp"
            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
            context:playbackLikelyToKeepUpContext];

  // Add observer to AVPlayer instead of AVPlayerItem since the AVPlayerItem does not have a "rate"
  // property
  [player addObserver:self
           forKeyPath:@"rate"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:rateContext];

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
    NSAssert([NSThread isMainThread], @"event sink must only be accessed from the main thread");
    if (_eventSink) {
      _eventSink(@{@"event" : @"completed"});
    }
  }
}

const int64_t TIME_UNSET = -9223372036854775807;

NS_INLINE int64_t FVPCMTimeToMillis(CMTime time) {
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

  videoComposition.sourceTrackIDForFrameTiming = videoTrack.trackID;
  if (CMTIME_IS_VALID(videoTrack.minFrameDuration)) {
    videoComposition.frameDuration = videoTrack.minFrameDuration;
  } else {
    NSLog(@"Warning: videoTrack.minFrameDuration for input video is invalid, please report this to "
          @"https://github.com/flutter/flutter/issues with input video attached.");
    videoComposition.frameDuration = CMTimeMake(1, 30);
  }

  return videoComposition;
}

- (void)observeValueForKeyPath:(NSString *)path
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  NSAssert([NSThread isMainThread], @"event sink must only be accessed from the main thread");
  if (context == timeRangeContext) {
    if (!_eventSink) {
      return;
    }
    NSMutableArray<NSArray<NSNumber *> *> *values = [[NSMutableArray alloc] init];
    for (NSValue *rangeValue in [object loadedTimeRanges]) {
      CMTimeRange range = [rangeValue CMTimeRangeValue];
      int64_t start = FVPCMTimeToMillis(range.start);
      [values addObject:@[ @(start), @(start + FVPCMTimeToMillis(range.duration)) ]];
    }
    _eventSink(@{@"event" : @"bufferingUpdate", @"values" : values});
  } else if (context == statusContext) {
    AVPlayerItem *item = (AVPlayerItem *)object;
    switch (item.status) {
      case AVPlayerItemStatusUnknown:
        break;
      case AVPlayerItemStatusReadyToPlay:
        [item addOutput:_videoOutput];
        if (_eventSink) {
          [self sendVideoInitializedEvent];
        }
        break;
      case AVPlayerItemStatusFailed:
        if (_eventSink) {
          [self sendFailedToLoadVideoEvent];
        }
        break;
    }
  } else if (context == playbackLikelyToKeepUpContext) {
    if (!_eventSink) {
      return;
    }
    [self updatePlayingState];
    NSString *event =
        [[_player currentItem] isPlaybackLikelyToKeepUp] ? @"bufferingEnd" : @"bufferingStart";
    _eventSink(@{@"event" : event});
  } else if (context == rateContext) {
    if (!_eventSink) {
      return;
    }
    // Important: Make sure to cast the object to AVPlayer when observing the rate property,
    // as it is not available in AVPlayerItem.
    AVPlayer *player = (AVPlayer *)object;
    _eventSink(@{@"event" : @"isPlayingStateUpdate", @"isPlaying" : player.rate > 0 ? @YES : @NO});
  }
}

- (void)updatePlayingState {
  if (!_isInitialized) {
    return;
  }
  if (_isPlaying) {
    // Calling play is the same as setting the rate to 1.0 (or to defaultRate depending on iOS
    // version) so last set playback speed must be set here if any instead.
    // https://github.com/flutter/flutter/issues/71264
    // https://github.com/flutter/flutter/issues/73643
    if (_targetPlaybackSpeed) {
      [self updateRate];
    } else {
      [_player play];
    }
  } else {
    [_player pause];
  }
}

/// Synchronizes the player's playback rate with targetPlaybackSpeed, constrained by the playback
/// rate capabilities of the player's current item.
- (void)updateRate {
  // See https://developer.apple.com/library/archive/qa/qa1772/_index.html for an explanation of
  // these checks.
  // If status is not AVPlayerItemStatusReadyToPlay then both canPlayFastForward
  // and canPlaySlowForward are always false and it is unknown whether video can
  // be played at these speeds, updatePlayingState will be called again when
  // status changes to AVPlayerItemStatusReadyToPlay.
  float speed = _targetPlaybackSpeed.floatValue;
  BOOL readyToPlay = _player.currentItem.status == AVPlayerItemStatusReadyToPlay;
  if (speed > 2.0 && !_player.currentItem.canPlayFastForward) {
    if (!readyToPlay) {
      return;
    }
    speed = 2.0;
  }
  if (speed < 1.0 && !_player.currentItem.canPlaySlowForward) {
    if (!readyToPlay) {
      return;
    }
    speed = 1.0;
  }
  _player.rate = speed;
}

- (void)sendFailedToLoadVideoEvent {
  NSAssert(_eventSink, @"sendFailedToLoadVideoEvent was called when the event sink was nil.");
  // Prefer more detailed error information from tracks loading.
  NSError *error;
  if ([self.player.currentItem.asset statusOfValueForKey:@"tracks"
                                                   error:&error] != AVKeyValueStatusFailed) {
    error = self.player.currentItem.error;
  }
  __block NSMutableOrderedSet<NSString *> *details =
      [NSMutableOrderedSet orderedSetWithObject:@"Failed to load video"];
  void (^add)(NSString *) = ^(NSString *detail) {
    if (detail != nil) {
      [details addObject:detail];
    }
  };
  NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
  add(error.localizedDescription);
  add(error.localizedFailureReason);
  add(underlyingError.localizedDescription);
  add(underlyingError.localizedFailureReason);
  NSString *message = [details.array componentsJoinedByString:@": "];
  _eventSink([FlutterError errorWithCode:@"VideoError" message:message details:nil]);
}

- (void)sendVideoInitializedEvent {
  AVPlayerItem *currentItem = self.player.currentItem;
  NSAssert(currentItem.status == AVPlayerItemStatusReadyToPlay,
           @"sendVideoInitializedEvent was called when the item wasn't ready to play.");
  NSAssert(_eventSink, @"sendVideoInitializedEvent was called when the event sink was nil.");
  NSAssert(!_isInitialized, @"sendVideoInitializedEvent should only be called once.");
  CGSize size = currentItem.presentationSize;
  CGFloat width = size.width;
  CGFloat height = size.height;

  _isInitialized = YES;
  [self updatePlayingState];
  _eventSink(@{
    @"event" : @"initialized",
    @"duration" : @(self.duration),
    @"width" : @(width),
    @"height" : @(height)
  });
}

#pragma mark - FVPVideoPlayerInstanceApi

- (void)playWithError:(FlutterError *_Nullable *_Nonnull)error {
  _isPlaying = YES;
  [self updatePlayingState];
}

- (void)pauseWithError:(FlutterError *_Nullable *_Nonnull)error {
  _isPlaying = NO;
  [self updatePlayingState];
}

- (nullable NSNumber *)position:(FlutterError *_Nullable *_Nonnull)error {
  return @(FVPCMTimeToMillis([_player currentTime]));
}

- (void)seekTo:(NSInteger)position completion:(void (^)(FlutterError *_Nullable))completion {
  CMTime targetCMTime = CMTimeMake(position, 1000);
  CMTimeValue duration = _player.currentItem.asset.duration.value;
  // Without adding tolerance when seeking to duration,
  // seekToTime will never complete, and this call will hang.
  // see issue https://github.com/flutter/flutter/issues/124475.
  CMTime tolerance = position == duration ? CMTimeMake(1, 1000) : kCMTimeZero;
  [_player seekToTime:targetCMTime
        toleranceBefore:tolerance
         toleranceAfter:tolerance
      completionHandler:^(BOOL completed) {
        if (completion) {
          dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
          });
        }
      }];
}

- (void)setLooping:(BOOL)looping error:(FlutterError *_Nullable *_Nonnull)error {
  _isLooping = looping;
}

- (void)setVolume:(double)volume error:(FlutterError *_Nullable *_Nonnull)error {
  _player.volume = (float)((volume < 0.0) ? 0.0 : ((volume > 1.0) ? 1.0 : volume));
}

- (void)setPlaybackSpeed:(double)speed error:(FlutterError *_Nullable *_Nonnull)error {
  _targetPlaybackSpeed = @(speed);
  [self updatePlayingState];
}

#pragma mark - FlutterStreamHandler

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  NSAssert([NSThread isMainThread], @"event sink must only be accessed from the main thread");
  _eventSink = nil;
  _isInitialized = NO;
  return nil;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  NSAssert([NSThread isMainThread], @"event sink must only be accessed from the main thread");
  _eventSink = events;
  switch (self.player.currentItem.status) {
    case AVPlayerItemStatusUnknown:
      // When this method is called when the media is still loading, do nothing:
      // sendVideoInitializedEvent or sendFailedToLoadVideoEvent will be called
      // by KVO on status updates.
      return nil;
    case AVPlayerItemStatusReadyToPlay:
      [self sendVideoInitializedEvent];
      return nil;
    case AVPlayerItemStatusFailed:
      [self sendFailedToLoadVideoEvent];
      return nil;
  }
}

#pragma mark - Private

- (int64_t)duration {
  // Note: https://openradar.appspot.com/radar?id=4968600712511488
  // `[AVPlayerItem duration]` can be `kCMTimeIndefinite`,
  // use `[[AVPlayerItem asset] duration]` instead.
  return FVPCMTimeToMillis([[[_player currentItem] asset] duration]);
}

/// Removes all key-value observers set up for the player.
///
/// This is called from dealloc, so must not use any methods on self.
- (void)removeKeyValueObservers {
  AVPlayerItem *currentItem = _player.currentItem;
  [currentItem removeObserver:self forKeyPath:@"status"];
  [currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
  [currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
  [_player removeObserver:self forKeyPath:@"rate"];
}

@end
