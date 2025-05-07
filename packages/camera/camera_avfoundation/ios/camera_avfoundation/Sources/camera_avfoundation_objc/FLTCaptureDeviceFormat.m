// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCaptureDeviceFormat.h"

@interface FLTDefaultFrameRateRange ()
@property(nonatomic, strong) AVFrameRateRange *range;
@end

@implementation FLTDefaultFrameRateRange

- (instancetype)initWithRange:(AVFrameRateRange *)range {
  self = [super init];
  if (self) {
    _range = range;
  }
  return self;
}

- (float)minFrameRate {
  return _range.minFrameRate;
}

- (float)maxFrameRate {
  return _range.maxFrameRate;
}

@end

@interface FLTDefaultCaptureDeviceFormat ()
@property(nonatomic, strong) AVCaptureDeviceFormat *format;
@end

@implementation FLTDefaultCaptureDeviceFormat

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format {
  self = [super init];
  if (self) {
    _format = format;
  }
  return self;
}

- (CMFormatDescriptionRef)formatDescription {
  return _format.formatDescription;
}

- (NSArray<NSObject<FLTFrameRateRange> *> *)videoSupportedFrameRateRanges {
  NSMutableArray<id<FLTFrameRateRange>> *ranges =
      [NSMutableArray arrayWithCapacity:_format.videoSupportedFrameRateRanges.count];
  for (AVFrameRateRange *range in _format.videoSupportedFrameRateRanges) {
    FLTDefaultFrameRateRange *wrapper = [[FLTDefaultFrameRateRange alloc] initWithRange:range];
    [ranges addObject:wrapper];
  }
  return ranges;
}

@end
