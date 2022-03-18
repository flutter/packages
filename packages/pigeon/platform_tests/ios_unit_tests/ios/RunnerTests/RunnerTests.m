// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "message.gen.h"

@interface ACSearchReply ()
+ (ACSearchReply *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@interface RunnerTests : XCTestCase

@end

@implementation RunnerTests

- (void)testToMapAndBack {
  ACSearchReply *reply = [[ACSearchReply alloc] init];
  reply.result = @"foobar";
  NSDictionary *dict = [reply toMap];
  ACSearchReply *copy = [ACSearchReply fromMap:dict];
  XCTAssertEqual(reply.result, copy.result);
}

- (void)testHandlesNull {
  ACSearchReply *reply = [[ACSearchReply alloc] init];
  reply.result = nil;
  NSDictionary *dict = [reply toMap];
  ACSearchReply *copy = [ACSearchReply fromMap:dict];
  XCTAssertNil(copy.result);
}

- (void)testHandlesNullFirst {
  ACSearchReply *reply = [[ACSearchReply alloc] init];
  reply.error = @"foobar";
  NSDictionary *dict = [reply toMap];
  ACSearchReply *copy = [ACSearchReply fromMap:dict];
  XCTAssertEqual(reply.error, copy.error);
}

@end
