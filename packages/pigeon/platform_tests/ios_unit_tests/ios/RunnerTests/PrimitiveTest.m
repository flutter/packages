// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <XCTest/XCTest.h>
#import "EchoMessenger.h"
#import "primitive.gen.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface PrimitiveTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation PrimitiveTest

- (void)testPrimitive {
  EchoBinaryMessenger* binaryMessenger = [[EchoBinaryMessenger alloc] init];
  PrimitiveFlutterApi* api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation* expectation = [self expectationWithDescription:@"callback"];
  [api inc:@1
      completion:^(NSNumber* _Nonnull result, NSError* _Nullable err) {
        XCTAssertEqualObjects(@1, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
