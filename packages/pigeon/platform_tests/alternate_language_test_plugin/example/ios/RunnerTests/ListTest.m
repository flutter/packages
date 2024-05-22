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
  FLTTestMessage *top = [[FLTTestMessage alloc] init];
  FLTTestMessage *inside = [[FLTTestMessage alloc] init];
  inside.testList = @[ @1, @2, @3 ];
  top.testList = @[ inside ];
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FLTFlutterSmallApiGetCodec()];
  FLTFlutterSmallApi *api = [[FLTFlutterSmallApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoWrappedList:top
            completion:^(FLTTestMessage *_Nonnull result, FlutterError *_Nullable err) {
              XCTAssertEqual(1u, result.testList.count);
              XCTAssertTrue([result.testList[0] isKindOfClass:[FLTTestMessage class]]);
              XCTAssertEqualObjects(inside.testList, [result.testList[0] testList]);
              [expectation fulfill];
            }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
