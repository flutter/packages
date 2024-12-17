// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../include/camera_avfoundation/Protocols/FLTCaptureDeviceControlling.h"

@interface FLTDefaultCaptureDeviceController ()
@property(nonatomic, strong) AVCaptureDevice *device;
@end

@implementation FLTDefaultCaptureDeviceController

- (instancetype)initWithDevice:(AVCaptureDevice *)device {
  self = [super init];
  if (self) {
    _device = device;
  }
  return self;
}

- (nonnull NSString *)uniqueID {
  return self.device.uniqueID;
}

// Position/Orientation
- (AVCaptureDevicePosition)position {
  return self.device.position;
}

// Format/Configuration
- (id<FLTCaptureDeviceFormat>)activeFormat {
  return [[FLTDefaultCaptureDeviceFormat alloc] initWithFormat:self.device.activeFormat];
}

- (NSArray<id<FLTCaptureDeviceFormat>> *)formats {
  NSMutableArray<id<FLTCaptureDeviceFormat>> *wrappedFormats = [NSMutableArray array];
  for (AVCaptureDeviceFormat *format in self.device.formats) {
    [wrappedFormats addObject:[[FLTDefaultCaptureDeviceFormat alloc] initWithFormat:format]];
  }
  return wrappedFormats;
}

- (void)setActiveFormat:(id<FLTCaptureDeviceFormat>)format {
  self.device.activeFormat = format.format;
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

- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode {
  return [self.device isFlashModeSupported:mode];
}

// Focus
- (BOOL)isFocusPointOfInterestSupported {
  return self.device.isFocusPointOfInterestSupported;
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
- (BOOL)isExposurePointOfInterestSupported {
  return self.device.isExposurePointOfInterestSupported;
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

- (AVCaptureInput *)createInput:(NSError *_Nullable *_Nullable)error {
  return [AVCaptureDeviceInput deviceInputWithDevice:_device error:error];
}

@end

@implementation FLTDefaultCaptureDeviceFormat {
  id<FLTCaptureDeviceFormat> _format;
}

- (instancetype)initWithFormat:(id<FLTCaptureDeviceFormat>)format {
  self = [super init];
  if (self) {
    format = format;
  }
  return self;
}

- (CMFormatDescriptionRef)formatDescription {
  return _format.formatDescription;
}

- (NSArray<AVFrameRateRange *> *)videoSupportedFrameRateRanges {
  return _format.videoSupportedFrameRateRanges;
}

@synthesize format;

@end
