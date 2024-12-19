// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTCapturePhotoSettings.h"

@interface FLTDefaultCapturePhotoSettings ()
@property(nonatomic, strong) AVCapturePhotoSettings *settings;
@end

@implementation FLTDefaultCapturePhotoSettings
- (instancetype)initWithSettings:(AVCapturePhotoSettings *)settings {
  self = [super init];
  if (self) {
    _settings = settings;
  }
  return self;
}

- (int64_t)uniqueID {
  return _settings.uniqueID;
}

- (NSDictionary<NSString *, id> *)format {
  return _settings.format;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
  [_settings setFlashMode:flashMode];
}

- (void)setHighResolutionPhotoEnabled:(BOOL)enabled {
  [_settings setHighResolutionPhotoEnabled:enabled];
}

@end
