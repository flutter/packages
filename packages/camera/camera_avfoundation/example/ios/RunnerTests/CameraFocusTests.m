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
#import "MockCaptureDevice.h"
#import "MockDeviceOrientationProvider.h"

@interface CameraFocusTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) MockCaptureDevice *mockDevice;
@property(readonly, nonatomic) MockDeviceOrientationProvider *mockDeviceOrientationProvider;
@end

@implementation CameraFocusTests

- (void)setUp {
  MockCaptureDevice *mockDevice = [[MockCaptureDevice alloc] init];
  _mockDevice = mockDevice;
  _mockDeviceOrientationProvider = [[MockDeviceOrientationProvider alloc] init];

  _camera = FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
      nil, nil, nil,
      ^NSObject<FLTCaptureDevice> *(void) {
        return mockDevice;
      },
      _mockDeviceOrientationProvider);
}

- (void)testAutoFocusWithContinuousModeSupported_ShouldSetContinuousAutoFocus {
  // AVCaptureFocusModeContinuousAutoFocus and AVCaptureFocusModeContinuousAutoFocus are supported
  _mockDevice.isFocusModeSupportedStub = ^BOOL(AVCaptureFocusMode mode) {
    return mode == AVCaptureFocusModeContinuousAutoFocus || mode == AVCaptureFocusModeAutoFocus;
  };

  __block BOOL setFocusModeContinuousAutoFocusCalled = NO;

  _mockDevice.setFocusModeStub = ^(AVCaptureFocusMode mode) {
    // Don't expect setFocusMode:AVCaptureFocusModeAutoFocus
    if (mode == AVCaptureFocusModeAutoFocus) {
      XCTFail(@"Unexpected call to setFocusMode");
    } else if (mode == AVCaptureFocusModeContinuousAutoFocus) {
      setFocusModeContinuousAutoFocusCalled = YES;
    }
  };

  // Run test
  [_camera applyFocusMode:FCPPlatformFocusModeAuto onDevice:_mockDevice];

  // Expect setFocusMode:AVCaptureFocusModeContinuousAutoFocus
  XCTAssertTrue(setFocusModeContinuousAutoFocusCalled);
}

- (void)testAutoFocusWithContinuousModeNotSupported_ShouldSetAutoFocus {
  // AVCaptureFocusModeContinuousAutoFocus is not supported
  // AVCaptureFocusModeAutoFocus is supported
  _mockDevice.isFocusModeSupportedStub = ^BOOL(AVCaptureFocusMode mode) {
    return mode == AVCaptureFocusModeAutoFocus;
  };

  __block BOOL setFocusModeAutoFocusCalled = NO;

  // Don't expect setFocusMode:AVCaptureFocusModeContinuousAutoFocus
  _mockDevice.setFocusModeStub = ^(AVCaptureFocusMode mode) {
    if (mode == AVCaptureFocusModeContinuousAutoFocus) {
      XCTFail(@"Unexpected call to setFocusMode");
    } else if (mode == AVCaptureFocusModeAutoFocus) {
      setFocusModeAutoFocusCalled = YES;
    }
  };

  // Run test
  [_camera applyFocusMode:FCPPlatformFocusModeAuto onDevice:_mockDevice];

  // Expect setFocusMode:AVCaptureFocusModeAutoFocus
  XCTAssertTrue(setFocusModeAutoFocusCalled);
}

- (void)testAutoFocusWithNoModeSupported_ShouldSetNothing {
  // No modes are supported
  _mockDevice.isFocusModeSupportedStub = ^BOOL(AVCaptureFocusMode mode) {
    return NO;
  };

  // Don't expect any setFocus
  _mockDevice.setFocusModeStub = ^(AVCaptureFocusMode mode) {
    XCTFail(@"Unexpected call to setFocusMode");
  };

  // Run test
  [_camera applyFocusMode:FCPPlatformFocusModeAuto onDevice:_mockDevice];
}

- (void)testLockedFocusWithModeSupported_ShouldSetModeAutoFocus {
  // AVCaptureFocusModeContinuousAutoFocus and AVCaptureFocusModeAutoFocus are supported
  _mockDevice.isFocusModeSupportedStub = ^BOOL(AVCaptureFocusMode mode) {
    return mode == AVCaptureFocusModeContinuousAutoFocus || mode == AVCaptureFocusModeAutoFocus;
  };

  __block BOOL setFocusModeAutoFocusCalled = NO;

  // Expect only setFocusMode:AVCaptureFocusModeAutoFocus
  _mockDevice.setFocusModeStub = ^(AVCaptureFocusMode mode) {
    if (mode == AVCaptureFocusModeContinuousAutoFocus) {
      XCTFail(@"Unexpected call to setFocusMode");
    } else if (mode == AVCaptureFocusModeAutoFocus) {
      setFocusModeAutoFocusCalled = YES;
    }
  };

  // Run test
  [_camera applyFocusMode:FCPPlatformFocusModeLocked onDevice:_mockDevice];

  XCTAssertTrue(setFocusModeAutoFocusCalled);
}

- (void)testLockedFocusWithModeNotSupported_ShouldSetNothing {
  _mockDevice.isFocusModeSupportedStub = ^BOOL(AVCaptureFocusMode mode) {
    return mode == AVCaptureFocusModeContinuousAutoFocus;
  };

  // Don't expect any setFocus
  _mockDevice.setFocusModeStub = ^(AVCaptureFocusMode mode) {
    XCTFail(@"Unexpected call to setFocusMode");
  };

  // Run test
  [_camera applyFocusMode:FCPPlatformFocusModeLocked onDevice:_mockDevice];
}

- (void)testSetFocusPointWithResult_SetsFocusPointOfInterest {
  // UI is currently in landscape left orientation
  _mockDeviceOrientationProvider.orientation = UIDeviceOrientationLandscapeLeft;
  // Focus point of interest is supported
  _mockDevice.focusPointOfInterestSupported = YES;

  __block BOOL setFocusPointOfInterestCalled = NO;
  _mockDevice.setFocusPointOfInterestStub = ^(CGPoint point) {
    if (point.x == 1 && point.y == 1) {
      setFocusPointOfInterestCalled = YES;
    }
  };

  // Run test
  [_camera setFocusPoint:[FCPPlatformPoint makeWithX:1 y:1]
          withCompletion:^(FlutterError *_Nullable error){
          }];

  // Verify the focus point of interest has been set
  XCTAssertTrue(setFocusPointOfInterestCalled);
}

- (void)testSetFocusPoint_WhenNotSupported_ReturnsError {
  // UI is currently in landscape left orientation
  _mockDeviceOrientationProvider.orientation = UIDeviceOrientationLandscapeLeft;
  // Exposure point of interest is not supported
  _mockDevice.focusPointOfInterestSupported = NO;

  XCTestExpectation *expectation = [self expectationWithDescription:@"Completion with error"];

  // Run
  [_camera setFocusPoint:[FCPPlatformPoint makeWithX:1 y:1]
          withCompletion:^(FlutterError *_Nullable error) {
            XCTAssertNotNil(error);
            XCTAssertEqualObjects(error.code, @"setFocusPointFailed");
            XCTAssertEqualObjects(error.message, @"Device does not have focus point capabilities");
            [expectation fulfill];
          }];

  // Verify
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
