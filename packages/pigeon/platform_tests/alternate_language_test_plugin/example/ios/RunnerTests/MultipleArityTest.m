// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "HandlerBinaryMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface MultipleAritytest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation MultipleAritytest

- (void)testSimple {
  HandlerBinaryMessenger *binaryMessenger = [[HandlerBinaryMessenger alloc]
      initWithCodec:GetMultipleArityCodec()
            handler:^id _Nullable(NSArray<id> *_Nonnull args) {
              return @[ @([args[0] intValue] - [args[1] intValue]) ];
            }];
  MultipleArityFlutterApi *api =
      [[MultipleArityFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"subtraction"];
  [api subtractX:30
               y:10
      completion:^(NSNumber *_Nonnull result, FlutterError *_Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(20, result.intValue);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:30.0];
}

@end
