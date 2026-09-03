// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPTextureBasedVideoPlayer.h"
#import "./include/video_player_avfoundation/FVPTextureBasedVideoPlayer_Test.h"

#import "./include/video_player_avfoundation/FVPDiag.h"

#define MAXIMUM_FRAME_WAIT_IN_SECONDS 0.2
#define MAXIMUM_ASSET_LOAD_WAIT_IN_SECONDS 1.0

/// How long to wait for the decoder before reporting readiness anyway.
///
/// Readiness gated on a frame that never arrives would leave the page on its
/// thumbnail forever, which is worse than the flash this is fixing.
#define MAXIMUM_FIRST_FRAME_WAIT_IN_SECONDS 1.0

@interface FVPTextureBasedVideoPlayer () <AVPlayerItemOutputPullDelegate>
// The updater that drives callbacks to the engine to indicate that a new frame is ready.
@property(nonatomic) FVPFrameUpdater *frameUpdater;
// The display link that drives frameUpdater.
@property(nonatomic) NSObject<FVPDisplayLink> *displayLink;
// The latest buffer obtained from video output. This is stored so that it can be returned from
// copyPixelBuffer again if nothing new is available, since the engine has undefined behavior when
// returning NULL.
@property(nonatomic) CVPixelBufferRef latestPixelBuffer;
// The time that represents when the next frame displays.
@property(nonatomic) CFTimeInterval targetTime;
// Whether to enqueue textureFrameAvailable from copyPixelBuffer.
@property(nonatomic) BOOL selfRefresh;
// The time that represents the start of average frame duration measurement.
@property(nonatomic) CFTimeInterval startTime;
// The number of frames since the start of average frame duration measurement.
@property(nonatomic) int framesCount;
// The latest frame duration since there was significant change.
@property(nonatomic) CFTimeInterval latestDuration;
// Whether a new frame needs to be provided to the engine regardless of the current play/pause state
// (e.g., after a seek while paused). If YES, the display link should continue to run until the next
// frame is successfully provided.
@property(nonatomic, assign) BOOL waitingForFrame;
// Generation counter for frame expectations. Incremented each time expectFrameWithTimeout: is called,
// allowing previous timeouts to be invalidated when a new frame expectation starts.
@property(nonatomic, assign) NSUInteger frameExpectationGeneration;
// Whether the decoder has signalled that it has a frame for the current item.
// Readiness is withheld from Dart until it has: the item reaching
// AVPlayerItemStatusReadyToPlay says the item can play, not that there is a
// picture, and the page puts the texture on screen the moment Dart is told.
@property(nonatomic, assign) BOOL hasDecodableFrame;
// Whether the engine has been handed a decoded frame of the current asset.
@property(nonatomic, assign) BOOL hasRenderedFirstFrame;
// Readiness reports that arrived before the decoder had a frame, to be sent
// once it does (or once the wait times out).
@property(nonatomic, assign) BOOL initializedPending;
@property(nonatomic, assign) BOOL reloadingEndPending;
// Invalidates the timeout of a previous wait when a new one starts.
@property(nonatomic, assign) NSUInteger firstFrameWaitGeneration;
// Diagnostic: wall clock, in milliseconds, of the most recent loadAsset. Zero
// once the first real frame of that asset has been served.
@property(nonatomic, assign) double diagLoadTime;
// Diagnostic: how many times the placeholder has been handed to the engine
// since that loadAsset. Every one of these is a frame of placeholder on screen
// if the widget has already swapped away from its thumbnail.
@property(nonatomic, assign) NSUInteger diagPlaceholderServed;
// Diagnostic: when the artificial hold on the current content expires.
@property(nonatomic, assign) double diagHoldUntil;
// Diagnostic: consecutive copyPixelBuffer calls while paused. The selfRefresh
// loop has no exit when paused with no incoming buffers, so a large count
// means the display link is stuck on and the raster thread is churning.
@property(nonatomic, assign) NSUInteger pausedRefreshCount;

/// Ensures that the frame updater runs until a frame is rendered, regardless of play/pause state.
- (void)expectFrame;
/// Ensures that the frame updater runs until a frame is rendered, with a custom timeout.
- (void)expectFrameWithTimeout:(NSTimeInterval)timeout;
@end

@implementation FVPTextureBasedVideoPlayer

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                      frameUpdater:(FVPFrameUpdater *)frameUpdater
                       displayLink:(NSObject<FVPDisplayLink> *)displayLink
                         avFactory:(id<FVPAVFactory>)avFactory
                      viewProvider:(NSObject<FVPViewProvider> *)viewProvider {
  self = [super initWithPlayerItem:item avFactory:avFactory viewProvider:viewProvider];

  if (self) {
    // Configure video output for texture-based rendering.
    // Platform view players (base class) don't need this since AVPlayerLayer renders directly.
    //
    // AVVideoColorPropertiesKey must be declared on the output settings (on pixel buffer
    // attributes AVFoundation silently ignores it) so that HDR sources are tone-mapped to BT.709
    // SDR on the way into the texture. Without it, BT.2020 samples reach the texture unconverted,
    // are sampled as sRGB, and play back washed out. BT.709 sources are unaffected.
    // See https://github.com/flutter/flutter/issues/91241. Note that the platform view path keeps
    // its HDR: AVPlayerLayer renders it directly into an EDR-enabled layer.
    NSDictionary *outputSettings = @{
      AVVideoColorPropertiesKey : @{
        AVVideoColorPrimariesKey : AVVideoColorPrimaries_ITU_R_709_2,
        AVVideoTransferFunctionKey : AVVideoTransferFunction_ITU_R_709_2,
        AVVideoYCbCrMatrixKey : AVVideoYCbCrMatrix_ITU_R_709_2,
      },
      (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
      (id)kCVPixelBufferIOSurfacePropertiesKey : @{},
    };
    self.videoOutput = [avFactory videoOutputWithOutputSettings:outputSettings];

    // A player created for a page the feed has not shown before never goes
    // through loadAsset, so start the diagnostic episode here too -- otherwise
    // the first view of a video, which is the case being investigated, is the
    // one case that goes unmeasured.
    self.diagLoadTime = NSDate.date.timeIntervalSince1970 * 1000.0;
    self.diagPlaceholderServed = 0;

    _frameUpdater = frameUpdater;
    _displayLink = displayLink;
    _frameUpdater.displayLink = _displayLink;
    // Default to the self-refresh loop (re-arm textureFrameAvailable from copyPixelBuffer). Once the
    // item is ready and its content frame rate is known, configureForReadyToPlayItem: switches to
    // driving the display link at that rate and turns this off.
    _selfRefresh = YES;

    // This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
    // (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
    // video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
    // invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
    // for issue #1, and restore the correct width and height for issue #2.
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
#if TARGET_OS_IOS
    CALayer *flutterLayer = viewProvider.viewController.view.layer;
#else
    CALayer *flutterLayer = viewProvider.view.layer;
#endif
    [flutterLayer addSublayer:self.playerLayer];
  }
  return self;
}

- (void)dealloc {
  CVBufferRelease(_latestPixelBuffer);
}

- (void)setTextureIdentifier:(int64_t)textureIdentifier {
  self.frameUpdater.textureIdentifier = textureIdentifier;

  // Ensure that the first frame is drawn once available, even if the video isn't played, since
  // the engine is now expecting the texture to be populated.
  [self expectFrame];
}

- (void)expectFrame {
  [self expectFrameWithTimeout:MAXIMUM_FRAME_WAIT_IN_SECONDS];
}

- (void)expectFrameWithTimeout:(NSTimeInterval)timeout {
  self.waitingForFrame = YES;
  _displayLink.running = YES;

  // Increment the generation to invalidate any previous timeouts.
  self.frameExpectationGeneration++;
  NSUInteger currentGeneration = self.frameExpectationGeneration;

  // Timeout for displaying the first frame. As long as textureFrameAvailable has been called before this timeout,
  // the engine will correctly trigger copyPixelBuffer when the FlutterTexture is instantiated.
  dispatch_time_t maxWaitTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
  __weak FVPTextureBasedVideoPlayer *weakSelf = self;
  dispatch_after(maxWaitTime, dispatch_get_main_queue(), ^(void){
    // Only act on this timeout if no newer frame expectation has been started.
    if (weakSelf.frameExpectationGeneration != currentGeneration) {
      return;
    }
    // Always clear the expectation when it expires, even if the player is
    // playing right now. Leaving waitingForFrame set means a later pause keeps
    // the display link running (updatePlayingState ORs it in), and a paused
    // player never produces the buffer that would clear it — leaving the
    // selfRefresh loop in copyPixelBuffer redrawing the scene every vsync
    // indefinitely.
    weakSelf.waitingForFrame = NO;
    if (!weakSelf.isPlaying) {
      weakSelf.displayLink.running = NO;
    }
  });
}

#pragma mark - Overrides

- (BOOL)shouldApplyVideoCompositionForTransform {
  return YES;
}

#pragma mark - First frame gating

/// Asks the output to tell us when it can produce a frame, and starts the wait.
///
/// This is the only signal available that does not depend on the engine: the
/// engine calls copyPixelBuffer only for a texture that is already on screen,
/// and the texture only goes on screen once Dart is told the player is ready,
/// so gating readiness on a frame actually handed over would deadlock.
- (void)awaitFirstDecodableFrame {
  self.hasDecodableFrame = NO;
  NSUInteger generation = ++self.firstFrameWaitGeneration;

  [self.videoOutput setDelegate:self queue:dispatch_get_main_queue()];
  [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0];

  __weak typeof(self) weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                               (int64_t)(MAXIMUM_FIRST_FRAME_WAIT_IN_SECONDS * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   FVPTextureBasedVideoPlayer *strongSelf = weakSelf;
                   if (!strongSelf || strongSelf.firstFrameWaitGeneration != generation ||
                       strongSelf.hasDecodableFrame) {
                     return;
                   }
                   FVP_DIAG(@"ev=frame.decodable.timeout tex=%lld",
                            strongSelf.frameUpdater.textureIdentifier);
                   [strongSelf releaseDeferredReadiness];
                 });
}

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender {
  if (self.hasDecodableFrame) {
    return;
  }
  FVP_DIAG(@"ev=frame.decodable tex=%lld sinceLoadMs=%.1f", self.frameUpdater.textureIdentifier,
           self.diagLoadTime > 0 ? NSDate.date.timeIntervalSince1970 * 1000.0 - self.diagLoadTime
                                 : -1.0);
  [self releaseDeferredReadiness];
}

/// Sends whatever readiness was held back, and makes sure the display link is
/// running so the frame reaches the engine as soon as the texture is on screen.
- (void)releaseDeferredReadiness {
  self.hasDecodableFrame = YES;

  if (self.initializedPending) {
    self.initializedPending = NO;
    [super reportInitialized];
  }
  if (self.reloadingEndPending) {
    self.reloadingEndPending = NO;
    [super finishLoadingNewAsset];
  }
  [self expectFrame];
}

- (void)reportInitialized {
  if (self.hasDecodableFrame || !FVPFirstFrameGatingEnabled()) {
    [super reportInitialized];
    return;
  }
  FVP_DIAG(@"ev=ready.deferred tex=%lld kind=initialized", self.frameUpdater.textureIdentifier);
  self.initializedPending = YES;
}

- (void)finishLoadingNewAsset {
  if (self.hasDecodableFrame || !FVPFirstFrameGatingEnabled()) {
    [super finishLoadingNewAsset];
    return;
  }
  FVP_DIAG(@"ev=ready.deferred tex=%lld kind=reloading", self.frameUpdater.textureIdentifier);
  self.reloadingEndPending = YES;
}

#pragma mark -

- (void)configureForReadyToPlayItem:(AVPlayerItem *)item {
  [super configureForReadyToPlayItem:item];
  [self awaitFirstDecodableFrame];

  // Find the video track, then read its content frame rate asynchronously. Querying
  // nominalFrameRate synchronously blocks the main thread while AVFoundation loads the property,
  // which for HTTP(S) assets is a network-bound stall ("Main thread blocked by synchronous property
  // query on not-yet-loaded property (NominalFrameRate)"). Until the rate loads the display link
  // keeps the upstream every-vsync behavior; it switches to the content rate once known.
  AVAssetTrack *videoTrack = nil;
  for (AVPlayerItemTrack *track in item.tracks) {
    AVAssetTrack *assetTrack = track.assetTrack;
    if (assetTrack && [assetTrack.mediaType isEqualToString:AVMediaTypeVideo]) {
      videoTrack = assetTrack;
      break;
    }
  }
  if (videoTrack == nil) {
    return;
  }

  __weak FVPTextureBasedVideoPlayer *weakSelf = self;
  [videoTrack
      loadValuesAsynchronouslyForKeys:@[ @"nominalFrameRate" ]
                    completionHandler:^{
                      float nominalFrameRate = 0;
                      if ([videoTrack statusOfValueForKey:@"nominalFrameRate"
                                                    error:nil] == AVKeyValueStatusLoaded) {
                        nominalFrameRate = videoTrack.nominalFrameRate;
                      }
                      dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf applyContentFrameRate:nominalFrameRate];
                      });
                    }];
}

- (void)applyContentFrameRate:(float)nominalFrameRate {
  if (self.disposed || nominalFrameRate <= 0) {
    // Unknown content rate (e.g. some HLS streams): keep the upstream self-refresh behavior, which
    // updates the texture every vsync.
    return;
  }

  // Drive the texture at the video's content rate instead of every vsync. On a ProMotion display a
  // 30 fps video then composites ~30x/s rather than 120x/s, cutting GPU/raster cost ~4x while at
  // rest on a playing video. The display link becomes the sole driver, so the copyPixelBuffer
  // self-refresh loop (which would otherwise re-arm every vsync) is turned off.
  CFTimeInterval contentFrameDuration = 1.0 / nominalFrameRate;
  self.frameUpdater.contentFrameDuration = contentFrameDuration;
  self.frameUpdater.frameDuration = contentFrameDuration;
  self.selfRefresh = NO;
  if ([self.displayLink respondsToSelector:@selector(setPreferredFrameRate:)]) {
    self.displayLink.preferredFrameRate = nominalFrameRate;
  }
}

- (void)updatePlayingState {
  [super updatePlayingState];

  // If the texture is still waiting for an expected frame, the display link needs to keep
  // running until it arrives regardless of the play/pause state.
  _displayLink.running = self.isPlaying || self.waitingForFrame;
}

- (void)stopWithError:(FlutterError *_Nullable *_Nonnull)error {
  [super stopWithError:error];

  // The base implementation clears isPlaying and drops the player item, but never recomputes the
  // display link, so a player that was playing keeps its link running (and pumping
  // textureFrameAvailable every vsync) after being stopped. Stop it here. A later loadAsset re-arms
  // the link via expectFrame.
  self.waitingForFrame = NO;
  _displayLink.running = NO;
}

- (void)loadAsset:(NSURL *)url httpHeaders:(NSDictionary<NSString *,NSString *> *)httpHeaders {
    self.diagLoadTime = NSDate.date.timeIntervalSince1970 * 1000.0;
    self.diagPlaceholderServed = 0;
    FVP_DIAG(@"ev=load.begin tex=%lld url=%@", self.frameUpdater.textureIdentifier,
             url.lastPathComponent);

    // The frame the previous asset decoded says nothing about this one.
    self.hasDecodableFrame = NO;
    self.hasRenderedFirstFrame = NO;
    self.diagHoldUntil = 0;

    // Release the old pixel buffer
    CVBufferRelease(self.latestPixelBuffer);

    // Create a transparent pixel buffer to avoid showing stale frames from the previous video
    CVPixelBufferRef transparentBuffer = NULL;
    NSDictionary *pixelBufferAttributes = @{
        (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
        (id)kCVPixelBufferIOSurfacePropertiesKey : @{}
    };
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          1, 1,  // 1x1 transparent pixel
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef)pixelBufferAttributes,
                                          &transparentBuffer);
    if (status == kCVReturnSuccess && transparentBuffer) {
        // Clear to fully transparent, not to opaque black. This buffer exists to
        // stop the previous video's last frame showing through a load, and it
        // does that either way -- but the engine composites it for the frame or
        // two between the page revealing the texture and the first decoded
        // frame being pulled, and an opaque buffer paints that as black. A
        // transparent one lets whatever the page draws behind the texture show
        // instead.
        CVPixelBufferLockBaseAddress(transparentBuffer, 0);
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(transparentBuffer);
        baseAddress[0] = 0;  // B
        baseAddress[1] = 0;  // G
        baseAddress[2] = 0;  // R
        baseAddress[3] = 0;  // A
        CVPixelBufferUnlockBaseAddress(transparentBuffer, 0);
        self.latestPixelBuffer = transparentBuffer;
        FVP_DIAG(@"ev=placeholder.set tex=%lld color=transparent",
                 self.frameUpdater.textureIdentifier);
    } else {
        self.latestPixelBuffer = NULL;
    }

    // Reset timing state to avoid drift issues with the new video
    self.targetTime = 0;

    [super loadAsset:url httpHeaders:httpHeaders];
    
    // Keep the display link running until we receive the first frame of the new video.
    // Use a longer timeout (1 second) since loading a new asset can take longer than seeks.
    [self expectFrameWithTimeout:MAXIMUM_ASSET_LOAD_WAIT_IN_SECONDS];
}

- (void)seekTo:(NSInteger)position completion:(void (^)(FlutterError *_Nullable))completion {
  // Reading player.currentTime takes the item's figment lock, which is held for
  // hundreds of milliseconds while a freshly swapped-in item is being prepared.
  // On iOS the caller is the merged platform/UI thread, so that read froze the
  // whole app. The comparison it fed only avoided an occasional redundant
  // expectFrame, which the comment below already calls harmless — so always
  // expect the frame instead of paying for the time read.
  [super seekTo:position
      completion:^(FlutterError *error) {
        // Ensure that a frame is drawn once available, even if currently paused. In theory a
        // race is possible here where the new frame has already drawn by the time this code
        // runs, and the display link stays on indefinitely, but that should be relatively
        // harmless. This must use the display link rather than just informing the engine that a
        // new frame is available because the seek completing doesn't guarantee that the pixel
        // buffer is already available.
        [self expectFrame];

        if (completion) {
          completion(error);
        }
      }];
}

- (void)disposeWithError:(FlutterError *_Nullable *_Nonnull)error {
  [super disposeWithError:error];

  [self.playerLayer removeFromSuperlayer];

  // The display link is not necessarily deallocated with the player -- the frame updater holds it,
  // and CADisplayLink retains its target -- so a player disposed while playing would keep firing
  // textureFrameAvailable until the frame updater's unconsumed-frame backoff caught it. Stop it
  // here instead. See https://github.com/flutter/flutter/issues/181387.
  _displayLink.running = NO;
  _displayLink = nil;
}

#pragma mark - FlutterTexture

- (CVPixelBufferRef)copyPixelBuffer {
  // The engine is compositing this texture, so it is being consumed. Reset the frame updater's
  // unconsumed-frame counter that backs off the display link once the texture goes offscreen (see
  // FVPFrameUpdater displayLinkFired).
  self.frameUpdater.unconsumedFrameCount = 0;

  if (self.isPlaying) {
    self.pausedRefreshCount = 0;
  } else {
    self.pausedRefreshCount++;
    if (self.pausedRefreshCount % 600 == 0) {
      NSLog(@"[VideoDiag] copyPixelBuffer churning while paused: %lu calls "
            @"(texture %lld, waitingForFrame=%d, displayLink running=%d)",
            (unsigned long)self.pausedRefreshCount,
            self.frameUpdater.textureIdentifier, self.waitingForFrame,
            self.displayLink.running);
    }
  }

  // If the difference between target time and current time is longer than this fraction of frame
  // duration then reset target time.
  const float resetThreshold = 0.5;

  // Ensure video sampling at regular intervals. This function is not called at exact time intervals
  // so CACurrentMediaTime returns irregular timestamps which causes missed video frames. The range
  // outside of which targetTime is reset should be narrow enough to make possible lag as small as
  // possible and at the same time wide enough to avoid too frequent resets which would lead to
  // irregular sampling.
  // TODO: Ideally there would be a targetTimestamp of display link used by the flutter engine.
  // https://github.com/flutter/flutter/issues/159087
  CFTimeInterval currentTime = CACurrentMediaTime();
  CFTimeInterval duration = self.frameUpdater.frameDuration;
  if (fabs(self.targetTime - currentTime) > duration * resetThreshold) {
    self.targetTime = currentTime;
  }
  self.targetTime += duration;

  // Diagnostic: hold whatever the texture currently has for a while once the
  // engine starts pulling, so the hole lasts long enough for the simulator's
  // recorder to catch. Timed from the first pull, not from the load: the engine
  // does not pull until the page is on screen, which here is a second later,
  // and a hold measured from the load has expired by then.
  double holdMs = FVPDiagPlaceholderHoldMs();
  if (holdMs > 0 && self.diagLoadTime > 0) {
    double now = NSDate.date.timeIntervalSince1970 * 1000.0;
    if (self.diagHoldUntil == 0) {
      self.diagHoldUntil = now + holdMs;
      FVPDiagLog(@"ev=hold.begin tex=%lld ms=%.0f hasBuffer=%d",
                 self.frameUpdater.textureIdentifier, holdMs,
                 self.latestPixelBuffer != NULL);
    }
    if (now < self.diagHoldUntil) {
      return CVPixelBufferRetain(self.latestPixelBuffer);
    }
  }

  CVPixelBufferRef buffer = NULL;
  CMTime outputItemTime = [self.videoOutput itemTimeForHostTime:self.targetTime];
  if ([self.videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
    buffer = [self.videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
    if (buffer) {
      // Balance the owned reference from copyPixelBufferForItemTime.
      CVBufferRelease(self.latestPixelBuffer);
      self.latestPixelBuffer = buffer;
    }
  }

  if (buffer && self.waitingForFrame) {
    self.waitingForFrame = NO;
  }

  if (buffer && !self.hasRenderedFirstFrame) {
    self.hasRenderedFirstFrame = YES;
    [self.eventListener videoPlayerDidRenderFirstFrame];
  }

  if (FVPDiagEnabled() && self.diagLoadTime > 0) {
    double now = NSDate.date.timeIntervalSince1970 * 1000.0;
    if (buffer) {
      FVPDiagLog(@"ev=frame.first tex=%lld sinceLoadMs=%.1f placeholderServed=%lu",
                 self.frameUpdater.textureIdentifier, now - self.diagLoadTime,
                 (unsigned long)self.diagPlaceholderServed);
      self.diagLoadTime = 0;
    } else {
      // No new buffer, so the engine gets latestPixelBuffer back -- which is
      // still the placeholder installed by loadAsset.
      self.diagPlaceholderServed++;
      if (self.diagPlaceholderServed == 1) {
        FVPDiagLog(@"ev=placeholder.served tex=%lld sinceLoadMs=%.1f",
                   self.frameUpdater.textureIdentifier, now - self.diagLoadTime);
      }
    }
  }
  // Stop the display link whenever the player is paused with no pending frame
  // expectation — not only when a buffer arrived. A paused player produces no
  // new buffers, so a buffer-gated stop can never trigger and the selfRefresh
  // loop below would keep the engine redrawing the last layer tree every
  // vsync (e.g. after the seek race documented in seekTo:).
  if (!self.isPlaying && !self.waitingForFrame) {
    self.displayLink.running = NO;
  }

  // Calling textureFrameAvailable only from within displayLinkFired would require a non-trivial
  // solution to minimize missed video frames due to race between displayLinkFired, copyPixelBuffer
  // and place where is _textureFrameAvailable reset to false in the flutter engine.
  // TODO: Ideally FlutterTexture would support mode of operation where the copyPixelBuffer is
  // called always or some other alternative, instead of on demand by calling textureFrameAvailable.
  // https://github.com/flutter/flutter/issues/159162
  if (self.displayLink.running && self.selfRefresh) {
    // The number of frames over which to measure average frame duration.
    const int windowSize = 10;
    // If measured average frame duration is shorter than this fraction of frame duration obtained
    // from display link then rely solely on refreshes from display link.
    const float durationThreshold = 0.5;
    // If duration changes by this fraction or more then reset average frame duration measurement.
    const float resetFraction = 0.01;

    if (fabs(duration - self.latestDuration) >= self.latestDuration * resetFraction) {
      self.startTime = currentTime;
      self.framesCount = 0;
      self.latestDuration = duration;
    }
    if (self.framesCount == windowSize) {
      CFTimeInterval averageDuration = (currentTime - self.startTime) / windowSize;
      if (averageDuration < duration * durationThreshold) {
        NSLog(@"Warning: measured average duration between frames is unexpectedly short (%f/%f), "
              @"please report this to "
              @"https://github.com/flutter/flutter/issues.",
              averageDuration, duration);
        self.selfRefresh = false;
      }
      self.startTime = currentTime;
      self.framesCount = 0;
    }
    self.framesCount++;

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.frameUpdater.registry textureFrameAvailable:self.frameUpdater.textureIdentifier];
    });
  }

  // Add a retain for the engine, since the copyPixelBufferForItemTime has already been accounted
  // for, and the engine expects an owning reference.
  return CVBufferRetain(self.latestPixelBuffer);
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!self.disposed) {
      FlutterError *error;
      [self disposeWithError:&error];
    }
  });
}

@end
