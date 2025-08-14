// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPVideoPlayer.h"
#import "./include/video_player_avfoundation/FVPVideoPlayer_Internal.h"

#import <GLKit/GLKit.h>

#import "./include/video_player_avfoundation/AVAssetTrackUtils.h"

static void *timeRangeContext = &timeRangeContext;
static void *statusContext = &statusContext;
static void *presentationSizeContext = &presentationSizeContext;
static void *durationContext = &durationContext;
static void *playbackLikelyToKeepUpContext = &playbackLikelyToKeepUpContext;
static void *rateContext = &rateContext;

/// Registers KVO observers on 'object' for each entry in 'observations', which must be a
/// dictionary mapping KVO keys to NSValue-wrapped context pointers.
///
/// This does not call any methods on 'observer', so is safe to call from 'observer's init.
static void FVPRegisterKeyValueObservers(NSObject *observer,
                                         NSDictionary<NSString *, NSValue *> *observations,
                                         NSObject *target) {
  // It is important not to use NSKeyValueObservingOptionInitial here, because that will cause
  // synchronous calls to 'observer', violating the requirement that this method does not call its
  // methods. If there are use cases for specific pieces of initial state, those should be handled
  // explicitly by the caller, rather than by adding initial-state KVO notifications here.
  for (NSString *key in observations) {
    [target addObserver:observer
             forKeyPath:key
                options:NSKeyValueObservingOptionNew
                context:observations[key].pointerValue];
  }
}

/// Registers KVO observers on 'object' for each entry in 'observations', which must be a
/// dictionary mapping KVO keys to NSValue-wrapped context pointers.
///
/// This should only be called to balance calls to FVPRegisterKeyValueObservers, as it is an
/// error to try to remove observers that are not currently set.
///
/// This does not call any methods on 'observer', so is safe to call from 'observer's dealloc.
static void FVPRemoveKeyValueObservers(NSObject *observer,
                                       NSDictionary<NSString *, NSValue *> *observations,
                                       NSObject *target) {
  for (NSString *key in observations) {
    [target removeObserver:observer forKeyPath:key];
  }
}

/// Returns a mapping of KVO keys to NSValue-wrapped observer context pointers for observations that
/// should be set for AVPlayer instances.
static NSDictionary<NSString *, NSValue *> *FVPGetPlayerObservations(void) {
  return @{
    @"rate" : [NSValue valueWithPointer:rateContext],
  };
}

/// Returns a mapping of KVO keys to NSValue-wrapped observer context pointers for observations that
/// should be set for AVPlayerItem instances.
static NSDictionary<NSString *, NSValue *> *FVPGetPlayerItemObservations(void) {
  return @{
    @"loadedTimeRanges" : [NSValue valueWithPointer:timeRangeContext],
    @"status" : [NSValue valueWithPointer:statusContext],
    @"presentationSize" : [NSValue valueWithPointer:presentationSizeContext],
    @"duration" : [NSValue valueWithPointer:durationContext],
    @"playbackLikelyToKeepUp" : [NSValue valueWithPointer:playbackLikelyToKeepUpContext],
  };
}

@implementation FVPVideoPlayer {
  // Whether or not player and player item listeners have ever been registered.
  BOOL _listenersRegistered;
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

  [asset loadValuesAsynchronouslyForKeys:@[ @"tracks" ] completionHandler:assetCompletionHandler];

  return self;
}

- (void)dealloc {
  if (_listenersRegistered && !_disposed) {
    // If dispose was never called for some reason, remove observers to prevent crashes.
    FVPRemoveKeyValueObservers(self, FVPGetPlayerItemObservations(), _player.currentItem);
    FVPRemoveKeyValueObservers(self, FVPGetPlayerObservations(), _player);
  }
}

- (void)dispose {
  // In some hot restart scenarios, dispose can be called twice, so no-op after the first time.
  if (_disposed) {
    return;
  }
  _disposed = YES;

  if (_listenersRegistered) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    FVPRemoveKeyValueObservers(self, FVPGetPlayerItemObservations(), self.player.currentItem);
    FVPRemoveKeyValueObservers(self, FVPGetPlayerObservations(), self.player);
  }

  [self.player replaceCurrentItemWithPlayerItem:nil];

  if (_onDisposed) {
    _onDisposed();
  }
  [self.eventListener videoPlayerWasDisposed];
}

- (void)setEventListener:(NSObject<FVPVideoEventListener> *)eventListener {
  _eventListener = eventListener;
  // The first time an event listener is set, set up video event listeners to relay status changes
  // changes to the event listener.
  if (eventListener && !_listenersRegistered) {
    AVPlayerItem *item = self.player.currentItem;
    // If the item is already ready to play, ensure that the intialized event is sent first.
    [self reportStatusForPlayerItem:item];
    // Set up all necessary observers to report video events.
    FVPRegisterKeyValueObservers(self, FVPGetPlayerItemObservations(), item);
    FVPRegisterKeyValueObservers(self, FVPGetPlayerObservations(), _player);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:item];
    _listenersRegistered = YES;
  }
}

- (void)itemDidPlayToEndTime:(NSNotification *)notification {
  if (_isLooping) {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
  } else {
    [self.eventListener videoPlayerDidComplete];
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
  if (context == timeRangeContext) {
    NSMutableArray<NSArray<NSNumber *> *> *values = [[NSMutableArray alloc] init];
    for (NSValue *rangeValue in [object loadedTimeRanges]) {
      CMTimeRange range = [rangeValue CMTimeRangeValue];
      [values addObject:@[
        @(FVPCMTimeToMillis(range.start)),
        @(FVPCMTimeToMillis(range.duration)),
      ]];
    }
    [self.eventListener videoPlayerDidUpdateBufferRegions:values];
  } else if (context == statusContext) {
    AVPlayerItem *item = (AVPlayerItem *)object;
    [self reportStatusForPlayerItem:item];
  } else if (context == presentationSizeContext || context == durationContext) {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if (item.status == AVPlayerItemStatusReadyToPlay) {
      // Due to an apparent bug, when the player item is ready, it still may not have determined
      // its presentation size or duration. When these properties are finally set, re-check if
      // all required properties and instantiate the event sink if it is not already set up.
      [self reportInitializedIfReadyToPlay];
    }
  } else if (context == playbackLikelyToKeepUpContext) {
    [self updatePlayingState];
    if ([[_player currentItem] isPlaybackLikelyToKeepUp]) {
      [self.eventListener videoPlayerDidEndBuffering];
    } else {
      [self.eventListener videoPlayerDidStartBuffering];
    }
  } else if (context == rateContext) {
    // Important: Make sure to cast the object to AVPlayer when observing the rate property,
    // as it is not available in AVPlayerItem.
    AVPlayer *player = (AVPlayer *)object;
    [self.eventListener videoPlayerDidSetPlaying:(player.rate > 0)];
  }
}

- (void)reportStatusForPlayerItem:(AVPlayerItem *)item {
  switch (item.status) {
    case AVPlayerItemStatusFailed:
      [self sendFailedToLoadVideoEvent];
      break;
    case AVPlayerItemStatusUnknown:
      break;
    case AVPlayerItemStatusReadyToPlay:
      [item addOutput:_videoOutput];
      [self reportInitializedIfReadyToPlay];
      break;
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
  [self.eventListener videoPlayerDidErrorWithMessage:message];
}

- (void)reportInitializedIfReadyToPlay {
  if (!_isInitialized) {
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
    // Audio-only HLS files have no size, so `currentItem.tracks.count` must be used to check for
    // track presence, as AVAsset does not always provide track information in HLS streams.
    BOOL hasNoTracks = currentItem.tracks.count == 0 && asset.tracks.count == 0;

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
    [self updatePlayingState];

    [self.eventListener videoPlayerDidInitializeWithDuration:duration size:size];
  }
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

#pragma mark - Private

- (int64_t)duration {
  // Note: https://openradar.appspot.com/radar?id=4968600712511488
  // `[AVPlayerItem duration]` can be `kCMTimeIndefinite`,
  // use `[[AVPlayerItem asset] duration]` instead.
  return FVPCMTimeToMillis([[[_player currentItem] asset] duration]);
}

@end
