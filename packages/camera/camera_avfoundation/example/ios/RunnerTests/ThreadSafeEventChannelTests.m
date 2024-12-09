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
@property(readonly, nonatomic) MockEventChannel *mockEventChannel;
@property(readonly, nonatomic) FLTThreadSafeEventChannel *threadSafeEventChannel;
@end

@implementation ThreadSafeEventChannelTests

- (void)setUp {
  [super setUp];
  _mockEventChannel = [[MockEventChannel alloc] init];
  _threadSafeEventChannel =
       [[FLTThreadSafeEventChannel alloc] initWithEventChannel:_mockEventChannel];
}

- (void)testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread {
  XCTestExpectation *mainThreadExpectation =
      [self expectationWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation =
      [self expectationWithDescription:
                @"setStreamHandler's completion block must be called on the main thread"];
  
  [_mockEventChannel setSetStreamHandlerStub:^(NSObject<FlutterStreamHandler> *handler) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  }];
  
  [_threadSafeEventChannel setStreamHandler:nil
                                completion:^{
                                  if (NSThread.isMainThread) {
                                    [mainThreadCompletionExpectation fulfill];
                                  }
                                }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread {
  XCTestExpectation *mainThreadExpectation =
      [self expectationWithDescription:@"setStreamHandler must be called on the main thread"];
  XCTestExpectation *mainThreadCompletionExpectation =
      [self expectationWithDescription:
                @"setStreamHandler's completion block must be called on the main thread"];
  
  
  [_mockEventChannel setSetStreamHandlerStub:^(NSObject<FlutterStreamHandler> *handler) {
    if (NSThread.isMainThread) {
      [mainThreadExpectation fulfill];
    }
  }];

  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [weakSelf.threadSafeEventChannel setStreamHandler:nil
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
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_queue_create("test", NULL), ^{
    FLTThreadSafeEventChannel *channel = [[FLTThreadSafeEventChannel alloc]
                                          initWithEventChannel:weakSelf.mockEventChannel];

    [channel setStreamHandler:nil
                   completion:^{
                     [expectation fulfill];
                   }];
  });

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
