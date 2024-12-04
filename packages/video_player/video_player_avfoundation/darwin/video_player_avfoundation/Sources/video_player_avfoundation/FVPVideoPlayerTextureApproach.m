// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPVideoPlayerTextureApproach_Test.h"

@interface FVPVideoPlayerTextureApproach ()
// The CALayer associated with the Flutter view this plugin is associated with, if any.
@property(nonatomic, readonly, nullable) CALayer *flutterViewLayer;
// The updater that drives callbacks to the engine to indicate that a new frame is ready.
@property(nonatomic, nullable) FVPFrameUpdater *frameUpdater;
// The display link that drives frameUpdater.
@property(nonatomic, nullable) FVPDisplayLink *displayLink;
// Whether a new frame needs to be provided to the engine regardless of the current play/pause state
// (e.g., after a seek while paused). If YES, the display link should continue to run until the next
// frame is successfully provided.
@property(nonatomic, assign) BOOL waitingForFrame;
@end

@implementation FVPVideoPlayerTextureApproach
- (instancetype)initWithAsset:(NSString *)asset
                 frameUpdater:(FVPFrameUpdater *)frameUpdater
                  displayLink:(FVPDisplayLink *)displayLink
                    avFactory:(id<FVPAVFactory>)avFactory
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSString *path = [[NSBundle mainBundle] pathForResource:asset ofType:nil];
#if TARGET_OS_OSX
  // See https://github.com/flutter/flutter/issues/135302
  // TODO(stuartmorgan): Remove this if the asset APIs are adjusted to work better for macOS.
  if (!path) {
    path = [NSURL URLWithString:asset relativeToURL:NSBundle.mainBundle.bundleURL].path;
  }
#endif
  return [self initWithURL:[NSURL fileURLWithPath:path]
              frameUpdater:(FVPFrameUpdater *)frameUpdater
               displayLink:(FVPDisplayLink *)displayLink
               httpHeaders:@{}
                 avFactory:avFactory
                 registrar:registrar];
}

- (instancetype)initWithURL:(NSURL *)url
               frameUpdater:(FVPFrameUpdater *)frameUpdater
                displayLink:(FVPDisplayLink *)displayLink
                httpHeaders:(nonnull NSDictionary<NSString *, NSString *> *)headers
                  avFactory:(id<FVPAVFactory>)avFactory
                  registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSDictionary<NSString *, id> *options = nil;
  if ([headers count] != 0) {
    options = @{@"AVURLAssetHTTPHeaderFieldsKey" : headers};
  }
  AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:options];
  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:urlAsset];
  return [self initWithPlayerItem:item
                     frameUpdater:(FVPFrameUpdater *)frameUpdater
                      displayLink:(FVPDisplayLink *)displayLink
                        avFactory:avFactory
                        registrar:registrar];
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
                      frameUpdater:(FVPFrameUpdater *)frameUpdater
                       displayLink:(FVPDisplayLink *)displayLink
                         avFactory:(id<FVPAVFactory>)avFactory
                         registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super initWithPlayerItem:item avFactory:avFactory registrar:registrar];

  if (self) {
    _frameUpdater = frameUpdater;
    _displayLink = displayLink;
    _frameUpdater.videoOutput = self.videoOutput;

    // This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
    // (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
    // video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
    // invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
    // for issue #1, and restore the correct width and height for issue #2.
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.flutterViewLayer addSublayer:self.playerLayer];
  }
  return self;
}

- (void)updatePlayingState {
  [super updatePlayingState];
  // If the texture is still waiting for an expected frame, the display link needs to keep
  // running until it arrives regardless of the play/pause state.
  _displayLink.running = self.isPlaying || self.waitingForFrame;
}

- (void)seekTo:(int64_t)location completionHandler:(void (^)(BOOL))completionHandler {
  // FIXME Rethink if it's possible to reuse it (same logic in super class)
  CMTime previousCMTime = self.player.currentTime;
  CMTime targetCMTime = CMTimeMake(location, 1000);
  CMTimeValue duration = self.player.currentItem.asset.duration.value;
  // Without adding tolerance when seeking to duration,
  // seekToTime will never complete, and this call will hang.
  // see issue https://github.com/flutter/flutter/issues/124475.
  CMTime tolerance = location == duration ? CMTimeMake(1, 1000) : kCMTimeZero;
  [self.player seekToTime:targetCMTime
          toleranceBefore:tolerance
           toleranceAfter:tolerance
        completionHandler:^(BOOL completed) {
          if (CMTimeCompare(self.player.currentTime, previousCMTime) != 0) {
            // Ensure that a frame is drawn once available, even if currently paused. In theory a
            // race is possible here where the new frame has already drawn by the time this code
            // runs, and the display link stays on indefinitely, but that should be relatively
            // harmless. This must use the display link rather than just informing the engine that a
            // new frame is available because the seek completing doesn't guarantee that the pixel
            // buffer is already available.
            [self expectFrame];
          }

          if (completionHandler) {
            completionHandler(completed);
          }
        }];
}

- (void)expectFrame {
  self.waitingForFrame = YES;

  _displayLink.running = YES;
}

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef buffer = NULL;
  CMTime outputItemTime = [self.videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  if ([self.videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
    buffer = [self.videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
  } else {
    // If the current time isn't available yet, use the time that was checked when informing the
    // engine that a frame was available (if any).
    CMTime lastAvailableTime = self.frameUpdater.lastKnownAvailableTime;
    if (CMTIME_IS_VALID(lastAvailableTime)) {
      buffer = [self.videoOutput copyPixelBufferForItemTime:lastAvailableTime
                                         itemTimeForDisplay:NULL];
    }
  }

  if (self.waitingForFrame && buffer) {
    self.waitingForFrame = NO;
    // If the display link was only running temporarily to pick up a new frame while the video was
    // paused, stop it again.
    if (!self.isPlaying) {
      self.displayLink.running = NO;
    }
  }

  return buffer;
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self dispose];
  });
}

- (void)disposeSansEventChannel {
  [super disposeSansEventChannel];

  [self.playerLayer removeFromSuperlayer];

  _displayLink = nil;
}

- (CALayer *)flutterViewLayer {
#if TARGET_OS_OSX
  return self.registrar.view.layer;
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(hellohuanlin): Provide a non-deprecated codepath. See
  // https://github.com/flutter/flutter/issues/104117
  UIViewController *root = UIApplication.sharedApplication.keyWindow.rootViewController;
#pragma clang diagnostic pop
  return root.view.layer;
#endif
}

@end
