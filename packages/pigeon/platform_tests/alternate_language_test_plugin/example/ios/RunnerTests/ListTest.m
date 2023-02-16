// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface ListTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation ListTest

- (void)testListInList {
  TestMessage *top = [[TestMessage alloc] init];
  TestMessage *inside = [[TestMessage alloc] init];
  inside.testList = @[ @1, @2, @3 ];
  top.testList = @[ inside ];
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:EchoApiGetCodec()];
  EchoApi *api = [[EchoApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoMsg:top
      completion:^(TestMessage *_Nonnull result, FlutterError *_Nullable err) {
        XCTAssertEqual(1u, result.testList.count);
        XCTAssertTrue([result.testList[0] isKindOfClass:[TestMessage class]]);
        XCTAssertEqualObjects(inside.testList, [result.testList[0] testList]);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
