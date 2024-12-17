// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import AVFoundation;
#import "CameraTestUtils.h"

@interface MockImageStreamHandler : FLTImageStreamHandler
@property(nonatomic, copy) void (^onEventSinkCalled)(id event);
@end

@implementation MockImageStreamHandler

- (FlutterEventSink)eventSink {
  if (self.onEventSinkCalled) {
    return ^(id event) {
      self.onEventSinkCalled(event);
    };
  }
  return nil;
}

@end

@interface MockFlutterBinaryMessenger : NSObject <FlutterBinaryMessenger>
@end

@implementation MockFlutterBinaryMessenger
- (void)sendOnChannel:(NSString *)channel message:(NSData *)message {
}

- (void)sendOnChannel:(NSString *)channel
              message:(NSData *)message
          binaryReply:(FlutterBinaryReply)callback {
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler)handler {
  return 0;
}

- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
}

- (void)cleanupConnection:(FlutterBinaryMessengerConnection)connection {
}
@end

@interface StreamingTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) CMSampleBufferRef sampleBuffer;
@property(readonly, nonatomic) MockImageStreamHandler *mockStreamHandler;
@property(readonly, nonatomic) MockFlutterBinaryMessenger *messengerMock;

@end

@implementation StreamingTests

- (void)setUp {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("testing", NULL);
  _mockStreamHandler =
      [[MockImageStreamHandler alloc] initWithCaptureSessionQueue:captureSessionQueue];
  _camera = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  _sampleBuffer = FLTCreateTestSampleBuffer();
  _messengerMock = [[MockFlutterBinaryMessenger alloc] init];
}

- (void)tearDown {
  CFRelease(_sampleBuffer);
}

- (void)testExceedMaxStreamingPendingFramesCount {
  XCTestExpectation *streamingExpectation = [self
      expectationWithDescription:@"Must not call handler over maxStreamingPendingFramesCount"];

  _mockStreamHandler.onEventSinkCalled = ^(id eventSink) {
    [streamingExpectation fulfill];
  };

  [_camera startImageStreamWithMessenger:_messengerMock imageStreamHandler:_mockStreamHandler];

  XCTKVOExpectation *expectation = [[XCTKVOExpectation alloc] initWithKeyPath:@"isStreamingImages"
                                                                       object:_camera
                                                                expectedValue:@YES];
  XCTWaiterResult result = [XCTWaiter waitForExpectations:@[ expectation ] timeout:1];
  XCTAssertEqual(result, XCTWaiterResultCompleted);

  streamingExpectation.expectedFulfillmentCount = 4;
  for (int i = 0; i < 10; i++) {
    [_camera captureOutput:nil didOutputSampleBuffer:self.sampleBuffer fromConnection:nil];
  }

  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testReceivedImageStreamData {
  XCTestExpectation *streamingExpectation =
      [self expectationWithDescription:
                @"Must be able to call the handler again when receivedImageStreamData is called"];

  _mockStreamHandler.onEventSinkCalled = ^(id eventSink) {
    [streamingExpectation fulfill];
  };

  [_camera startImageStreamWithMessenger:_messengerMock imageStreamHandler:_mockStreamHandler];

  XCTKVOExpectation *expectation = [[XCTKVOExpectation alloc] initWithKeyPath:@"isStreamingImages"
                                                                       object:_camera
                                                                expectedValue:@YES];
  XCTWaiterResult result = [XCTWaiter waitForExpectations:@[ expectation ] timeout:1];
  XCTAssertEqual(result, XCTWaiterResultCompleted);

  streamingExpectation.expectedFulfillmentCount = 5;
  for (int i = 0; i < 10; i++) {
    [_camera captureOutput:nil didOutputSampleBuffer:self.sampleBuffer fromConnection:nil];
  }

  [_camera receivedImageStreamData];
  [_camera captureOutput:nil didOutputSampleBuffer:self.sampleBuffer fromConnection:nil];

  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
