// Copyright 2013 The Flutter Authors
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
      [[EchoBinaryMessenger alloc] initWithCodec:FLTGetCoreTestsCodec()];
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
                   XCTAssertNil(result.list);
                   XCTAssertNil(result.boolList);
                   XCTAssertNil(result.intList);
                   XCTAssertNil(result.doubleList);
                   XCTAssertNil(result.stringList);
                   XCTAssertNil(result.objectList);
                   XCTAssertNil(result.map);
                   XCTAssertNil(result.objectMap);
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
  everything.list = @[ @"string", @1 ];
  everything.boolList = @[ @YES, @NO ];
  everything.intList = @[ @1, @2 ];
  everything.doubleList = @[ @1.1, @2.2 ];
  everything.stringList = @[ @"string", @"another one" ];
  everything.objectList = @[ @"string", @1 ];
  everything.listList = @[ @[ @"string" ], @[ @"another one" ] ];
  everything.mapList = @[
    @{@"hello" : @(1234), @"goodbye" : @"world"}, @{@"hello" : @(1234), @"goodbye" : @"world"}
  ];
  everything.map = @{@"hello" : @(1234), @"goodbye" : @"world"};
  everything.stringMap = @{@"hello" : @"you", @"goodbye" : @"world"};
  everything.intMap = @{@(1) : @(0), @(2) : @(-2)};
  everything.objectMap = @{@"hello" : @(1234), @"goodbye" : @"world"};
  everything.listMap = @{@(1234) : @[ @"string", @"another one" ]};
  everything.mapMap = @{@(1234) : @{@"goodbye" : @"world"}};
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:FLTGetCoreTestsCodec()];
  FLTFlutterIntegrationCoreApi *api =
      [[FLTFlutterIntegrationCoreApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoAllNullableTypes:everything
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
                   XCTAssertEqualObjects(result.list, everything.list);
                   XCTAssertEqualObjects(result.boolList, everything.boolList);
                   XCTAssertEqualObjects(result.intList, everything.intList);
                   XCTAssertEqualObjects(result.doubleList, everything.doubleList);
                   XCTAssertEqualObjects(result.stringList, everything.stringList);
                   XCTAssertEqualObjects(result.objectList, everything.objectList);
                   XCTAssertEqualObjects(result.listList, everything.listList);
                   XCTAssertEqualObjects(result.mapList, everything.mapList);
                   XCTAssertEqualObjects(result.map, everything.map);
                   XCTAssertEqualObjects(result.stringMap, everything.stringMap);
                   XCTAssertEqualObjects(result.intMap, everything.intMap);
                   XCTAssertEqualObjects(result.objectMap, everything.objectMap);
                   XCTAssertEqualObjects(result.listMap, everything.listMap);
                   XCTAssertEqualObjects(result.mapMap, everything.mapMap);
                   [expectation fulfill];
                 }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testEquality {
  FLTAllNullableTypes *everything1 = [[FLTAllNullableTypes alloc] init];
  everything1.aNullableBool = @NO;
  everything1.aNullableInt = @(1);
  everything1.aNullableString = @"123";

  FLTAllNullableTypes *everything2 = [[FLTAllNullableTypes alloc] init];
  everything2.aNullableBool = @NO;
  everything2.aNullableInt = @(1);
  everything2.aNullableString = @"123";

  FLTAllNullableTypes *everything3 = [[FLTAllNullableTypes alloc] init];
  everything3.aNullableBool = @YES;

  XCTAssertEqualObjects(everything1, everything2);
  XCTAssertNotEqualObjects(everything1, everything3);
  XCTAssertEqual(everything1.hash, everything2.hash);
}

- (void)testNaNEquality {
  FLTAllNullableTypes *everything1 = [[FLTAllNullableTypes alloc] init];
  everything1.aNullableDouble = @(NAN);

  FLTAllNullableTypes *everything2 = [[FLTAllNullableTypes alloc] init];
  everything2.aNullableDouble = @(NAN);

  XCTAssertEqualObjects(everything1, everything2);
  XCTAssertEqual(everything1.hash, everything2.hash);
}

- (void)testCrossTypeEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.aNullableInt = @(1);

  FLTAllNullableTypesWithoutRecursion *b = [[FLTAllNullableTypesWithoutRecursion alloc] init];
  b.aNullableInt = @(1);

  XCTAssertNotEqualObjects(a, b);
  XCTAssertNotEqualObjects(b, a);
}

- (void)testZeroEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.aNullableDouble = @(0.0);

  FLTAllNullableTypes *b = [[FLTAllNullableTypes alloc] init];
  b.aNullableDouble = @(-0.0);

  XCTAssertEqualObjects(a, b);
  XCTAssertEqual(a.hash, b.hash);
}

- (void)testNestedNaNEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.aNullableDouble = @(nan(""));
  a.doubleList = @[ @(nan("")) ];

  FLTAllNullableTypes *b = [[FLTAllNullableTypes alloc] init];
  b.aNullableDouble = @(nan(""));
  b.doubleList = @[ @(nan("")) ];

  // If this fails, Objective-C needs a deepEquals helper too.
  XCTAssertEqualObjects(a, b);
  XCTAssertEqual(a.hash, b.hash);
}

- (void)testNestedZeroListEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.doubleList = @[ @(0.0) ];

  FLTAllNullableTypes *b = [[FLTAllNullableTypes alloc] init];
  b.doubleList = @[ @(-0.0) ];

  XCTAssertEqualObjects(a, b);
  XCTAssertEqual(a.hash, b.hash);
}

- (void)testZeroMapKeyEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.map = @{@(0.0) : @"a"};

  FLTAllNullableTypes *b = [[FLTAllNullableTypes alloc] init];
  b.map = @{@(-0.0) : @"a"};

  XCTAssertEqualObjects(a, b);
  XCTAssertEqual(a.hash, b.hash);
}

- (void)testZeroMapValueEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.map = @{@"a" : @(0.0)};

  FLTAllNullableTypes *b = [[FLTAllNullableTypes alloc] init];
  b.map = @{@"a" : @(-0.0)};

  XCTAssertEqualObjects(a, b);
  XCTAssertEqual(a.hash, b.hash);
}

- (void)testNSNullListEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.list = @[ [NSNull null] ];

  FLTAllNullableTypes *b = [[FLTAllNullableTypes alloc] init];
  b.list = @[ [NSNull null] ];

  XCTAssertEqualObjects(a, b);
  XCTAssertEqual(a.hash, b.hash);
}

- (void)testNSNullPropertyEquality {
  FLTAllNullableTypes *a = [[FLTAllNullableTypes alloc] init];
  a.aNullableObject = [NSNull null];

  FLTAllNullableTypes *b = [[FLTAllNullableTypes alloc] init];
  b.aNullableObject = nil;

  XCTAssertEqualObjects(a, b);
  XCTAssertEqual(a.hash, b.hash);
}

@end
