// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <XCTest/XCTest.h>
#import "EchoMessenger.h"
#import "all_datatypes.gen.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface AllDatatypesTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation AllDatatypesTest

- (void)testAllNull {
  Everything *everything = [[Everything alloc] init];
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FlutterEverythingGetCodec()];
  FlutterEverything *api = [[FlutterEverything alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoEverything:everything
           completion:^(Everything *_Nonnull result, NSError *_Nullable error) {
             XCTAssertNil(error);
             XCTAssertNotNil(result);
             XCTAssert([result.aBool isEqual:[NSNull null]]);
             XCTAssert([result.anInt isEqual:[NSNull null]]);
             XCTAssert([result.aDouble isEqual:[NSNull null]]);
             XCTAssert([result.aString isEqual:[NSNull null]]);
             XCTAssert([result.aByteArray isEqual:[NSNull null]]);
             XCTAssert([result.a4ByteArray isEqual:[NSNull null]]);
             XCTAssert([result.a8ByteArray isEqual:[NSNull null]]);
             XCTAssert([result.aFloatArray isEqual:[NSNull null]]);
             XCTAssert([result.aList isEqual:[NSNull null]]);
             XCTAssert([result.aMap isEqual:[NSNull null]]);
             [expectation fulfill];
           }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testAllEquals {
  Everything *everything = [[Everything alloc] init];
  everything.aBool = @NO;
  everything.anInt = @(1);
  everything.aDouble = @(2.0);
  everything.aString = @"123";
  everything.aByteArray = [FlutterStandardTypedData
      typedDataWithBytes:[@"1234" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.a4ByteArray = [FlutterStandardTypedData
      typedDataWithInt32:[@"1234" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.a8ByteArray = [FlutterStandardTypedData
      typedDataWithInt64:[@"12345678" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.aFloatArray = [FlutterStandardTypedData
      typedDataWithFloat64:[@"12345678" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.aList = @[ @(1), @(2) ];
  everything.aMap = @{@"hello" : @(1234)};
  everything.mapWithObject = @{@"hello" : @(1234), @"goodbye" : @"world"};
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FlutterEverythingGetCodec()];
  FlutterEverything *api = [[FlutterEverything alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoEverything:everything
           completion:^(Everything *_Nonnull result, NSError *_Nullable error) {
             XCTAssertEqual(result.aBool, everything.aBool);
             XCTAssertEqual(result.anInt, everything.anInt);
             XCTAssertEqual(result.aDouble, everything.aDouble);
             XCTAssertEqualObjects(result.aString, everything.aString);
             XCTAssertEqualObjects(result.aByteArray.data, everything.aByteArray.data);
             XCTAssertEqualObjects(result.a4ByteArray.data, everything.a4ByteArray.data);
             XCTAssertEqualObjects(result.a8ByteArray.data, everything.a8ByteArray.data);
             XCTAssertEqualObjects(result.aFloatArray.data, everything.aFloatArray.data);
             XCTAssertEqualObjects(result.aList, everything.aList);
             XCTAssertEqualObjects(result.aMap, everything.aMap);
             XCTAssertEqualObjects(result.mapWithObject, everything.mapWithObject);
             [expectation fulfill];
           }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
