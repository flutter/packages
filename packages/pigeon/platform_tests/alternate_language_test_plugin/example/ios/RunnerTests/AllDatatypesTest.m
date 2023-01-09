// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

#ifdef LEGACY_HARNESS
#import "CoreTests.gen.h"
#else
@import alternate_language_test_plugin;
#endif

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface AllDatatypesTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation AllDatatypesTest

- (void)testAllNull {
  AllNullableTypes *everything = [[AllNullableTypes alloc] init];
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FlutterIntegrationCoreApiGetCodec()];
  FlutterIntegrationCoreApi *api =
      [[FlutterIntegrationCoreApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoAllNullableTypes:everything
                 completion:^(AllNullableTypes *_Nonnull result, NSError *_Nullable error) {
                   XCTAssertNil(result.aNullableBool);
                   XCTAssertNil(result.aNullableInt);
                   XCTAssertNil(result.aNullableDouble);
                   XCTAssertNil(result.aNullableString);
                   XCTAssertNil(result.aNullableByteArray);
                   XCTAssertNil(result.aNullable4ByteArray);
                   XCTAssertNil(result.aNullable8ByteArray);
                   XCTAssertNil(result.aNullableFloatArray);
                   XCTAssertNil(result.aNullableList);
                   XCTAssertNil(result.aNullableMap);
                   [expectation fulfill];
                 }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testAllEquals {
  AllNullableTypes *everything = [[AllNullableTypes alloc] init];
  everything.aNullableBool = @NO;
  everything.aNullableInt = @(1);
  everything.aNullableDouble = @(2.0);
  everything.aNullableString = @"123";
  everything.aNullableByteArray = [FlutterStandardTypedData
      typedDataWithBytes:[@"1234" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.aNullable4ByteArray = [FlutterStandardTypedData
      typedDataWithInt32:[@"1234" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.aNullable8ByteArray = [FlutterStandardTypedData
      typedDataWithInt64:[@"12345678" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.aNullableFloatArray = [FlutterStandardTypedData
      typedDataWithFloat64:[@"12345678" dataUsingEncoding:NSUTF8StringEncoding]];
  everything.aNullableList = @[ @(1), @(2) ];
  everything.aNullableMap = @{@"hello" : @(1234)};
  everything.nullableMapWithObject = @{@"hello" : @(1234), @"goodbye" : @"world"};
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FlutterIntegrationCoreApiGetCodec()];
  FlutterIntegrationCoreApi *api =
      [[FlutterIntegrationCoreApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoAllNullableTypes:everything
                 completion:^(AllNullableTypes *_Nonnull result, NSError *_Nullable error) {
                   XCTAssertEqual(result.aNullableBool, everything.aNullableBool);
                   XCTAssertEqual(result.aNullableInt, everything.aNullableInt);
                   XCTAssertEqual(result.aNullableDouble, everything.aNullableDouble);
                   XCTAssertEqualObjects(result.aNullableString, everything.aNullableString);
                   XCTAssertEqualObjects(result.aNullableByteArray.data,
                                         everything.aNullableByteArray.data);
                   XCTAssertEqualObjects(result.aNullable4ByteArray.data,
                                         everything.aNullable4ByteArray.data);
                   XCTAssertEqualObjects(result.aNullable8ByteArray.data,
                                         everything.aNullable8ByteArray.data);
                   XCTAssertEqualObjects(result.aNullableFloatArray.data,
                                         everything.aNullableFloatArray.data);
                   XCTAssertEqualObjects(result.aNullableList, everything.aNullableList);
                   XCTAssertEqualObjects(result.aNullableMap, everything.aNullableMap);
                   XCTAssertEqualObjects(result.nullableMapWithObject,
                                         everything.nullableMapWithObject);
                   [expectation fulfill];
                 }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
