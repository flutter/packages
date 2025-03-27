// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMCATransactionWrapper.h"
#import <QuartzCore/QuartzCore.h>

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
