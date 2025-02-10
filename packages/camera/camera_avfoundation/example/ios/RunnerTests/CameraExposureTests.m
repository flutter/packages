// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import XCTest;
@import AVFoundation;

#import "CameraTestUtils.h"
#import "MockCaptureDevice.h"
#import "MockDeviceOrientationProvider.h"

@interface CameraExposureTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) MockCaptureDevice *mockDevice;
@property(readonly, nonatomic) MockDeviceOrientationProvider *mockDeviceOrientationProvider;
@end

@implementation CameraExposureTests

- (void)setUp {
  MockCaptureDevice *mockDevice = [[MockCaptureDevice alloc] init];
  _mockDeviceOrientationProvider = [[MockDeviceOrientationProvider alloc] init];
  _mockDevice = mockDevice;

  FLTCamConfiguration *configuration = FLTCreateTestCameraConfiguration();
  configuration.captureDeviceFactory = ^NSObject<FLTCaptureDevice> *_Nonnull { return mockDevice; };
  configuration.deviceOrientationProvider = _mockDeviceOrientationProvider;
  _camera = FLTCreateCamWithConfiguration(configuration);
}

- (void)testSetExposurePointWithResult_SetsExposurePointOfInterest {
  // UI is currently in landscape left orientation
  _mockDeviceOrientationProvider.orientation = UIDeviceOrientationLandscapeLeft;
  // Exposure point of interest is supported
  _mockDevice.exposurePointOfInterestSupported = YES;

  // Verify the focus point of interest has been set
  __block CGPoint setPoint = CGPointZero;
  _mockDevice.setExposurePointOfInterestStub = ^(CGPoint point) {
    if (CGPointEqualToPoint(CGPointMake(1, 1), point)) {
      setPoint = point;
    }
  };

  // Run test
  XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Completion called"];
  [_camera setExposurePoint:[FCPPlatformPoint makeWithX:1 y:1]
             withCompletion:^(FlutterError *_Nullable error) {
               XCTAssertNil(error);
               [completionExpectation fulfill];
             }];

  [self waitForExpectationsWithTimeout:30 handler:nil];
  XCTAssertEqual(setPoint.x, 1.0);
  XCTAssertEqual(setPoint.y, 1.0);
}

- (void)testSetExposurePoint_WhenNotSupported_ReturnsError {
  // UI is currently in landscape left orientation
  _mockDeviceOrientationProvider.orientation = UIDeviceOrientationLandscapeLeft;
  // Exposure point of interest is not supported
  _mockDevice.exposurePointOfInterestSupported = NO;

  XCTestExpectation *expectation = [self expectationWithDescription:@"Completion with error"];

  // Run
  [_camera
      setExposurePoint:[FCPPlatformPoint makeWithX:1 y:1]
        withCompletion:^(FlutterError *_Nullable error) {
          XCTAssertNotNil(error);
          XCTAssertEqualObjects(error.code, @"setExposurePointFailed");
          XCTAssertEqualObjects(error.message, @"Device does not have exposure point capabilities");
          [expectation fulfill];
        }];

  // Verify
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
