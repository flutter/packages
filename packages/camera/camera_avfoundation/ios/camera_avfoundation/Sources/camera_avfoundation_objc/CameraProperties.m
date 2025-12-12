// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/CameraProperties.h"

AVCaptureFlashMode FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashMode mode) {
  switch (mode) {
    case FCPPlatformFlashModeOff:
      return AVCaptureFlashModeOff;
    case FCPPlatformFlashModeAuto:
      return AVCaptureFlashModeAuto;
    case FCPPlatformFlashModeAlways:
      return AVCaptureFlashModeOn;
    case FCPPlatformFlashModeTorch:
      NSCAssert(false, @"This mode cannot be converted, and requires custom handling.");
      return -1;
  }
}

UIDeviceOrientation FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
    FCPPlatformDeviceOrientation orientation) {
  switch (orientation) {
    case FCPPlatformDeviceOrientationPortraitDown:
      return UIDeviceOrientationPortraitUpsideDown;
    case FCPPlatformDeviceOrientationLandscapeLeft:
      return UIDeviceOrientationLandscapeLeft;
    case FCPPlatformDeviceOrientationLandscapeRight:
      return UIDeviceOrientationLandscapeRight;
    case FCPPlatformDeviceOrientationPortraitUp:
      return UIDeviceOrientationPortrait;
  };
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

OSType FCPGetPixelFormatForPigeonFormat(FCPPlatformImageFormatGroup imageFormat) {
  switch (imageFormat) {
    case FCPPlatformImageFormatGroupBgra8888:
      return kCVPixelFormatType_32BGRA;
    case FCPPlatformImageFormatGroupYuv420:
      return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
  }
}

AVCaptureVideoStabilizationMode getAvCaptureVideoStabilizationMode(
    FCPPlatformVideoStabilizationMode videoStabilizationMode) {
  switch (videoStabilizationMode) {
    case FCPPlatformVideoStabilizationModeOff:
      return AVCaptureVideoStabilizationModeOff;
    case FCPPlatformVideoStabilizationModeStandard:
      return AVCaptureVideoStabilizationModeStandard;
    case FCPPlatformVideoStabilizationModeCinematic:
      return AVCaptureVideoStabilizationModeCinematic;
    case FCPPlatformVideoStabilizationModeCinematicExtended:
      if (@available(iOS 13.0, *)) {
        return AVCaptureVideoStabilizationModeCinematicExtended;
      } else {
        return AVCaptureVideoStabilizationModeCinematic;
      }

    default:
      return AVCaptureVideoStabilizationModeOff;
  }
}
