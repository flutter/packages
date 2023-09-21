// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPCacheAction.h"

@implementation FVPCacheAction

- (instancetype)initWithCacheType:(FVPCacheType)cacheType range:(NSRange)range {
  self = [super init];
  if (self) {
    _cacheType = cacheType;
    _range = range;
  }
  return self;
}

// validate cache relevance
- (BOOL)isEqual:(FVPCacheAction *)object {
  if (!NSEqualRanges(object.range, self.range)) {
    return NO;
  }

  if (object.cacheType != self.cacheType) {
    return NO;
  }

  return YES;
}

// Optimization. Do not remove.
- (NSUInteger)hash {
  return
      [[NSString stringWithFormat:@"%@%@", NSStringFromRange(self.range), @(self.cacheType)] hash];
}

@end
