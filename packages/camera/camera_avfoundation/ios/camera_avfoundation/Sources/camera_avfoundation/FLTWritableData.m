// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTWritableData.h"

@implementation FLTDefaultWritableData

- (instancetype)initWithData:(NSData *)data {
  self = [super init];
  if (self) {
    _data = data;
  }
  return self;
}

- (BOOL)writeToFile:(NSString *)path
            options:(NSDataWritingOptions)writeOptionsMask
              error:(NSError **)errorPtr {
  return [self.data writeToFile:path options:writeOptionsMask error:errorPtr];
}

@end
