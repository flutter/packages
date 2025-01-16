
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockCaptureDeviceController.h"

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

@implementation MockCaptureDeviceController

- (void)setActiveFormat:(AVCaptureDeviceFormat *)format {
  _activeFormat = format;
  if (self.onSetActiveFormat) {
    self.onSetActiveFormat(format);
  }
}

- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode {
  return self.flashModeSupported;
}

- (void)setTorchMode:(AVCaptureTorchMode)mode {
  _torchMode = mode;
  if (self.onSetTorchMode) {
    self.onSetTorchMode(mode);
  }
}

- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)mode {
  if (self.onIsFocusModeSupported) {
    return self.onIsFocusModeSupported(mode);
  }
  return NO;
}

- (void)setFocusMode:(AVCaptureFocusMode)mode {
  _focusMode = mode;
  if (self.onSetFocusMode) {
    self.onSetFocusMode(mode);
  }
}

- (void)setFocusPointOfInterest:(CGPoint)point {
  _focusPointOfInterest = point;
  if (self.onSetFocusPointOfInterest) {
    self.onSetFocusPointOfInterest(point);
  }
}

- (void)setExposureMode:(AVCaptureExposureMode)mode {
  _exposureMode = mode;
  if (self.onSetExposureMode) {
    self.onSetExposureMode(mode);
  }
}

- (void)setExposurePointOfInterest:(CGPoint)point {
  _exposurePointOfInterest = point;
  if (self.onSetExposurePointOfInterest) {
    self.onSetExposurePointOfInterest(point);
  }
}

- (void)setExposureTargetBias:(float)bias completionHandler:(void (^)(CMTime))handler {
  if (self.onSetExposureTargetBias) {
    self.onSetExposureTargetBias(bias, handler);
  } else if (handler) {
    handler(kCMTimeZero);
  }
}

- (void)setVideoZoomFactor:(float)factor {
  _videoZoomFactor = factor;
  if (self.onSetVideoZoomFactor) {
    self.onSetVideoZoomFactor(factor);
  }
}

- (BOOL)lockForConfiguration:(NSError **)error {
  if (self.onLockForConfiguration) {
    self.onLockForConfiguration(error);
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
  if (self.onUnlockForConfiguration) {
    self.onUnlockForConfiguration();
  }
}

- (void)setActiveVideoMinFrameDuration:(CMTime)duration {
  _activeVideoMinFrameDuration = duration;
  if (self.onSetActiveVideoMinFrameDuration) {
    self.onSetActiveVideoMinFrameDuration(duration);
  }
}

- (void)setActiveVideoMaxFrameDuration:(CMTime)duration {
  _activeVideoMaxFrameDuration = duration;
  if (self.onSetActiveVideoMaxFrameDuration) {
    self.onSetActiveVideoMaxFrameDuration(duration);
  }
}

- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)mode {
  return self.exposureModeSupported;
}

- (AVCaptureInput *)createInput:(NSError *_Nullable *_Nullable)error {
  if (self.onCreateInput) {
    self.onCreateInput(error);
  }
  return self.inputToReturn;
}

@end
