// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTCapturePhotoOutput.h"
#import "../include/camera_avfoundation/Protocols/FLTCapturePhotoSettings.h"

@implementation FLTDefaultCapturePhotoOutput {
  AVCapturePhotoOutput *_photoOutput;
}

- (instancetype)initWithPhotoOutput:(AVCapturePhotoOutput *)photoOutput {
  self = [super init];
  if (self) {
    _photoOutput = photoOutput;
  }
  return self;
}

- (AVCapturePhotoOutput *)photoOutput {
  return _photoOutput;
}

- (NSArray<AVVideoCodecType> *)availablePhotoCodecTypes {
  return _photoOutput.availablePhotoCodecTypes;
}

- (void)setHighResolutionCaptureEnabled:(BOOL)enabled {
  [_photoOutput setHighResolutionCaptureEnabled:enabled];
}

- (BOOL)isHighResolutionCaptureEnabled {
  return _photoOutput.isHighResolutionCaptureEnabled;
}

- (void)capturePhotoWithSettings:(id<FLTCapturePhotoSettings>)settings
                        delegate:(id<AVCapturePhotoCaptureDelegate>)delegate {
  [_photoOutput capturePhotoWithSettings:settings.settings delegate:delegate];
}

- (nullable AVCaptureConnection *)connectionWithMediaType:(nonnull AVMediaType)mediaType { 
  return [_photoOutput connectionWithMediaType:mediaType];
}


- (NSArray<NSNumber *> *)supportedFlashModes {
  return _photoOutput.supportedFlashModes;
}

@end
