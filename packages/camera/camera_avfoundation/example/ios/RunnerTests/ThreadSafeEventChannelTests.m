// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;

#import "MockEventChannel.h"

@interface ThreadSafeEventChannelTests : XCTestCase

@end

@implementation ThreadSafeEventChannelTests

- (void)testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread {
  MockEventChannel *mockEventChannel = [[MockEventChannel alloc] init];
  FLTThreadSafeEventChannel *threadSafeEventChannel =
      [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  XCTestExpectation *mainThreadExpectation =
      [self expectationWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation =
      [self expectationWithDescription:
                @"setStreamHandler's completion block must be called on the main thread"];

  [mockEventChannel setSetStreamHandlerStub:^(NSObject<FlutterStreamHandler> *handler) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  }];

  [threadSafeEventChannel setStreamHandler:nil
                                completion:^{
                                  if (NSThread.isMainThread) {
                                    [mainThreadCompletionExpectation fulfill];
                                  }
                                }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  MockEventChannel *mockEventChannel = [[MockEventChannel alloc] init];
  FLTThreadSafeEventChannel *threadSafeEventChannel =
      [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

  XCTestExpectation *mainThreadExpectation =
      [self expectationWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation =
      [self expectationWithDescription:
                @"setStreamHandler's completion block must be called on the main thread"];

  [mockEventChannel setSetStreamHandlerStub:^(NSObject<FlutterStreamHandler> *handler) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  }];

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
  MockEventChannel *mockEventChannel = [[MockEventChannel alloc] init];

  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Completion should be called."];

  dispatch_async(dispatch_queue_create("test", NULL), ^{
    FLTThreadSafeEventChannel *channel =
        [[FLTThreadSafeEventChannel alloc] initWithEventChannel:mockEventChannel];

    [channel setStreamHandler:nil
                   completion:^{
                     [expectation fulfill];
                   }];
  });

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
