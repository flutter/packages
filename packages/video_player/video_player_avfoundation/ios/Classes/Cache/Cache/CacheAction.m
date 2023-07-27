// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CacheAction.h"

@implementation CacheAction

- (instancetype)initWithActionType:(CacheType)cacheType range:(NSRange)range {
  self = [super init];
  if (self) {
    _cacheType = cacheType;
    _range = range;
  }
  return self;
}

- (BOOL)isEqual:(CacheAction *)object {
  return NSEqualRanges(object.range, self.range) && object.cacheType == self.cacheType;
}

@end
