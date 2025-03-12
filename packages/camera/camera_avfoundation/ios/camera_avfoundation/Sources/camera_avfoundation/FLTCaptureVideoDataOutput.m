// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCaptureVideoDataOutput.h"

@implementation FLTDefaultCaptureVideoDataOutput {
  AVCaptureVideoDataOutput *_avOutput;
}

- (instancetype)initWithCaptureVideoOutput:(AVCaptureVideoDataOutput *)videoOutput {
  self = [super init];
  if (self) {
    _avOutput = videoOutput;
  }
  return self;
}

- (AVCaptureVideoDataOutput *)avOutput {
  return _avOutput;
}

- (BOOL)alwaysDiscardsLateVideoFrames {
  return _avOutput.alwaysDiscardsLateVideoFrames;
}

- (void)setAlwaysDiscardsLateVideoFrames:(BOOL)alwaysDiscardsLateVideoFrames {
  _avOutput.alwaysDiscardsLateVideoFrames = alwaysDiscardsLateVideoFrames;
}

- (NSDictionary<NSString *, id> *)videoSettings {
  return _avOutput.videoSettings;
}

- (void)setVideoSettings:(NSDictionary<NSString *, id> *)videoSettings {
  _avOutput.videoSettings = videoSettings;
}

- (nullable NSObject<FLTCaptureConnection> *)connectionWithMediaType:
    (nonnull AVMediaType)mediaType {
  return [[FLTDefaultCaptureConnection alloc]
      initWithConnection:[_avOutput connectionWithMediaType:mediaType]];
}

- (void)setSampleBufferDelegate:
            (nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate
                          queue:(nullable dispatch_queue_t)sampleBufferCallbackQueue {
  [_avOutput setSampleBufferDelegate:sampleBufferDelegate queue:sampleBufferCallbackQueue];
}

@end
