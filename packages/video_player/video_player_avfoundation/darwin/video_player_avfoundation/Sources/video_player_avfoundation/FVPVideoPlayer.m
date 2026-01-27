// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPVideoPlayer.h"
#import "./include/video_player_avfoundation/FVPVideoPlayer_Internal.h"

#import <GLKit/GLKit.h>
#if TARGET_OS_IOS
#import <MediaPlayer/MediaPlayer.h>
#endif

#import "./include/video_player_avfoundation/AVAssetTrackUtils.h"

static void *timeRangeContext = &timeRangeContext;
static void *statusContext = &statusContext;
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
    @"playbackLikelyToKeepUp" : [NSValue valueWithPointer:playbackLikelyToKeepUpContext],
  };
}

@implementation FVPVideoPlayer {
  // Whether or not player and player item listeners have ever been registered.
  BOOL _listenersRegistered;

  // Background playback support
  BOOL _enableBackgroundPlayback;
  FVPNotificationMetadataMessage *_notificationMetadata;
#if TARGET_OS_IOS
  id _timeObserver;
#endif
}

- (instancetype)initWithPlayerItem:(NSObject<FVPAVPlayerItem> *)item
                         avFactory:(id<FVPAVFactory>)avFactory
                      viewProvider:(NSObject<FVPViewProvider> *)viewProvider {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");

  _viewProvider = viewProvider;

  NSObject<FVPAVAsset> *asset = item.asset;
  void (^assetCompletionHandler)(void) = ^{
    if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
      void (^processVideoTracks)(NSArray<AVAssetTrack *> *) = ^(NSArray<AVAssetTrack *> *tracks) {
        if ([tracks count] > 0) {
          AVAssetTrack *videoTrack = tracks[0];
          void (^trackCompletionHandler)(void) = ^{
            if (self->_disposed) return;
            if ([videoTrack statusOfValueForKey:@"preferredTransform"
                                          error:nil] == AVKeyValueStatusLoaded) {
              // Rotate the video by using a videoComposition and the preferredTransform
              self->_preferredTransform = FVPGetStandardizedTrackTransform(
                  videoTrack.preferredTransform, videoTrack.naturalSize);
              // Do not use video composition when it is not needed.
              if (CGAffineTransformIsIdentity(self->_preferredTransform)) {
                return;
              }
              // Note:
              // https://developer.apple.com/documentation/avfoundation/avplayeritem/1388818-videocomposition
              // Video composition can only be used with file-based media and is not supported for
              // use with media served using HTTP Live Streaming.
              AVMutableVideoComposition *videoComposition =
                  [self videoCompositionWithTransform:self->_preferredTransform
                                                asset:asset
                                           videoTrack:videoTrack];
              item.videoComposition = videoComposition;
            }
          };
          [videoTrack loadValuesAsynchronouslyForKeys:@[ @"preferredTransform" ]
                                    completionHandler:trackCompletionHandler];
        }
      };

      // Use the new async API on iOS 15.0+/macOS 12.0+, fall back to deprecated API on older
      // versions
      if (@available(iOS 15.0, macOS 12.0, *)) {
        [asset loadTracksWithMediaType:AVMediaTypeVideo
                     completionHandler:^(NSArray<AVAssetTrack *> *_Nullable tracks,
                                         NSError *_Nullable error) {
                       if (error == nil && tracks != nil) {
                         processVideoTracks(tracks);
                       } else if (error != nil) {
                         NSLog(@"Error loading tracks: %@", error);
                       }
                     }];
      } else {
        // For older OS versions, use the deprecated API with warning suppression
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
        processVideoTracks(tracks);
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
  _pixelBufferSource = [avFactory videoOutputWithPixelBufferAttributes:pixBuffAttributes];

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

- (void)disposeWithError:(FlutterError *_Nullable *_Nonnull)error {
  // In some hot restart scenarios, dispose can be called twice, so no-op after the first time.
  if (_disposed) {
    return;
  }
  _disposed = YES;

  // Clean up background playback resources
#if TARGET_OS_IOS
  if (_enableBackgroundPlayback) {
    [self teardownRemoteCommandCenter];
    [self clearNowPlayingInfo];
    [self removeTimeObserver];
  }
#endif

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

- (AVMutableVideoComposition *)videoCompositionWithTransform:(CGAffineTransform)transform
                                                       asset:(NSObject<FVPAVAsset> *)asset
                                                  videoTrack:(AVAssetTrack *)videoTrack {
  AVMutableVideoCompositionInstruction *instruction =
      [AVMutableVideoCompositionInstruction videoCompositionInstruction];
  instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
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
  NSAssert(self.eventListener,
           @"reportStatusForPlayerItem was called when the event listener was not set.");
  switch (item.status) {
    case AVPlayerItemStatusFailed:
      [self sendFailedToLoadVideoEvent];
      break;
    case AVPlayerItemStatusUnknown:
      break;
    case AVPlayerItemStatusReadyToPlay:
      if (!_isInitialized) {
        [item addOutput:self.pixelBufferSource.videoOutput];
        [self reportInitialized];
        [self updatePlayingState];
      }
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

- (void)reportInitialized {
  AVPlayerItem *currentItem = self.player.currentItem;
  NSAssert(currentItem.status == AVPlayerItemStatusReadyToPlay,
           @"reportInitializedIfReadyToPlay was called when the item wasn't ready to play.");
  NSAssert(!_isInitialized, @"reportInitializedIfReadyToPlay should only be called once.");

  _isInitialized = YES;
  [self.eventListener videoPlayerDidInitializeWithDuration:self.duration
                                                      size:currentItem.presentationSize];
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

- (nullable NSArray<FVPMediaSelectionAudioTrackData *> *)getAudioTracks:
    (FlutterError *_Nullable *_Nonnull)error {
  AVPlayerItem *currentItem = _player.currentItem;
  NSAssert(currentItem, @"currentItem should not be nil");
  AVAsset *asset = currentItem.asset;

  // Get tracks from media selection (for HLS streams)
  AVMediaSelectionGroup *audioGroup =
      [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible];

  NSMutableArray<FVPMediaSelectionAudioTrackData *> *mediaSelectionTracks =
      [[NSMutableArray alloc] init];

  if (audioGroup.options.count > 0) {
    AVMediaSelection *mediaSelection = currentItem.currentMediaSelection;
    AVMediaSelectionOption *currentSelection =
        [mediaSelection selectedMediaOptionInMediaSelectionGroup:audioGroup];

    for (NSInteger i = 0; i < audioGroup.options.count; i++) {
      AVMediaSelectionOption *option = audioGroup.options[i];
      NSString *displayName = option.displayName;

      NSString *languageCode = nil;
      if (option.locale) {
        languageCode = option.locale.languageCode;
      }

      NSArray<AVMetadataItem *> *titleItems =
          [AVMetadataItem metadataItemsFromArray:option.commonMetadata
                                         withKey:AVMetadataCommonKeyTitle
                                        keySpace:AVMetadataKeySpaceCommon];
      NSString *commonMetadataTitle = titleItems.firstObject.stringValue;

      BOOL isSelected = [currentSelection isEqual:option];

      FVPMediaSelectionAudioTrackData *trackData =
          [FVPMediaSelectionAudioTrackData makeWithIndex:i
                                             displayName:displayName
                                            languageCode:languageCode
                                              isSelected:isSelected
                                     commonMetadataTitle:commonMetadataTitle];

      [mediaSelectionTracks addObject:trackData];
    }
  }

  return mediaSelectionTracks;
}

- (void)selectAudioTrackAtIndex:(NSInteger)trackIndex
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  AVPlayerItem *currentItem = _player.currentItem;
  NSAssert(currentItem, @"currentItem should not be nil");
  AVAsset *asset = currentItem.asset;

  AVMediaSelectionGroup *audioGroup =
      [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible];

  if (audioGroup && trackIndex >= 0 && trackIndex < (NSInteger)audioGroup.options.count) {
    AVMediaSelectionOption *option = audioGroup.options[trackIndex];
    [currentItem selectMediaOption:option inMediaSelectionGroup:audioGroup];
  }
}

- (void)setBackgroundPlayback:(FVPBackgroundPlaybackMessage *)msg
                        error:(FlutterError *_Nullable *_Nonnull)error {
  _enableBackgroundPlayback = msg.enableBackground;
  _notificationMetadata = msg.notificationMetadata;

#if TARGET_OS_IOS
  if (_enableBackgroundPlayback) {
    // Configure audio session for background playback
    NSError *audioError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback
                         mode:AVAudioSessionModeMoviePlayback
                      options:0
                        error:&audioError];
    if (audioError) {
      NSLog(@"Error setting audio session category: %@", audioError);
    }

    [audioSession setActive:YES error:&audioError];
    if (audioError) {
      NSLog(@"Error activating audio session: %@", audioError);
    }

    // iOS 15+: Enable seamless background playback without layer disconnection
    if (@available(iOS 15.0, macOS 12.0, *)) {
      _player.audiovisualBackgroundPlaybackPolicy =
          AVPlayerAudiovisualBackgroundPlaybackPolicyContinuesIfPossible;
    }

    // Set up remote command center for media controls
    [self setupRemoteCommandCenter];

    // Update Now Playing info if metadata is provided
    if (_notificationMetadata) {
      [self updateNowPlayingInfo];
      [self setupTimeObserver];
    }
  } else {
    // Disable background playback
    [self teardownRemoteCommandCenter];
    [self clearNowPlayingInfo];
    [self removeTimeObserver];

    // iOS 15+: Reset background playback policy to automatic (default)
    if (@available(iOS 15.0, macOS 12.0, *)) {
      _player.audiovisualBackgroundPlaybackPolicy =
          AVPlayerAudiovisualBackgroundPlaybackPolicyAutomatic;
    }

    // Deactivate audio session to release audio hardware
    NSError *audioError = nil;
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&audioError];
    if (audioError) {
      NSLog(@"Error deactivating audio session: %@", audioError);
    }
  }
#else
  // macOS doesn't support MPNowPlayingInfoCenter in the same way
  // Background audio works differently on macOS
  if (_enableBackgroundPlayback) {
    NSLog(@"Background playback enabled (macOS - limited support)");
  }
#endif
}

- (void)updateNotificationMetadata:(FVPNotificationMetadataMessage *)msg
                             error:(FlutterError *_Nullable *_Nonnull)error {
  _notificationMetadata = msg;

#if TARGET_OS_IOS
  if (_enableBackgroundPlayback && _notificationMetadata) {
    [self updateNowPlayingInfo];
  }
#endif
}

#if TARGET_OS_IOS
- (void)setupRemoteCommandCenter {
  MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

  // Play command
  [commandCenter.playCommand setEnabled:YES];
  [commandCenter.playCommand addTarget:self action:@selector(handlePlayCommand:)];

  // Pause command
  [commandCenter.pauseCommand setEnabled:YES];
  [commandCenter.pauseCommand addTarget:self action:@selector(handlePauseCommand:)];

  // Toggle play/pause command
  [commandCenter.togglePlayPauseCommand setEnabled:YES];
  [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(handleTogglePlayPauseCommand:)];

  // Change playback position command (seeking)
  [commandCenter.changePlaybackPositionCommand setEnabled:YES];
  [commandCenter.changePlaybackPositionCommand addTarget:self
                                                  action:@selector(handleChangePlaybackPositionCommand:)];

  // Skip forward command
  [commandCenter.skipForwardCommand setEnabled:YES];
  commandCenter.skipForwardCommand.preferredIntervals = @[ @15 ];
  [commandCenter.skipForwardCommand addTarget:self action:@selector(handleSkipForwardCommand:)];

  // Skip backward command
  [commandCenter.skipBackwardCommand setEnabled:YES];
  commandCenter.skipBackwardCommand.preferredIntervals = @[ @15 ];
  [commandCenter.skipBackwardCommand addTarget:self action:@selector(handleSkipBackwardCommand:)];
}

- (MPRemoteCommandHandlerStatus)handlePlayCommand:(MPRemoteCommandEvent *)event {
  _isPlaying = YES;
  [self updatePlayingState];
  [self updateNowPlayingPlaybackState];
  return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePauseCommand:(MPRemoteCommandEvent *)event {
  _isPlaying = NO;
  [self updatePlayingState];
  [self updateNowPlayingPlaybackState];
  return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleTogglePlayPauseCommand:(MPRemoteCommandEvent *)event {
  _isPlaying = !_isPlaying;
  [self updatePlayingState];
  [self updateNowPlayingPlaybackState];
  return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleChangePlaybackPositionCommand:(MPRemoteCommandEvent *)event {
  MPChangePlaybackPositionCommandEvent *positionEvent = (MPChangePlaybackPositionCommandEvent *)event;
  CMTime targetTime = CMTimeMakeWithSeconds(positionEvent.positionTime, NSEC_PER_SEC);
  [_player seekToTime:targetTime
      completionHandler:^(BOOL finished) {
        if (finished) {
          [self updateNowPlayingPlaybackState];
        }
      }];
  return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleSkipForwardCommand:(MPRemoteCommandEvent *)event {
  MPSkipIntervalCommandEvent *skipEvent = (MPSkipIntervalCommandEvent *)event;
  CMTime currentTime = _player.currentTime;
  CMTime skipTime = CMTimeMakeWithSeconds(skipEvent.interval, NSEC_PER_SEC);
  CMTime newTime = CMTimeAdd(currentTime, skipTime);
  [_player seekToTime:newTime
      completionHandler:^(BOOL finished) {
        if (finished) {
          [self updateNowPlayingPlaybackState];
        }
      }];
  return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleSkipBackwardCommand:(MPRemoteCommandEvent *)event {
  MPSkipIntervalCommandEvent *skipEvent = (MPSkipIntervalCommandEvent *)event;
  CMTime currentTime = _player.currentTime;
  CMTime skipTime = CMTimeMakeWithSeconds(skipEvent.interval, NSEC_PER_SEC);
  CMTime newTime = CMTimeSubtract(currentTime, skipTime);
  [_player seekToTime:newTime
      completionHandler:^(BOOL finished) {
        if (finished) {
          [self updateNowPlayingPlaybackState];
        }
      }];
  return MPRemoteCommandHandlerStatusSuccess;
}

- (void)teardownRemoteCommandCenter {
  MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

  [commandCenter.playCommand removeTarget:self action:@selector(handlePlayCommand:)];
  [commandCenter.pauseCommand removeTarget:self action:@selector(handlePauseCommand:)];
  [commandCenter.togglePlayPauseCommand removeTarget:self action:@selector(handleTogglePlayPauseCommand:)];
  [commandCenter.changePlaybackPositionCommand removeTarget:self
                                                     action:@selector(handleChangePlaybackPositionCommand:)];
  [commandCenter.skipForwardCommand removeTarget:self action:@selector(handleSkipForwardCommand:)];
  [commandCenter.skipBackwardCommand removeTarget:self action:@selector(handleSkipBackwardCommand:)];

  [commandCenter.playCommand setEnabled:NO];
  [commandCenter.pauseCommand setEnabled:NO];
  [commandCenter.togglePlayPauseCommand setEnabled:NO];
  [commandCenter.changePlaybackPositionCommand setEnabled:NO];
  [commandCenter.skipForwardCommand setEnabled:NO];
  [commandCenter.skipBackwardCommand setEnabled:NO];
}

- (void)updateNowPlayingInfo {
  if (!_notificationMetadata) {
    return;
  }

  NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];

  // Set title
  if (_notificationMetadata.title) {
    nowPlayingInfo[MPMediaItemPropertyTitle] = _notificationMetadata.title;
  }

  // Set artist
  if (_notificationMetadata.artist) {
    nowPlayingInfo[MPMediaItemPropertyArtist] = _notificationMetadata.artist;
  }

  // Set album
  if (_notificationMetadata.album) {
    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = _notificationMetadata.album;
  }

  // Set duration
  NSNumber *durationMs = _notificationMetadata.durationMs;
  if (durationMs) {
    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = @(durationMs.doubleValue / 1000.0);
  } else {
    // Use the actual video duration
    CMTime duration = _player.currentItem.asset.duration;
    if (CMTIME_IS_VALID(duration) && !CMTIME_IS_INDEFINITE(duration)) {
      nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = @(CMTimeGetSeconds(duration));
    }
  }

  // Set current playback position
  CMTime currentTime = _player.currentTime;
  if (CMTIME_IS_VALID(currentTime)) {
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(CMTimeGetSeconds(currentTime));
  }

  // Set playback rate
  nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = @(_isPlaying ? _player.rate : 0.0);

  // Load artwork asynchronously if provided
  if (_notificationMetadata.artUri) {
    [self loadArtworkFromUri:_notificationMetadata.artUri
                  completion:^(MPMediaItemArtwork *artwork) {
                    if (artwork) {
                      NSMutableDictionary *info =
                          [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo mutableCopy];
                      if (info) {
                        info[MPMediaItemPropertyArtwork] = artwork;
                        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
                      }
                    }
                  }];
  }

  [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

- (void)updateNowPlayingPlaybackState {
  NSMutableDictionary *nowPlayingInfo =
      [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo mutableCopy];
  if (!nowPlayingInfo) {
    return;
  }

  // Update elapsed time
  CMTime currentTime = _player.currentTime;
  if (CMTIME_IS_VALID(currentTime)) {
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(CMTimeGetSeconds(currentTime));
  }

  // Update playback rate
  nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = @(_isPlaying ? _player.rate : 0.0);

  [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

- (void)clearNowPlayingInfo {
  [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
}

- (void)setupTimeObserver {
  // Remove existing observer if any
  [self removeTimeObserver];

  // Add periodic time observer to update Now Playing info
  __weak typeof(self) weakSelf = self;
  _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)
                                                        queue:dispatch_get_main_queue()
                                                   usingBlock:^(CMTime time) {
                                                     [weakSelf updateNowPlayingPlaybackState];
                                                   }];
}

- (void)removeTimeObserver {
  if (_timeObserver) {
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
  }
}

- (void)loadArtworkFromUri:(NSString *)uriString
                completion:(void (^)(MPMediaItemArtwork *_Nullable artwork))completion {
  if (!uriString || uriString.length == 0) {
    completion(nil);
    return;
  }

  NSURL *url = [NSURL URLWithString:uriString];
  if (!url) {
    completion(nil);
    return;
  }

  // Check if it's a local file or network URL
  if ([url.scheme isEqualToString:@"file"]) {
    UIImage *image = [UIImage imageWithContentsOfFile:url.path];
    if (image) {
      MPMediaItemArtwork *artwork =
          [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size
                                         requestHandler:^UIImage *_Nonnull(CGSize size) {
                                           return image;
                                         }];
      completion(artwork);
    } else {
      completion(nil);
    }
  } else {
    // Network URL - load asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData *imageData = [NSData dataWithContentsOfURL:url];
      UIImage *image = imageData ? [UIImage imageWithData:imageData] : nil;

      dispatch_async(dispatch_get_main_queue(), ^{
        if (image) {
          MPMediaItemArtwork *artwork =
              [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size
                                             requestHandler:^UIImage *_Nonnull(CGSize size) {
                                               return image;
                                             }];
          completion(artwork);
        } else {
          completion(nil);
        }
      });
    });
  }
}
#endif

#pragma mark - Private

- (int64_t)duration {
  // Note: https://openradar.appspot.com/radar?id=4968600712511488
  // `[AVPlayerItem duration]` can be `kCMTimeIndefinite`,
  // use `[[AVPlayerItem asset] duration]` instead.
  return FVPCMTimeToMillis([[[_player currentItem] asset] duration]);
}

@end
