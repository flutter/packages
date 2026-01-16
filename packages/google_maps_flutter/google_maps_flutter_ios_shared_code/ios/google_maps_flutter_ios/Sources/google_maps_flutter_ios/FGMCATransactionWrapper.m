// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/google_maps_flutter_ios/FGMCATransactionWrapper.h"

@import QuartzCore;

@implementation FGMCATransactionWrapper

- (void)begin {
  [CATransaction begin];
}

- (void)commit {
  [CATransaction commit];
}

- (void)setAnimationDuration:(CFTimeInterval)duration {
  [CATransaction setAnimationDuration:duration];
}

@end
