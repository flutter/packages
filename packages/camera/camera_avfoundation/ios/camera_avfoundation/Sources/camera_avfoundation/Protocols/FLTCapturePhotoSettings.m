// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTCapturePhotoSettings.h"

@implementation FLTDefaultCapturePhotoSettings
- (instancetype)initWithSettings:(AVCapturePhotoSettings *)settings {
  self = [super init];
  if (self) {
    settings = settings;
  }
  return self;
}

- (int64_t)uniqueID {
  return settings.uniqueID;
}

- (NSDictionary<NSString *, id> *)format {
  return settings.format;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
  [settings setFlashMode:flashMode];
}

- (void)setHighResolutionPhotoEnabled:(BOOL)enabled {
  [settings setHighResolutionPhotoEnabled:enabled];
}

@synthesize settings;

@end
