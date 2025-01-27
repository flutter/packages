// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;

@import alternate_language_test_plugin;

@interface ACMessageSearchReply ()
+ (ACMessageSearchReply *)fromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface RunnerTests : XCTestCase

@end

@implementation RunnerTests

- (void)testToMapAndBack {
  ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
  reply.result = @"foobar";
  NSArray<id> *list = [reply toList];
  ACMessageSearchReply *copy = [ACMessageSearchReply fromList:list];
  XCTAssertEqual(reply.result, copy.result);
}

- (void)testHandlesNull {
  ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
  reply.result = nil;
  NSArray<id> *list = [reply toList];
  ACMessageSearchReply *copy = [ACMessageSearchReply fromList:list];
  XCTAssertNil(copy.result);
}

- (void)testHandlesNullFirst {
  ACMessageSearchReply *reply = [[ACMessageSearchReply alloc] init];
  reply.error = @"foobar";
  NSArray<id> *list = [reply toList];
  ACMessageSearchReply *copy = [ACMessageSearchReply fromList:list];
  XCTAssertEqual(reply.error, copy.error);
}

@end
