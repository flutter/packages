// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;

#ifdef LEGACY_HARNESS
#import "Message.gen.h"
#else
@import alternate_language_test_plugin;
#endif

@interface ACMessageSearchReply ()
+ (ACMessageSearchReply *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@interface RunnerTests : XCTestCase

@end

@implementation RunnerTests

- (void)testToMapAndBack {
  ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
  reply.result = @"foobar";
  NSDictionary *dict = [reply toMap];
  ACMessageSearchReply *copy = [ACMessageSearchReply fromMap:dict];
  XCTAssertEqual(reply.result, copy.result);
}

- (void)testHandlesNull {
  ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
  reply.result = nil;
  NSDictionary *dict = [reply toMap];
  ACMessageSearchReply *copy = [ACMessageSearchReply fromMap:dict];
  XCTAssertNil(copy.result);
}

- (void)testHandlesNullFirst {
  ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
  reply.error = @"foobar";
  NSDictionary *dict = [reply toMap];
  ACMessageSearchReply *copy = [ACMessageSearchReply fromMap:dict];
  XCTAssertEqual(reply.error, copy.error);
}

@end
