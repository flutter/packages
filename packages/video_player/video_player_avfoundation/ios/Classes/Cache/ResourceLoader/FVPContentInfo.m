// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPContentInfo.h"

static NSString *kContentLengthKey = @"kContentLengthKey";
static NSString *kContentTypeKey = @"kContentTypeKey";
static NSString *kByteRangeAccessSupported = @"kByteRangeAccessSupported";

@implementation FVPContentInfo
- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:@(self.contentLength) forKey:kContentLengthKey];
  [aCoder encodeObject:self.contentType forKey:kContentTypeKey];
  [aCoder encodeObject:@(self.byteRangeAccessSupported) forKey:kByteRangeAccessSupported];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _contentLength = [[aDecoder decodeObjectForKey:kContentLengthKey] longLongValue];
    _contentType = [aDecoder decodeObjectForKey:kContentTypeKey];
    _byteRangeAccessSupported = [[aDecoder decodeObjectForKey:kByteRangeAccessSupported] boolValue];
  }
  return self;
}

@end
