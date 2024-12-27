// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import XCTest;
@import AVFoundation;

#import "MockCaptureDeviceController.h"
#import "MockDeviceOrientationProvider.h"

@interface CameraFocusTests : XCTestCase
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) MockCaptureDeviceController *mockDevice;
@property(readonly, nonatomic) MockDeviceOrientationProvider *mockDeviceOrientationProvider;
@end

@implementation CameraFocusTests

- (void)setUp {
  _camera = [[FLTCam alloc] init];
  _mockDevice = [[MockCaptureDeviceController alloc] init];
  _mockDeviceOrientationProvider = [[MockDeviceOrientationProvider alloc] init];
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

// TODO(mchudy): replace setValue with proper DI
- (void)testSetFocusPointWithResult_SetsFocusPointOfInterest {
  // UI is currently in landscape left orientation
  [_camera setValue:_mockDeviceOrientationProvider forKey:@"deviceOrientationProvider"];
  _mockDeviceOrientationProvider.orientation = UIDeviceOrientationLandscapeLeft;
  // Focus point of interest is supported
  _mockDevice.isFocusPointOfInterestSupported = YES;
  // Set mock device as the current capture device
  [_camera setValue:_mockDevice forKey:@"captureDevice"];

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

@end
