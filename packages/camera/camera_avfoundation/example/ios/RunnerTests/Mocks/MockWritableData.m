// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockWritableData.h"

@implementation MockWritableData

- (BOOL)writeToFile:(NSString *)path
            options:(NSDataWritingOptions)writeOptionsMask
              error:(NSError **)errorPtr {
  if (self.writeToFileStub) {
    return _writeToFileStub(path, writeOptionsMask, errorPtr);
  }
  return YES;
}

@end
