// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import GoogleMaps;
@import google_maps_flutter_ios;

#import <OCMock/OCMock.h>

@interface FLTTileProviderController ()
- (void)requestTileForX:(NSUInteger)x
                      y:(NSUInteger)y
                   zoom:(NSUInteger)zoom
               receiver:(id<GMSTileReceiver>)receiver;
@end

@interface FLTTileProviderControllerTests : XCTestCase
@end

@implementation FLTTileProviderControllerTests

- (void)testFoo {
  id channel = OCMClassMock(FlutterMethodChannel.class);
  FLTTileProviderController *controller = [[FLTTileProviderController alloc] init:channel
                                                        withTileOverlayIdentifier:@"foo"];
  XCTAssertNotNil(controller);
  XCTestExpectation *expectation = [self expectationWithDescription:@"invokeMethod"];
  OCMStub([channel invokeMethod:[OCMArg any] arguments:[OCMArg any] result:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        XCTAssertTrue([[NSThread currentThread] isMainThread]);
        [expectation fulfill];
      });
  [controller requestTileForX:0 y:0 zoom:0 receiver:nil];
  [self waitForExpectations:@[ expectation ] timeout:10.0];
}

@end
