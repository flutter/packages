// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface AllDatatypesTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation AllDatatypesTest

- (void)testAllNull {
  FLTAllNullableTypes *everything = [[FLTAllNullableTypes alloc] init];
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FLTCoreTestsGetCodec()];
  FLTFlutterIntegrationCoreApi *api =
      [[FLTFlutterIntegrationCoreApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoAllNullableTypes:everything
                 completion:^(FLTAllNullableTypes *_Nonnull result, FlutterError *_Nullable error) {
                   XCTAssertNil(result.aNullableBool);
                   XCTAssertNil(result.aNullableInt);
                   XCTAssertNil(result.aNullableDouble);
                   XCTAssertNil(result.aNullableString);
                   XCTAssertNil(result.aNullableByteArray);
                   XCTAssertNil(result.aNullable4ByteArray);
                   XCTAssertNil(result.aNullable8ByteArray);
                   XCTAssertNil(result.aNullableFloatArray);
                   XCTAssertNil(result.allNullableLists.list);
                   XCTAssertNil(result.allNullableLists.boolList);
                   XCTAssertNil(result.allNullableLists.intList);
                   XCTAssertNil(result.allNullableLists.doubleList);
                   XCTAssertNil(result.allNullableLists.stringList);
                   XCTAssertNil(result.allNullableMaps.map);
                   [expectation fulfill];
                 }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testAllEquals {
  FLTAllNullableTypes *everything = [[FLTAllNullableTypes alloc] init];
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
  everything.nullableMapWithObject = @{@"hello" : @(1234), @"goodbye" : @"world"};
  everything.allNullableLists = [[FLTAllNullableListTypes alloc] init];
  everything.allNullableMaps = [[FLTAllNullableMapTypes alloc] init];
  everything.allNullableLists.boolList = @[ @YES, @NO ];
  everything.allNullableLists.intList = @[ @1, @2 ];
  everything.allNullableLists.doubleList = @[ @1.1, @2.2 ];
  everything.allNullableLists.stringList = @[ @"string", @"another one" ];
  everything.allNullableLists.list = @[ @"string", @1 ];
  everything.allNullableMaps.map = @{@"hello" : @(1234), @"goodbye" : @"world"};
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FLTCoreTestsGetCodec()];
  FLTFlutterIntegrationCoreApi *api =
      [[FLTFlutterIntegrationCoreApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api
      echoAllNullableTypes:everything
                completion:^(FLTAllNullableTypes *_Nonnull result, FlutterError *_Nullable error) {
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
                  XCTAssertEqualObjects(result.nullableMapWithObject,
                                        everything.nullableMapWithObject);
                  XCTAssertEqualObjects(result.allNullableLists.list,
                                        everything.allNullableLists.list);
                  XCTAssertEqualObjects(result.allNullableLists.boolList,
                                        everything.allNullableLists.boolList);
                  XCTAssertEqualObjects(result.allNullableLists.intList,
                                        everything.allNullableLists.intList);
                  XCTAssertEqualObjects(result.allNullableLists.doubleList,
                                        everything.allNullableLists.doubleList);
                  XCTAssertEqualObjects(result.allNullableLists.stringList,
                                        everything.allNullableLists.stringList);
                  XCTAssertEqualObjects(result.allNullableMaps.map, everything.allNullableMaps.map);
                  [expectation fulfill];
                }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
