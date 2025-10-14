// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ExceptionCatcher.h"

@implementation ExceptionCatcher
+ (nullable NSException *)catchException:(void (^)(void))tryBlock {
  @try {
    tryBlock();
    // No exception occurred.
    return nil;
  } @catch (NSException *exception) {
    return exception;
  }
}
@end
