// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

#ifdef LEGACY_HARNESS
#import "Enum.gen.h"
#else
@import alternate_language_test_plugin;
#endif

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface EnumTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation EnumTest

- (void)testEcho {
  DataWithEnum *data = [[DataWithEnum alloc] init];
  data.state = EnumStateError;
  EchoBinaryMessenger *binaryMessenger =
      [[EchoBinaryMessenger alloc] initWithCodec:EnumApi2HostGetCodec()];
  EnumApi2Flutter *api = [[EnumApi2Flutter alloc] initWithBinaryMessenger:binaryMessenger];
  XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];
  [api echoData:data
      completion:^(DataWithEnum *_Nonnull result, NSError *_Nullable error) {
        XCTAssertEqual(data.state, result.state);
        [expectation fulfill];
      }];
  [self waitForExpectations:@[ expectation ] timeout:1.0];
}

@end
