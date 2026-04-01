
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface NonNullFieldsTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation NonNullFieldsTest

- (void)testMake {
  NonNullFieldSearchRequest *request = [NonNullFieldSearchRequest makeWithQuery:@"hello"];
  XCTAssertEqualObjects(@"hello", request.query);
}

- (void)testEquality {
  NonNullFieldSearchRequest *request1 = [NonNullFieldSearchRequest makeWithQuery:@"hello"];
  NonNullFieldSearchRequest *request2 = [NonNullFieldSearchRequest makeWithQuery:@"hello"];
  NonNullFieldSearchRequest *request3 = [NonNullFieldSearchRequest makeWithQuery:@"world"];

  XCTAssertEqualObjects(request1, request2);
  XCTAssertNotEqualObjects(request1, request3);
  XCTAssertEqual(request1.hash, request2.hash);
}

@end
