
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

#ifdef LEGACY_HARNESS
#import "NonNullFields.gen.h"
#else
@import alternate_language_test_plugin;
#endif

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

@end
