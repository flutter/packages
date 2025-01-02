// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import GoogleMaps;
@import google_maps_flutter_ios;

#import <OCMock/OCMock.h>

#import "messages.g.h"

@interface FLTTileProviderControllerTests : XCTestCase
@end

@implementation FLTTileProviderControllerTests

- (void)testCallChannelOnPlatformThread {
  id handler = OCMClassMock([FGMMapsCallbackApi class]);
  FLTTileProviderController *controller =
      [[FLTTileProviderController alloc] initWithTileOverlayIdentifier:@"foo"
                                                       callbackHandler:handler];
  XCTAssertNotNil(controller);
  XCTestExpectation *expectation = [self expectationWithDescription:@"invokeMethod"];
  OCMStub([handler tileWithOverlayIdentifier:[OCMArg any]
                                    location:[OCMArg any]
                                        zoom:0
                                  completion:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        XCTAssertTrue([[NSThread currentThread] isMainThread]);
        [expectation fulfill];
      });
  id receiver = OCMProtocolMock(@protocol(GMSTileReceiver));
  [controller requestTileForX:0 y:0 zoom:0 receiver:receiver];
  [self waitForExpectations:@[ expectation ] timeout:10.0];
}

@end
