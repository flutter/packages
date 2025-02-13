// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

#import "FLTCaptureDevice.h"

@interface FLTDefaultCaptureDevice ()
@property(nonatomic, strong) AVCaptureDevice *device;
@end

@implementation FLTDefaultCaptureDevice

- (instancetype)initWithDevice:(AVCaptureDevice *)device {
  self = [super init];
  if (self) {
    _device = device;
  }
  return self;
}

// Device identifier
- (NSString *)uniqueID {
  return self.device.uniqueID;
}

// Position/Orientation
- (AVCaptureDevicePosition)position {
  return self.device.position;
}

// Format/Configuration
- (NSObject<FLTCaptureDeviceFormat> *)activeFormat {
  return [[FLTDefaultCaptureDeviceFormat alloc] initWithFormat:self.device.activeFormat];
}

- (NSArray<NSObject<FLTCaptureDeviceFormat> *> *)formats {
  NSMutableArray<id<FLTCaptureDeviceFormat>> *wrappedFormats =
      [NSMutableArray arrayWithCapacity:self.device.formats.count];
  for (AVCaptureDeviceFormat *format in self.device.formats) {
    [wrappedFormats addObject:[[FLTDefaultCaptureDeviceFormat alloc] initWithFormat:format]];
  }
  return wrappedFormats;
}

- (void)setActiveFormat:(AVCaptureDeviceFormat *)format {
  self.device.activeFormat = format;
}

// Flash/Torch
- (BOOL)hasFlash {
  return self.device.hasFlash;
}

- (BOOL)hasTorch {
  return self.device.hasTorch;
}

- (BOOL)isTorchAvailable {
  return self.device.isTorchAvailable;
}

- (AVCaptureTorchMode)torchMode {
  return self.device.torchMode;
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
  self.device.torchMode = torchMode;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode {
  return [self.device isFlashModeSupported:mode];
}
#pragma clang diagnostic pop

// Focus
- (BOOL)focusPointOfInterestSupported {
  return self.device.focusPointOfInterestSupported;
}

- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)mode {
  return [self.device isFocusModeSupported:mode];
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode {
  self.device.focusMode = focusMode;
}

- (void)setFocusPointOfInterest:(CGPoint)point {
  self.device.focusPointOfInterest = point;
}

// Exposure
- (BOOL)exposurePointOfInterestSupported {
  return self.device.exposurePointOfInterestSupported;
}

- (void)setExposureMode:(AVCaptureExposureMode)exposureMode {
  self.device.exposureMode = exposureMode;
}

- (void)setExposurePointOfInterest:(CGPoint)point {
  self.device.exposurePointOfInterest = point;
}

- (float)minExposureTargetBias {
  return self.device.minExposureTargetBias;
}

- (float)maxExposureTargetBias {
  return self.device.maxExposureTargetBias;
}

- (void)setExposureTargetBias:(float)bias completionHandler:(void (^)(CMTime))handler {
  [self.device setExposureTargetBias:bias completionHandler:handler];
}

- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)mode {
  return [self.device isExposureModeSupported:mode];
}

// Zoom
- (float)maxAvailableVideoZoomFactor {
  return self.device.maxAvailableVideoZoomFactor;
}

- (float)minAvailableVideoZoomFactor {
  return self.device.minAvailableVideoZoomFactor;
}

- (float)videoZoomFactor {
  return self.device.videoZoomFactor;
}

- (void)setVideoZoomFactor:(float)factor {
  self.device.videoZoomFactor = factor;
}

// Camera Properties
- (float)lensAperture {
  return self.device.lensAperture;
}

- (CMTime)exposureDuration {
  return self.device.exposureDuration;
}

- (float)ISO {
  return self.device.ISO;
}

// Configuration Lock
- (BOOL)lockForConfiguration:(NSError **)error {
  return [self.device lockForConfiguration:error];
}

- (void)unlockForConfiguration {
  [self.device unlockForConfiguration];
}

- (CMTime)activeVideoMinFrameDuration {
  return self.device.activeVideoMinFrameDuration;
}

- (void)setActiveVideoMinFrameDuration:(CMTime)duration {
  self.device.activeVideoMinFrameDuration = duration;
}

- (CMTime)activeVideoMaxFrameDuration {
  return self.device.activeVideoMaxFrameDuration;
}

- (void)setActiveVideoMaxFrameDuration:(CMTime)duration {
  self.device.activeVideoMaxFrameDuration = duration;
}

@end

@interface FLTDefaultCaptureInput ()
@property(nonatomic, strong) AVCaptureInput *input;
@end

@implementation FLTDefaultCaptureInput

- (instancetype)initWithInput:(AVCaptureInput *)input {
  self = [super init];
  if (self) {
    _input = input;
  }
  return self;
}

- (AVCaptureInput *)input {
  return _input;
}

- (NSArray<AVCaptureInputPort *> *)ports {
  return self.input.ports;
}

@end

@implementation FLTDefaultCaptureDeviceInputFactory

- (NSObject<FLTCaptureInput> *)deviceInputWithDevice:(NSObject<FLTCaptureDevice> *)device
                                               error:(NSError **)error {
  return [[FLTDefaultCaptureInput alloc]
      initWithInput:[AVCaptureDeviceInput deviceInputWithDevice:device.device error:error]];
}

@end
