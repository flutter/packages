// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockCaptureDeviceFormat.h"

@implementation MockCaptureDeviceFormat

- (instancetype)initWithDimensions:(CMVideoDimensions)dimensions {
  self = [super init];
  if (self) {
    CMVideoFormatDescriptionCreate(kCFAllocatorDefault, kCVPixelFormatType_32BGRA, dimensions.width,
                                   dimensions.height, NULL, &_formatDescription);
  }
  return self;
}

- (void)dealloc {
  if (_formatDescription) {
    CFRelease(_formatDescription);
  }
}

@end

@implementation MockFrameRateRange

- (instancetype)initWithMinFrameRate:(float)minFrameRate maxFrameRate:(float)maxFrameRate {
  self = [super init];
  if (self) {
    _minFrameRate = minFrameRate;
    _maxFrameRate = maxFrameRate;
  }
  return self;
}

@end
