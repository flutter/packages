// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCapturePhotoOutput.h"

@interface FLTDefaultCapturePhotoOutput ()
@property(nonatomic, strong) AVCapturePhotoOutput *avOutput;
@end

@implementation FLTDefaultCapturePhotoOutput

- (instancetype)initWithPhotoOutput:(AVCapturePhotoOutput *)photoOutput {
  self = [super init];
  if (self) {
    _avOutput = photoOutput;
  }
  return self;
}

- (NSArray<AVVideoCodecType> *)availablePhotoCodecTypes {
  return self.avOutput.availablePhotoCodecTypes;
}

- (BOOL)highResolutionCaptureEnabled {
  return self.avOutput.isHighResolutionCaptureEnabled;
}

- (void)setHighResolutionCaptureEnabled:(BOOL)enabled {
  [self.avOutput setHighResolutionCaptureEnabled:enabled];
}

- (void)capturePhotoWithSettings:(AVCapturePhotoSettings *)settings
                        delegate:(NSObject<AVCapturePhotoCaptureDelegate> *)delegate {
  [self.avOutput capturePhotoWithSettings:settings delegate:delegate];
}

- (nullable NSObject<FLTCaptureConnection> *)connectionWithMediaType:
    (nonnull AVMediaType)mediaType {
  return [[FLTDefaultCaptureConnection alloc]
      initWithConnection:[self.avOutput connectionWithMediaType:mediaType]];
}

- (NSArray<NSNumber *> *)supportedFlashModes {
  return self.avOutput.supportedFlashModes;
}

@end
