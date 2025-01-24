// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to AVCaptureDevice.
/// It exists to allow replacing AVCaptureDevice in tests.
@protocol FLTCaptureDevice <NSObject>

// Device
- (NSString *)uniqueID;

// Position/Orientation
- (AVCaptureDevicePosition)position;

// Format/Configuration
- (AVCaptureDeviceFormat *)activeFormat;
- (NSArray<AVCaptureDeviceFormat *> *)formats;
- (void)setActiveFormat:(AVCaptureDeviceFormat *)format;

// Flash/Torch
- (BOOL)hasFlash;
- (BOOL)hasTorch;
- (BOOL)isTorchAvailable;
- (AVCaptureTorchMode)torchMode;
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode;

// Focus
- (BOOL)focusPointOfInterestSupported;
- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)mode;
- (void)setFocusMode:(AVCaptureFocusMode)focusMode;
- (void)setFocusPointOfInterest:(CGPoint)point;

// Exposure
- (BOOL)exposurePointOfInterestSupported;
- (void)setExposureMode:(AVCaptureExposureMode)exposureMode;
- (void)setExposurePointOfInterest:(CGPoint)point;
- (float)minExposureTargetBias;
- (float)maxExposureTargetBias;
- (void)setExposureTargetBias:(float)bias completionHandler:(void (^_Nullable)(CMTime))handler;
- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)mode;

// Zoom
- (float)maxAvailableVideoZoomFactor;
- (float)minAvailableVideoZoomFactor;
- (float)videoZoomFactor;
- (void)setVideoZoomFactor:(float)factor;

// Camera Properties
- (float)lensAperture;
- (CMTime)exposureDuration;
- (float)ISO;

// Configuration Lock
- (BOOL)lockForConfiguration:(NSError **)error;
- (void)unlockForConfiguration;

// Frame Duration
- (CMTime)activeVideoMinFrameDuration;
- (void)setActiveVideoMinFrameDuration:(CMTime)duration;
- (CMTime)activeVideoMaxFrameDuration;
- (void)setActiveVideoMaxFrameDuration:(CMTime)duration;

@end

/// A protocol which is a direct passthrough to AVCaptureInput.
/// It exists to allow replacing AVCaptureInput in tests.
@protocol FLTCaptureInput <NSObject>
@property(nonatomic, readonly) NSArray<AVCaptureInputPort *> *ports;
@end

/// A protocol which wraps the creation of AVCaptureDeviceInput.
/// It exists to allow mocking instances of AVCaptureDeviceInput in tests.
@protocol FLTCaptureDeviceInputFactory <NSObject>
- (nullable id<FLTCaptureInput>)deviceInputWithDevice:(id<FLTCaptureDevice>)device
                                                error:(NSError **)error;
@end

@interface AVCaptureDevice (FLTCaptureDevice) <FLTCaptureDevice>
@end

@interface AVCaptureInput (FLTCaptureInput) <FLTCaptureInput>
@end

/// A default implementation of FLTCaptureDeviceInputFactory protocol which
/// wraps a call to AVCaptureInput static method `deviceInputWithDevice`.
@interface FLTDefaultCaptureDeviceInputFactory : NSObject <FLTCaptureDeviceInputFactory>
@end

NS_ASSUME_NONNULL_END
