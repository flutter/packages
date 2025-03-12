// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTCapturePhotoOutput.h"

@implementation FLTDefaultCapturePhotoOutput {
  AVCapturePhotoOutput *_avOutput;
}

- (instancetype)initWithPhotoOutput:(AVCapturePhotoOutput *)photoOutput {
  self = [super init];
  if (self) {
    _avOutput = photoOutput;
  }
  return self;
}

- (AVCapturePhotoOutput *)avOutput {
  return _avOutput;
}

- (NSArray<AVVideoCodecType> *)availablePhotoCodecTypes {
  return _avOutput.availablePhotoCodecTypes;
}

- (BOOL)highResolutionCaptureEnabled {
  return _avOutput.isHighResolutionCaptureEnabled;
}

- (void)setHighResolutionCaptureEnabled:(BOOL)enabled {
  [_avOutput setHighResolutionCaptureEnabled:enabled];
}

- (void)capturePhotoWithSettings:(AVCapturePhotoSettings *)settings
                        delegate:(NSObject<AVCapturePhotoCaptureDelegate> *)delegate {
  [_avOutput capturePhotoWithSettings:settings delegate:delegate];
}

- (nullable NSObject<FLTCaptureConnection> *)connectionWithMediaType:
    (nonnull AVMediaType)mediaType {
  return [[FLTDefaultCaptureConnection alloc]
      initWithConnection:[_avOutput connectionWithMediaType:mediaType]];
}

- (NSArray<NSNumber *> *)supportedFlashModes {
  return _avOutput.supportedFlashModes;
}

@end
