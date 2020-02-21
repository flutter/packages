//
//  RunnerTests.m
//  RunnerTests
//
//  Created by Aaron Clarke on 2/20/20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "messages.h"

@interface ACSearchReply ()
+ (ACSearchReply*)fromMap:(NSDictionary*)dict;
- (NSDictionary*)toMap;
@end

@interface RunnerTests : XCTestCase

@end

@implementation RunnerTests

- (void)testToMapAndBack {
  ACSearchReply* reply = [[ACSearchReply alloc] init];
  reply.result = @"foobar";
  NSDictionary* dict = [reply toMap];
  ACSearchReply* copy = [ACSearchReply fromMap:dict];
  XCTAssertEqual(reply.result, copy.result);
}

- (void)testHandlesNull {
  ACSearchReply* reply = [[ACSearchReply alloc] init];
  reply.result = nil;
  NSDictionary* dict = [reply toMap];
  ACSearchReply* copy = [ACSearchReply fromMap:dict];
  XCTAssertNil(copy.result);
}

- (void)testHandlesNullFirst {
  ACSearchReply* reply = [[ACSearchReply alloc] init];
  reply.error = @"foobar";
  NSDictionary* dict = [reply toMap];
  ACSearchReply* copy = [ACSearchReply fromMap:dict];
  XCTAssertEqual(reply.error, copy.error);
}

@end
