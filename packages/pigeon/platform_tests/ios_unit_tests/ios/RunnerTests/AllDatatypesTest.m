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
           completion:^(NSMutableArray *result) {
             XCTAssertNil(result[0]);
             XCTAssertNil(result[1]);
             XCTAssertNil(result[2]);
             XCTAssertNil(result[3]);
             XCTAssertNil(result[4]);
             XCTAssertNil(result[5]);
             XCTAssertNil(result[6]);
             XCTAssertNil(result[7]);
             XCTAssertNil(result[8]);
             XCTAssertNil(result[9]);
             [expectation fulfill];
           }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testAllEquals {
  Everything *everything = [[Everything alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    Everything *newEverything = [[Everything fromList: list] init];
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
           completion:^(NSMutableArray *result) {
      NSMutableArray *trueResult = result[0];
      Everything *newEverything = [[Everything fromList: trueResult] init];
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
