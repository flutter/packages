// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "OCSwiftMock.h"
#import <Foundation/Foundation.h>

@implementation OCSwiftProtocolMock

- (instancetype)init:(Protocol *)mockProtocol {
  self = [super init];
  if (self) {
    _protocol = OCMProtocolMock(mockProtocol);
  }
  return self;
}
@end

@implementation OCSwiftClassMock

- (instancetype)init:(Class)classObject {
  self = [super init];
  if (self) {
    _object = OCMClassMock(classObject);
  }
  return self;
}

@end
