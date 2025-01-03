// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

#import "MockCaptureDeviceController.h"

@implementation MockCaptureDeviceController

- (void)setActiveFormat:(AVCaptureDeviceFormat *)format {
  _activeFormat = format;
  if (self.setActiveFormatStub) {
    self.setActiveFormatStub(format);
  }
}

- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode {
  return self.flashModeSupported;
}

- (void)setTorchMode:(AVCaptureTorchMode)mode {
  _torchMode = mode;
  if (self.setTorchModeStub) {
    self.setTorchModeStub(mode);
  }
}

- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)mode {
  if (self.isFocusModeSupportedStub) {
    return self.isFocusModeSupportedStub(mode);
  }
  return NO;
}

- (void)setFocusMode:(AVCaptureFocusMode)mode {
  _focusMode = mode;
  if (self.setFocusModeStub) {
    self.setFocusModeStub(mode);
  }
}

- (void)setFocusPointOfInterest:(CGPoint)point {
  _focusPointOfInterest = point;
  if (self.setFocusPointOfInterestStub) {
    self.setFocusPointOfInterestStub(point);
  }
}

- (void)setExposureMode:(AVCaptureExposureMode)mode {
  _exposureMode = mode;
  if (self.setExposureModeStub) {
    self.setExposureModeStub(mode);
  }
}

- (void)setExposurePointOfInterest:(CGPoint)point {
  _exposurePointOfInterest = point;
  if (self.setExposurePointOfInterestStub) {
    self.setExposurePointOfInterestStub(point);
  }
}

- (void)setExposureTargetBias:(float)bias completionHandler:(void (^)(CMTime))handler {
  if (self.setExposureTargetBiasStub) {
    self.setExposureTargetBiasStub(bias, handler);
  } else if (handler) {
    handler(kCMTimeZero);
  }
}

- (void)setVideoZoomFactor:(float)factor {
  _videoZoomFactor = factor;
  if (self.setVideoZoomFactorStub) {
    self.setVideoZoomFactorStub(factor);
  }
}

- (BOOL)lockForConfiguration:(NSError **)error {
  if (self.lockForConfigurationStub) {
    self.lockForConfigurationStub(error);
    return !self.shouldFailConfiguration;
  }
  if (self.shouldFailConfiguration) {
    if (error) {
      *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
    }
    return NO;
  }
  return YES;
}

- (void)unlockForConfiguration {
  if (self.unlockForConfigurationStub) {
    self.unlockForConfigurationStub();
  }
}

- (void)setActiveVideoMinFrameDuration:(CMTime)duration {
  _activeVideoMinFrameDuration = duration;
  if (self.setActiveVideoMinFrameDurationStub) {
    self.setActiveVideoMinFrameDurationStub(duration);
  }
}

- (void)setActiveVideoMaxFrameDuration:(CMTime)duration {
  _activeVideoMaxFrameDuration = duration;
  if (self.setActiveVideoMaxFrameDurationStub) {
    self.setActiveVideoMaxFrameDurationStub(duration);
  }
}

- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)mode {
  return self.exposureModeSupported;
}

- (AVCaptureInput *)createInput:(NSError *_Nullable *_Nullable)error {
  if (self.createInputStub) {
    self.createInputStub(error);
  }
  return self.inputToReturn;
}

@end

@implementation MockCaptureInput
@synthesize ports;
@end
