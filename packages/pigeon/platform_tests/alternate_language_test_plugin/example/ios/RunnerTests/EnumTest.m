// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface EnumTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation EnumTest

- (void)testEcho {
  PGNDataWithEnum *data = [[PGNDataWithEnum alloc] init];
  PGNEnumStateBox *stateBox = [[PGNEnumStateBox alloc] initWithValue:PGNEnumStateError];
  data.state = stateBox;
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:PGNGetEnumCodec()];
  PGNEnumApi2Flutter *api = [[PGNEnumApi2Flutter alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoData:data
      completion:^(PGNDataWithEnum *_Nonnull result, FlutterError *_Nullable error) {
        XCTAssertEqual(data.state.value, result.state.value);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
