// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraProperties.h"

#pragma mark - flash mode

FLTFlashMode FLTGetFLTFlashModeForString(NSString *mode) {
  if ([mode isEqualToString:@"off"]) {
    return FLTFlashModeOff;
  } else if ([mode isEqualToString:@"auto"]) {
    return FLTFlashModeAuto;
  } else if ([mode isEqualToString:@"always"]) {
    return FLTFlashModeAlways;
  } else if ([mode isEqualToString:@"torch"]) {
    return FLTFlashModeTorch;
  } else {
    return FLTFlashModeInvalid;
  }
}

AVCaptureFlashMode FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashMode mode) {
  switch (mode) {
    case FLTFlashModeOff:
      return AVCaptureFlashModeOff;
    case FLTFlashModeAuto:
      return AVCaptureFlashModeAuto;
    case FLTFlashModeAlways:
      return AVCaptureFlashModeOn;
    case FLTFlashModeTorch:
    default:
      return -1;
  }
}

#pragma mark - exposure mode

FCPPlatformExposureMode FCPGetExposureModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return FCPPlatformExposureModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return FCPPlatformExposureModeLocked;
  } else {
    // This should be unreachable; see _serializeExposureMode in avfoundation_camera.dart.
    NSCAssert(false, @"Unsupported exposure mode");
    return FCPPlatformExposureModeAuto;
  }
}

#pragma mark - focus mode

FCPPlatformFocusMode FCPGetFocusModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return FCPPlatformFocusModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return FCPPlatformFocusModeLocked;
  } else {
    // This should be unreachable; see _serializeFocusMode in avfoundation_camera.dart.
    NSCAssert(false, @"Unsupported focus mode");
    return FCPPlatformFocusModeAuto;
  }
}

#pragma mark - device orientation

UIDeviceOrientation FLTGetUIDeviceOrientationForString(NSString *orientation) {
  if ([orientation isEqualToString:@"portraitDown"]) {
    return UIDeviceOrientationPortraitUpsideDown;
  } else if ([orientation isEqualToString:@"landscapeLeft"]) {
    return UIDeviceOrientationLandscapeLeft;
  } else if ([orientation isEqualToString:@"landscapeRight"]) {
    return UIDeviceOrientationLandscapeRight;
  } else if ([orientation isEqualToString:@"portraitUp"]) {
    return UIDeviceOrientationPortrait;
  } else {
    return UIDeviceOrientationUnknown;
  }
}

FCPPlatformDeviceOrientation FCPGetPigeonDeviceOrientationForOrientation(
    UIDeviceOrientation orientation) {
  switch (orientation) {
    case UIDeviceOrientationPortraitUpsideDown:
      return FCPPlatformDeviceOrientationPortraitDown;
    case UIDeviceOrientationLandscapeLeft:
      return FCPPlatformDeviceOrientationLandscapeLeft;
    case UIDeviceOrientationLandscapeRight:
      return FCPPlatformDeviceOrientationLandscapeRight;
    case UIDeviceOrientationPortrait:
    default:
      return FCPPlatformDeviceOrientationPortraitUp;
  };
}

#pragma mark - video format

OSType FLTGetVideoFormatFromString(NSString *videoFormatString) {
  if ([videoFormatString isEqualToString:@"bgra8888"]) {
    return kCVPixelFormatType_32BGRA;
  } else if ([videoFormatString isEqualToString:@"yuv420"]) {
    return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
  } else {
    NSLog(@"The selected imageFormatGroup is not supported by iOS. Defaulting to brga8888");
    return kCVPixelFormatType_32BGRA;
  }
}

#pragma mark - file format

FCPFileFormat FCPGetFileFormatFromString(NSString *fileFormatString) {
  if ([fileFormatString isEqualToString:@"jpg"]) {
    return FCPFileFormatJPEG;
  } else if ([fileFormatString isEqualToString:@"heif"]) {
    return FCPFileFormatHEIF;
  } else {
    return FCPFileFormatInvalid;
  }
}
