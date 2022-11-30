// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "EchoMessenger.h"
#import "MockBinaryMessenger.h"
#import "NullableReturns.gen.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface MockNullableArgHostApi : NSObject <NullableArgHostApi>
@property(nonatomic, assign) BOOL didCall;
@property(nonatomic, copy) NSNumber *x;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation MockNullableArgHostApi
- (nullable NSNumber *)doitX:(NSNumber *_Nullable)x
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  _didCall = YES;
  self.x = x;
  return x;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullableReturnsTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation NullableReturnsTest

- (void)testNullableParameterWithFlutterApi {
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:NullableArgHostApiGetCodec()];
  NullableArgFlutterApi *api =
      [[NullableArgFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api doitX:nil
      completion:^(NSNumber *_Nonnull result, NSError *_Nullable error) {
        XCTAssertNil(result);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testNullableParameterWithHostApi {
  MockNullableArgHostApi *api = [[MockNullableArgHostApi alloc] init];
  MockBinaryMessenger *binaryMessenger =
      [[MockBinaryMessenger alloc] initWithCodec:NullableArgHostApiGetCodec()];
  NSString *channel = @"dev.flutter.pigeon.NullableArgHostApi.doit";
  NullableArgHostApiSetup(binaryMessenger, api);
  XCTAssertNotNil(binaryMessenger.handlers[channel]);
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  NSData *arguments = [NullableArgHostApiGetCodec() encode:@[ [NSNull null] ]];
  binaryMessenger.handlers[channel](arguments, ^(NSData *data) {
    [expectation fulfill];
  });
  XCTAssertTrue(api.didCall);
  XCTAssertNil(api.x);
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
