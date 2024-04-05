// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCamMediaSettings.h"

static void AssertPositiveNumberOrNil(NSNumber *_Nullable param, const char *_Nonnull paramName) {
  if (param != nil) {
    NSCAssert(!isnan([param doubleValue]), @"%s is NaN", paramName);
    NSCAssert([param doubleValue] > 0, @"%s is not positive: %@", paramName, param);
  }
}

@implementation FLTCamMediaSettings

- (instancetype)initWithFramesPerSecond:(nullable NSNumber *)framesPerSecond
                           videoBitrate:(nullable NSNumber *)videoBitrate
                           audioBitrate:(nullable NSNumber *)audioBitrate
                            enableAudio:(BOOL)enableAudio {
  self = [super init];

  if (self != nil) {
    AssertPositiveNumberOrNil(framesPerSecond, "framesPerSecond");
    AssertPositiveNumberOrNil(videoBitrate, "videoBitrate");
    AssertPositiveNumberOrNil(audioBitrate, "audioBitrate");

    _framesPerSecond = framesPerSecond;
    _videoBitrate = videoBitrate;
    _audioBitrate = audioBitrate;
    _enableAudio = enableAudio;
  }

  return self;
}

@end
