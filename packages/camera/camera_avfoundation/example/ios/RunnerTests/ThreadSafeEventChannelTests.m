// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
#import <OCMock/OCMock.h>

@interface ThreadSafeEventChannelTests : XCTestCase
@end

@implementation ThreadSafeEventChannelTests

- (void)testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread {
  FlutterEventChannel *mockEventChannel = OCMClassMock([FlutterEventChannel class]);
  FLTThreadSafeEventChannel *threadSafeEventChannel =
      [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  XCTestExpectation *mainThreadExpectation =
      [self expectationWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation =
      [self expectationWithDescription:
                @"setStreamHandler's completion block must be called on the main thread"];
  OCMStub([mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  });

  [threadSafeEventChannel setStreamHandler:nil
                                completion:^{
                                  if (NSThread.isMainThread) {
                                    [mainThreadCompletionExpectation fulfill];
                                  }
                                }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  FlutterEventChannel *mockEventChannel = OCMClassMock([FlutterEventChannel class]);
  FLTThreadSafeEventChannel *threadSafeEventChannel =
      [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  XCTestExpectation *mainThreadExpectation =
      [self expectationWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation =
      [self expectationWithDescription:
                @"setStreamHandler's completion block must be called on the main thread"];
  OCMStub([mockEventChannel setStreamHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  });

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [threadSafeEventChannel setStreamHandler:nil
                                  completion:^{
                                    if (NSThread.isMainThread) {
                                      [mainThreadCompletionExpectation fulfill];
                                    }
                                  }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testEventChannel_shouldBeKeptAliveWhenDispatchingBackToMainThread {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Completion should be called."];
  dispatch_async(dispatch_queue_create("test", NULL), ^{
    FLTThreadSafeEventChannel *channel = [[FLTThreadSafeEventChannel alloc]
        initWithEventChannel:OCMClassMock([FlutterEventChannel class])];

    [channel setStreamHandler:OCMOCK_ANY
                   completion:^{
                     [expectation fulfill];
                   }];
  });

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
