// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCaptureVideoDataOutput.h"

@interface FLTDefaultCaptureVideoDataOutput ()
@property(nonatomic, strong) AVCaptureVideoDataOutput *avOutput;
@end

@implementation FLTDefaultCaptureVideoDataOutput

- (instancetype)initWithCaptureVideoOutput:(AVCaptureVideoDataOutput *)videoOutput {
  self = [super init];
  if (self) {
    _avOutput = videoOutput;
  }
  return self;
}

- (BOOL)alwaysDiscardsLateVideoFrames {
  return self.avOutput.alwaysDiscardsLateVideoFrames;
}

- (void)setAlwaysDiscardsLateVideoFrames:(BOOL)alwaysDiscardsLateVideoFrames {
  self.avOutput.alwaysDiscardsLateVideoFrames = alwaysDiscardsLateVideoFrames;
}

- (NSDictionary<NSString *, id> *)videoSettings {
  return self.avOutput.videoSettings;
}

- (void)setVideoSettings:(NSDictionary<NSString *, id> *)videoSettings {
  self.avOutput.videoSettings = videoSettings;
}

- (nullable NSObject<FLTCaptureConnection> *)connectionWithMediaType:
    (nonnull AVMediaType)mediaType {
  return [[FLTDefaultCaptureConnection alloc]
      initWithConnection:[self.avOutput connectionWithMediaType:mediaType]];
}

- (void)setSampleBufferDelegate:
            (nullable id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate
                          queue:(nullable dispatch_queue_t)sampleBufferCallbackQueue {
  [self.avOutput setSampleBufferDelegate:sampleBufferDelegate queue:sampleBufferCallbackQueue];
}

@end
