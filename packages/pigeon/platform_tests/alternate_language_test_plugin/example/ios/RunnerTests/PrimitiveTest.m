// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface PrimitiveTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation PrimitiveTest

- (void)testIntPrimitive {
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:GetPrimitiveCodec()];
  PrimitiveFlutterApi *api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api anIntValue:1
       completion:^(NSNumber *_Nonnull result, FlutterError *_Nullable err) {
         XCTAssertEqualObjects(@1, result);
         [expectation fulfill];
       }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testBoolPrimitive {
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:GetPrimitiveCodec()];
  PrimitiveFlutterApi *api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  BOOL arg = YES;
  [api aBoolValue:arg
       completion:^(NSNumber *_Nonnull result, FlutterError *_Nullable err) {
         XCTAssertNotNil(result);
         XCTAssertEqual(arg, result.boolValue);
         [expectation fulfill];
       }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testDoublePrimitive {
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:GetPrimitiveCodec()];
  PrimitiveFlutterApi *api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  NSInteger arg = 1.5;
  [api aDoubleValue:arg
         completion:^(NSNumber *_Nonnull result, FlutterError *_Nullable err) {
           XCTAssertNotNil(result);
           XCTAssertEqual(arg, result.integerValue);
           [expectation fulfill];
         }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testStringPrimitive {
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:GetPrimitiveCodec()];
  PrimitiveFlutterApi *api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  NSString *arg = @"hello";
  [api aStringValue:arg
         completion:^(NSString *_Nonnull result, FlutterError *_Nullable err) {
           XCTAssertEqualObjects(arg, result);
           [expectation fulfill];
         }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testListPrimitive {
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:GetPrimitiveCodec()];
  PrimitiveFlutterApi *api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  NSArray<id> *arg = @[ @"hello" ];
  [api aListValue:arg
       completion:^(NSArray<id> *_Nonnull result, FlutterError *_Nullable err) {
         XCTAssertEqualObjects(arg, result);
         [expectation fulfill];
       }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testMapPrimitive {
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:GetPrimitiveCodec()];
  PrimitiveFlutterApi *api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  NSDictionary *arg = @{@"hello" : @1};
  [api aMapValue:arg
      completion:^(NSDictionary *_Nonnull result, FlutterError *_Nullable err) {
        XCTAssertEqualObjects(arg, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
