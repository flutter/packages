// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockCaptureDevice.h"

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

@implementation MockCaptureDevice

- (NSObject<FLTCaptureDeviceFormat> *)activeFormat {
  if (self.activeFormatStub) {
    return self.activeFormatStub();
  }
  return nil;
}

- (void)setActiveFormat:(NSObject<FLTCaptureDeviceFormat> *)format {
  if (self.setActiveFormatStub) {
    self.setActiveFormatStub(format);
  }
}

- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode {
  return self.flashModeSupported;
}

- (void)setTorchMode:(AVCaptureTorchMode)mode {
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
  if (self.setFocusModeStub) {
    self.setFocusModeStub(mode);
  }
}

- (void)setFocusPointOfInterest:(CGPoint)point {
  if (self.setFocusPointOfInterestStub) {
    self.setFocusPointOfInterestStub(point);
  }
}

- (void)setExposureMode:(AVCaptureExposureMode)mode {
  if (self.setExposureModeStub) {
    self.setExposureModeStub(mode);
  }
}

- (void)setExposurePointOfInterest:(CGPoint)point {
  if (self.setExposurePointOfInterestStub) {
    self.setExposurePointOfInterestStub(point);
  }
}

- (void)setExposureTargetBias:(float)bias completionHandler:(void (^)(CMTime))handler {
  if (self.setExposureTargetBiasStub) {
    self.setExposureTargetBiasStub(bias, handler);
  }
}

- (void)setVideoZoomFactor:(float)factor {
  if (self.setVideoZoomFactorStub) {
    self.setVideoZoomFactorStub(factor);
  }
}

- (BOOL)lockForConfiguration:(NSError **)error {
  if (self.lockForConfigurationStub) {
    return self.lockForConfigurationStub(error);
  }
  return YES;
}

- (void)unlockForConfiguration {
  if (self.unlockForConfigurationStub) {
    self.unlockForConfigurationStub();
  }
}

- (void)setActiveVideoMinFrameDuration:(CMTime)duration {
  if (self.setActiveVideoMinFrameDurationStub) {
    self.setActiveVideoMinFrameDurationStub(duration);
  }
}

- (void)setActiveVideoMaxFrameDuration:(CMTime)duration {
  if (self.setActiveVideoMaxFrameDurationStub) {
    self.setActiveVideoMaxFrameDurationStub(duration);
  }
}

- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)mode {
  return self.exposureModeSupported;
}

@synthesize device;

@end

@implementation MockCaptureInput
@synthesize ports;
@synthesize input;
@end

@implementation MockCaptureDeviceInputFactory

- (nonnull instancetype)init {
  self = [super init];
  if (self) {
    _mockDeviceInput = [[MockCaptureInput alloc] init];
  }
  return self;
}

- (nonnull instancetype)initWithMockDeviceInput:
    (nonnull NSObject<FLTCaptureInput> *)mockDeviceInput {
  self = [super init];
  if (self) {
    _mockDeviceInput = mockDeviceInput;
  }
  return self;
}

- (NSObject<FLTCaptureInput> *)deviceInputWithDevice:(NSObject<FLTCaptureDevice> *)device
                                               error:(NSError **)error {
  return _mockDeviceInput;
}

@end
