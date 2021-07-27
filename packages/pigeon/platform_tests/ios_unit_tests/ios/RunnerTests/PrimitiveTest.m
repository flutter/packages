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

- (void)testIntPrimitive {
  EchoBinaryMessenger* binaryMessenger = [[EchoBinaryMessenger alloc] init];
  PrimitiveFlutterApi* api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation* expectation = [self expectationWithDescription:@"callback"];
  [api anInt:@1
      completion:^(NSNumber* _Nonnull result, NSError* _Nullable err) {
        XCTAssertEqualObjects(@1, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testBoolPrimitive {
  EchoBinaryMessenger* binaryMessenger = [[EchoBinaryMessenger alloc] init];
  PrimitiveFlutterApi* api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation* expectation = [self expectationWithDescription:@"callback"];
  NSNumber* arg = @YES;
  [api aBool:arg
      completion:^(NSNumber* _Nonnull result, NSError* _Nullable err) {
        XCTAssertEqualObjects(arg, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testDoublePrimitive {
  EchoBinaryMessenger* binaryMessenger = [[EchoBinaryMessenger alloc] init];
  PrimitiveFlutterApi* api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation* expectation = [self expectationWithDescription:@"callback"];
  NSNumber* arg = @(1.5);
  [api aBool:arg
      completion:^(NSNumber* _Nonnull result, NSError* _Nullable err) {
        XCTAssertEqualObjects(arg, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testStringPrimitive {
  EchoBinaryMessenger* binaryMessenger = [[EchoBinaryMessenger alloc] init];
  PrimitiveFlutterApi* api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation* expectation = [self expectationWithDescription:@"callback"];
  NSString* arg = @"hello";
  [api aString:arg
      completion:^(NSString* _Nonnull result, NSError* _Nullable err) {
        XCTAssertEqualObjects(arg, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testListPrimitive {
  EchoBinaryMessenger* binaryMessenger = [[EchoBinaryMessenger alloc] init];
  PrimitiveFlutterApi* api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation* expectation = [self expectationWithDescription:@"callback"];
  NSArray* arg = @[ @"hello" ];
  [api aList:arg
      completion:^(NSArray* _Nonnull result, NSError* _Nullable err) {
        XCTAssertEqualObjects(arg, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testMapPrimitive {
  EchoBinaryMessenger* binaryMessenger = [[EchoBinaryMessenger alloc] init];
  PrimitiveFlutterApi* api = [[PrimitiveFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation* expectation = [self expectationWithDescription:@"callback"];
  NSDictionary* arg = @{ @"hello" : @1 };
  [api aMap:arg
      completion:^(NSDictionary* _Nonnull result, NSError* _Nullable err) {
        XCTAssertEqualObjects(arg, result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
