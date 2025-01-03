// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import Flutter;

#import "MockCameraDeviceDiscoverer.h"
#import "MockCaptureDeviceController.h"
#import "MockCaptureSession.h"
#import "MockDeviceOrientationProvider.h"

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

@interface MockCamera : FLTCam
@property(nonatomic, copy) void (^setDeviceOrientationStub)(UIDeviceOrientation orientation);
@end

@implementation MockCamera
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
  if (self.setDeviceOrientationStub) {
    self.setDeviceOrientationStub(orientation);
  }
}

- (void)setCaptureDevice:(id<FLTCaptureDeviceControlling>)device {
  self.captureDevice = device;
}

@end

@interface MockUIDevice : UIDevice
@property(nonatomic, assign) UIDeviceOrientation mockOrientation;
@end

@implementation MockUIDevice
- (UIDeviceOrientation)orientation {
  return self.mockOrientation;
}

@end

#pragma mark -

@interface CameraOrientationTests : XCTestCase
@property(readonly, nonatomic) MockCamera *camera;
@property(readonly, nonatomic) MockCaptureDeviceController *mockDevice;
@property(readonly, nonatomic) StubGlobalEventApi *eventAPI;
@property(readonly, nonatomic) CameraPlugin *cameraPlugin;
@property(readonly, nonatomic) MockCameraDeviceDiscoverer *deviceDiscoverer;
@end

@implementation CameraOrientationTests

- (void)setUp {
  [super setUp];
  MockCaptureDeviceController *mockDevice = [[MockCaptureDeviceController alloc] init];
  _camera = [[MockCamera alloc] init];
  _eventAPI = [[StubGlobalEventApi alloc] init];
  _mockDevice = mockDevice;
  _deviceDiscoverer = [[MockCameraDeviceDiscoverer alloc] init];

  _cameraPlugin = [[CameraPlugin alloc] initWithRegistry:nil
                                               messenger:nil
                                               globalAPI:_eventAPI
                                        deviceDiscoverer:_deviceDiscoverer
                                           deviceFactory:^id<FLTCaptureDeviceControlling>(NSString *name) {
                                              return mockDevice;
                                            }
                                   captureSessionFactory:^id<FLTCaptureSession> _Nonnull{
    return [[MockCaptureSession alloc] init];
  }
  ];
  _cameraPlugin.camera = _camera;
}

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
  [self sendOrientation:UIDeviceOrientationPortraitUpsideDown toCamera:_cameraPlugin];
  XCTAssertEqual(_eventAPI.lastOrientation, FCPPlatformDeviceOrientationPortraitDown);
  [self sendOrientation:UIDeviceOrientationPortrait toCamera:_cameraPlugin];
  XCTAssertEqual(_eventAPI.lastOrientation, FCPPlatformDeviceOrientationPortraitUp);
  [self sendOrientation:UIDeviceOrientationLandscapeLeft toCamera:_cameraPlugin];
  XCTAssertEqual(_eventAPI.lastOrientation, FCPPlatformDeviceOrientationLandscapeLeft);
  [self sendOrientation:UIDeviceOrientationLandscapeRight toCamera:_cameraPlugin];
  XCTAssertEqual(_eventAPI.lastOrientation, FCPPlatformDeviceOrientationLandscapeRight);
}

- (void)testOrientationNotificationsNotCalledForFaceUp {
  [self sendOrientation:UIDeviceOrientationFaceUp toCamera:_cameraPlugin];

  XCTAssertFalse(_eventAPI.called);
}

- (void)testOrientationNotificationsNotCalledForFaceDown {
  [self sendOrientation:UIDeviceOrientationFaceDown toCamera:_cameraPlugin];

  XCTAssertFalse(_eventAPI.called);
}

- (void)testOrientationUpdateMustBeOnCaptureSessionQueue {
  XCTestExpectation *queueExpectation = [self
      expectationWithDescription:@"Orientation update must happen on the capture session queue"];

  CameraPlugin *plugin = [[CameraPlugin alloc] initWithRegistry:nil messenger:nil];
  const char *captureSessionQueueSpecific = "capture_session_queue";
  dispatch_queue_set_specific(plugin.captureSessionQueue, captureSessionQueueSpecific,
                              (void *)captureSessionQueueSpecific, NULL);
  plugin.camera = _camera;

  _camera.setDeviceOrientationStub = ^(UIDeviceOrientation orientation) {
    if (dispatch_get_specific(captureSessionQueueSpecific)) {
      [queueExpectation fulfill];
    }
  };

  [plugin orientationChanged:
              [self createMockNotificationForOrientation:UIDeviceOrientationLandscapeLeft]];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testOrientationChanged_noRetainCycle {
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);

  __weak CameraPlugin *weakPlugin;
  __weak MockCaptureDeviceController *weakDevice = _mockDevice;

  @autoreleasepool {
    CameraPlugin *plugin = [[CameraPlugin alloc] initWithRegistry:nil
                                                        messenger:nil
                                                        globalAPI:_eventAPI
                                                 deviceDiscoverer:_deviceDiscoverer
                                                    deviceFactory:^id<FLTCaptureDeviceControlling>(NSString *name) {
                                                       return weakDevice;
                                                     }
                                            captureSessionFactory:^id<FLTCaptureSession> _Nonnull{
             return [[MockCaptureSession alloc] init];
           }
    ];
    weakPlugin = plugin;
    plugin.captureSessionQueue = captureSessionQueue;
    plugin.camera = _camera;

    [plugin orientationChanged:
                [self createMockNotificationForOrientation:UIDeviceOrientationLandscapeLeft]];
  }

  // Sanity check
  XCTAssertNil(weakPlugin, @"Camera must have been deallocated.");

  __block BOOL setDeviceOrientationCalled = NO;
  _camera.setDeviceOrientationStub = ^(UIDeviceOrientation orientation) {
    if (orientation == UIDeviceOrientationLandscapeLeft) {
      setDeviceOrientationCalled = YES;
    }
  };

  __weak StubGlobalEventApi *weakEventAPI = _eventAPI;

  // Must check in captureSessionQueue since orientationChanged dispatches to this queue.
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Dispatched to capture session queue"];
  dispatch_async(captureSessionQueue, ^{
    XCTAssertFalse(setDeviceOrientationCalled);
    XCTAssertFalse(weakEventAPI.called);
    [expectation fulfill];
  });

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (NSNotification *)createMockNotificationForOrientation:(UIDeviceOrientation)deviceOrientation {
  MockUIDevice *mockDevice = [[MockUIDevice alloc] init];
  mockDevice.mockOrientation = deviceOrientation;

  return [NSNotification notificationWithName:@"orientation_test" object:mockDevice];
}

@end
