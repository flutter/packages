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
#import "MockFlutterBinaryMessenger.h"

@interface MockImageStreamHandler : FLTImageStreamHandler
@property(nonatomic, copy) void (^eventSinkStub)(id event);
@end

@implementation MockImageStreamHandler

- (FlutterEventSink)eventSink {
  if (self.eventSinkStub) {
    return ^(id event) {
      self.eventSinkStub(event);
    };
  }
  return nil;
}

@end

@interface StreamingTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) CMSampleBufferRef sampleBuffer;
@end

@implementation StreamingTests

- (void)setUp {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("testing", NULL);
  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.captureSessionQueue = captureSessionQueue;

  _camera = FLTCreateCamWithConfiguration(configuration);
  _sampleBuffer = FLTCreateTestSampleBuffer();
}

- (void)tearDown {
  CFRelease(_sampleBuffer);
}

- (void)testExceedMaxStreamingPendingFramesCount {
  XCTestExpectation *streamingExpectation = [self
      expectationWithDescription:@"Must not call handler over maxStreamingPendingFramesCount"];

  MockImageStreamHandler *handlerMock = [[MockImageStreamHandler alloc] init];
  handlerMock.eventSinkStub = ^(id event) {
    [streamingExpectation fulfill];
  };

  MockFlutterBinaryMessenger *messenger = [[MockFlutterBinaryMessenger alloc] init];
  [_camera startImageStreamWithMessenger:messenger imageStreamHandler:handlerMock];

  XCTKVOExpectation *expectation = [[XCTKVOExpectation alloc] initWithKeyPath:@"isStreamingImages"
                                                                       object:_camera
                                                                expectedValue:@YES];
  XCTWaiterResult result = [XCTWaiter waitForExpectations:@[ expectation ] timeout:1];
  XCTAssertEqual(result, XCTWaiterResultCompleted);

  streamingExpectation.expectedFulfillmentCount = 4;
  for (int i = 0; i < 10; i++) {
    [_camera captureOutput:nil didOutputSampleBuffer:self.sampleBuffer fromConnection:nil];
  }

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testReceivedImageStreamData {
  XCTestExpectation *streamingExpectation =
      [self expectationWithDescription:
                @"Must be able to call the handler again when receivedImageStreamData is called"];

  MockImageStreamHandler *handlerMock = [[MockImageStreamHandler alloc] init];
  handlerMock.eventSinkStub = ^(id event) {
    [streamingExpectation fulfill];
  };

  MockFlutterBinaryMessenger *messenger = [[MockFlutterBinaryMessenger alloc] init];
  [_camera startImageStreamWithMessenger:messenger imageStreamHandler:handlerMock];

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

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
