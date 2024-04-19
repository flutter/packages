// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
@import camera_avfoundation.Test;
@import AVFoundation;
@import XCTest;

@interface CameraPropertiesTests : XCTestCase

@end

@implementation CameraPropertiesTests

#pragma mark - flash mode tests

- (void)testFLTGetFLTFlashModeForString {
  XCTAssertEqual(FLTFlashModeOff, FLTGetFLTFlashModeForString(@"off"));
  XCTAssertEqual(FLTFlashModeAuto, FLTGetFLTFlashModeForString(@"auto"));
  XCTAssertEqual(FLTFlashModeAlways, FLTGetFLTFlashModeForString(@"always"));
  XCTAssertEqual(FLTFlashModeTorch, FLTGetFLTFlashModeForString(@"torch"));
  XCTAssertEqual(FLTFlashModeInvalid, FLTGetFLTFlashModeForString(@"unknown"));
}

- (void)testFLTGetAVCaptureFlashModeForFLTFlashMode {
  XCTAssertEqual(AVCaptureFlashModeOff, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeOff));
  XCTAssertEqual(AVCaptureFlashModeAuto, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeAuto));
  XCTAssertEqual(AVCaptureFlashModeOn, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeAlways));
  XCTAssertEqual(-1, FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashModeTorch));
}

#pragma mark - exposure mode tests

- (void)testFCPGetExposureModeForString {
  XCTAssertEqual(FCPPlatformExposureModeAuto, FCPGetExposureModeForString(@"auto"));
  XCTAssertEqual(FCPPlatformExposureModeLocked, FCPGetExposureModeForString(@"locked"));
}

#pragma mark - focus mode tests

- (void)testFLTGetFLTFocusModeForString {
  XCTAssertEqual(FCPPlatformFocusModeAuto, FCPGetFocusModeForString(@"auto"));
  XCTAssertEqual(FCPPlatformFocusModeLocked, FCPGetFocusModeForString(@"locked"));
}

#pragma mark - video format tests

- (void)testFLTGetVideoFormatFromString {
  XCTAssertEqual(kCVPixelFormatType_32BGRA, FLTGetVideoFormatFromString(@"bgra8888"));
  XCTAssertEqual(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                 FLTGetVideoFormatFromString(@"yuv420"));
  XCTAssertEqual(kCVPixelFormatType_32BGRA, FLTGetVideoFormatFromString(@"unknown"));
}

#pragma mark - device orientation tests

- (void)testFLTGetUIDeviceOrientationForString {
  XCTAssertEqual(UIDeviceOrientationPortraitUpsideDown,
                 FLTGetUIDeviceOrientationForString(@"portraitDown"));
  XCTAssertEqual(UIDeviceOrientationLandscapeLeft,
                 FLTGetUIDeviceOrientationForString(@"landscapeLeft"));
  XCTAssertEqual(UIDeviceOrientationLandscapeRight,
                 FLTGetUIDeviceOrientationForString(@"landscapeRight"));
  XCTAssertEqual(UIDeviceOrientationPortrait, FLTGetUIDeviceOrientationForString(@"portraitUp"));
  XCTAssertEqual(UIDeviceOrientationUnknown, FLTGetUIDeviceOrientationForString(@"unknown"));
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

#pragma mark - file format tests

- (void)testFLTGetFileFormatForString {
  XCTAssertEqual(FCPFileFormatJPEG, FCPGetFileFormatFromString(@"jpg"));
  XCTAssertEqual(FCPFileFormatHEIF, FCPGetFileFormatFromString(@"heif"));
  XCTAssertEqual(FCPFileFormatInvalid, FCPGetFileFormatFromString(@"unknown"));
}

@end
