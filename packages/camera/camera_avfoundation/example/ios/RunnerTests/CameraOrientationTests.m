// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import Flutter;

#import <OCMock/OCMock.h>

@interface StubGlobalEventApi : FCPCameraGlobalEventApi
@property(nonatomic) BOOL called;
@property(nonatomic) FCPPlatformDeviceOrientation lastOrientation;
@end

@implementation StubGlobalEventApi
- (void)deviceOrientationChangedOrientation:(FCPPlatformDeviceOrientation)orientation
                                 completion:(void (^)(FlutterError *_Nullable))completion {
  self.called = YES;
  self.lastOrientation = orientation;
  completion(nil);
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (nullable FlutterBinaryMessageHandler)handler {
  return 0;
}

@end

#pragma mark -

@interface CameraOrientationTests : XCTestCase
@end

@implementation CameraOrientationTests

// Ensure that the given queue and then the main queue have both cycled, to wait for any pending
// async events that may have been bounced between them.
- (void)waitForRoundTripWithQueue:(dispatch_queue_t)queue {
  XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Queue flush"];
  dispatch_async(queue, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [expectation fulfill];
    });
  });
  [self waitForExpectations:@[ expectation ]];
}

- (void)sendOrientation:(UIDeviceOrientation)orientation toCamera:(CameraPlugin *)cameraPlugin {
  [cameraPlugin orientationChanged:[self createMockNotificationForOrientation:orientation]];
  [self waitForRoundTripWithQueue:cameraPlugin.captureSessionQueue];
}

- (void)testOrientationNotifications {
  StubGlobalEventApi *eventAPI = [[StubGlobalEventApi alloc] init];
  CameraPlugin *cameraPlugin = [[CameraPlugin alloc] initWithRegistry:nil
                                                            messenger:nil
                                                            globalAPI:eventAPI];

  [self sendOrientation:UIDeviceOrientationPortraitUpsideDown toCamera:cameraPlugin];
  XCTAssertEqual(eventAPI.lastOrientation, FCPPlatformDeviceOrientationPortraitDown);
  [self sendOrientation:UIDeviceOrientationPortrait toCamera:cameraPlugin];
  XCTAssertEqual(eventAPI.lastOrientation, FCPPlatformDeviceOrientationPortraitUp);
  [self sendOrientation:UIDeviceOrientationLandscapeLeft toCamera:cameraPlugin];
  XCTAssertEqual(eventAPI.lastOrientation, FCPPlatformDeviceOrientationLandscapeLeft);
  [self sendOrientation:UIDeviceOrientationLandscapeRight toCamera:cameraPlugin];
  XCTAssertEqual(eventAPI.lastOrientation, FCPPlatformDeviceOrientationLandscapeRight);
}

- (void)testOrientationNotificationsNotCalledForFaceUp {
  StubGlobalEventApi *eventAPI = [[StubGlobalEventApi alloc] init];
  CameraPlugin *cameraPlugin = [[CameraPlugin alloc] initWithRegistry:nil
                                                            messenger:nil
                                                            globalAPI:eventAPI];

  [self sendOrientation:UIDeviceOrientationFaceUp toCamera:cameraPlugin];

  XCTAssertFalse(eventAPI.called);
}

- (void)testOrientationNotificationsNotCalledForFaceDown {
  StubGlobalEventApi *eventAPI = [[StubGlobalEventApi alloc] init];
  CameraPlugin *cameraPlugin = [[CameraPlugin alloc] initWithRegistry:nil
                                                            messenger:nil
                                                            globalAPI:eventAPI];

  [self sendOrientation:UIDeviceOrientationFaceDown toCamera:cameraPlugin];

  XCTAssertFalse(eventAPI.called);
}

- (void)testOrientationUpdateMustBeOnCaptureSessionQueue {
  XCTestExpectation *queueExpectation = [self
      expectationWithDescription:@"Orientation update must happen on the capture session queue"];

  CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  const char *captureSessionQueueSpecific = "capture_session_queue";
  dispatch_queue_set_specific(camera.captureSessionQueue, captureSessionQueueSpecific,
                              (void *)captureSessionQueueSpecific, NULL);
  FLTCam *mockCam = OCMClassMock([FLTCam class]);
  camera.camera = mockCam;
  OCMStub([mockCam setDeviceOrientation:UIDeviceOrientationLandscapeLeft])
      .andDo(^(NSInvocation *invocation) {
        if (dispatch_get_specific(captureSessionQueueSpecific)) {
          [queueExpectation fulfill];
        }
      });

  [camera orientationChanged:
              [self createMockNotificationForOrientation:UIDeviceOrientationLandscapeLeft]];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testOrientationChanged_noRetainCycle {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  FLTCam *mockCam = OCMClassMock([FLTCam class]);
  StubGlobalEventApi *stubAPI = [[StubGlobalEventApi alloc] init];

  __weak CameraPlugin *weakCamera;

  @autoreleasepool {
    CameraPlugin *camera = [[CameraPlugin alloc] initWithRegistry:nil
                                                        messenger:nil
                                                        globalAPI:stubAPI];
    weakCamera = camera;
    camera.captureSessionQueue = captureSessionQueue;
    camera.camera = mockCam;

    [camera orientationChanged:
                [self createMockNotificationForOrientation:UIDeviceOrientationLandscapeLeft]];
  }

  // Sanity check
  XCTAssertNil(weakCamera, @"Camera must have been deallocated.");

  // Must check in captureSessionQueue since orientationChanged dispatches to this queue.
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Dispatched to capture session queue"];
  dispatch_async(captureSessionQueue, ^{
    OCMVerify(never(), [mockCam setDeviceOrientation:UIDeviceOrientationLandscapeLeft]);
    XCTAssertFalse(stubAPI.called);
    [expectation fulfill];
  });

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (NSNotification *)createMockNotificationForOrientation:(UIDeviceOrientation)deviceOrientation {
  UIDevice *mockDevice = OCMClassMock([UIDevice class]);
  OCMStub([mockDevice orientation]).andReturn(deviceOrientation);

  return [NSNotification notificationWithName:@"orientation_test" object:mockDevice];
}

@end
