// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;
@import XCTest;

@interface CameraPropertiesTests : XCTestCase

@end

@implementation CameraPropertiesTests

#pragma mark - flash mode tests

- (void)testFCPGetAVCaptureFlashModeForPigeonFlashMode {
  XCTAssertEqual(AVCaptureFlashModeOff,
                 FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashModeOff));
  XCTAssertEqual(AVCaptureFlashModeAuto,
                 FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashModeAuto));
  XCTAssertEqual(AVCaptureFlashModeOn,
                 FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashModeAlways));
  XCTAssertThrows(FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashModeTorch));
}

#pragma mark - video format tests

- (void)testFCPGetPixelFormatForPigeonFormat {
  XCTAssertEqual(kCVPixelFormatType_32BGRA,
                 FCPGetPixelFormatForPigeonFormat(FCPPlatformImageFormatGroupBgra8888));
  XCTAssertEqual(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                 FCPGetPixelFormatForPigeonFormat(FCPPlatformImageFormatGroupYuv420));
}

#pragma mark - device orientation tests

- (void)testFCPGetUIDeviceOrientationForPigeonDeviceOrientation {
  XCTAssertEqual(UIDeviceOrientationPortraitUpsideDown,
                 FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
                     FCPPlatformDeviceOrientationPortraitDown));
  XCTAssertEqual(UIDeviceOrientationLandscapeLeft,
                 FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
                     FCPPlatformDeviceOrientationLandscapeLeft));
  XCTAssertEqual(UIDeviceOrientationLandscapeRight,
                 FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
                     FCPPlatformDeviceOrientationLandscapeRight));
  XCTAssertEqual(UIDeviceOrientationPortrait, FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
                                                  FCPPlatformDeviceOrientationPortraitUp));
}

- (void)testFLTGetStringForUIDeviceOrientation {
  XCTAssertEqual(
      FCPPlatformDeviceOrientationPortraitDown,
      FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientationPortraitUpsideDown));
  XCTAssertEqual(FCPPlatformDeviceOrientationLandscapeLeft,
                 FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientationLandscapeLeft));
  XCTAssertEqual(FCPPlatformDeviceOrientationLandscapeRight,
                 FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientationLandscapeRight));
  XCTAssertEqual(FCPPlatformDeviceOrientationPortraitUp,
                 FCPGetPigeonDeviceOrientationForOrientation(UIDeviceOrientationPortrait));
  XCTAssertEqual(FCPPlatformDeviceOrientationPortraitUp,
                 FCPGetPigeonDeviceOrientationForOrientation(-1));
}

@end
