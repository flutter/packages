// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

#import "FLTCaptureDeviceFormat.h"

NS_ASSUME_NONNULL_BEGIN

/// A protocol which is a direct passthrough to AVCaptureDevice.
/// It exists to allow replacing AVCaptureDevice in tests.
@protocol FLTCaptureDevice <NSObject>

/// Underlying `AVCaptureDevice` instance. This is should not be used directly
/// in the plugin implementation code, but it exists so that other protocol default
/// implementation can pass the raw device to AVFoundation methods.
@property(nonatomic, readonly) AVCaptureDevice *device;

// Device identifier
@property(nonatomic, readonly) NSString *uniqueID;

// Position/Orientation
@property(nonatomic, readonly) AVCaptureDevicePosition position;

// Format/Configuration
@property(nonatomic, retain) NSObject<FLTCaptureDeviceFormat> *activeFormat;
@property(nonatomic, readonly) NSArray<NSObject<FLTCaptureDeviceFormat> *> *formats;

// Flash/Torch
@property(nonatomic, readonly) BOOL hasFlash;
@property(nonatomic, readonly) BOOL hasTorch;
@property(nonatomic, readonly, getter=isTorchAvailable) BOOL torchAvailable;
@property(nonatomic) AVCaptureTorchMode torchMode;
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)mode;

// Focus
@property(nonatomic, readonly, getter=isFocusPointOfInterestSupported)
    BOOL focusPointOfInterestSupported;
- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)mode;
- (void)setFocusMode:(AVCaptureFocusMode)focusMode;
- (void)setFocusPointOfInterest:(CGPoint)point;

// Exposure
@property(nonatomic, readonly, getter=isExposurePointOfInterestSupported)
    BOOL exposurePointOfInterestSupported;
- (void)setExposureMode:(AVCaptureExposureMode)exposureMode;
- (void)setExposurePointOfInterest:(CGPoint)point;
@property(nonatomic, readonly) float minExposureTargetBias;
@property(nonatomic, readonly) float maxExposureTargetBias;
- (void)setExposureTargetBias:(float)bias completionHandler:(void (^_Nullable)(CMTime))handler;
- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)mode;

// Zoom
@property(nonatomic, readonly) CGFloat maxAvailableVideoZoomFactor;
@property(nonatomic, readonly) CGFloat minAvailableVideoZoomFactor;
@property(nonatomic) CGFloat videoZoomFactor;

// Camera Properties
- (float)lensAperture;
- (CMTime)exposureDuration;
- (float)ISO;

// Configuration Lock
- (BOOL)lockForConfiguration:(NSError *_Nullable *_Nullable)outError;
- (void)unlockForConfiguration;

// Frame Duration
@property(nonatomic) CMTime activeVideoMinFrameDuration;
@property(nonatomic) CMTime activeVideoMaxFrameDuration;

@end

/// A protocol which is a direct passthrough to AVCaptureInput.
/// It exists to allow replacing AVCaptureInput in tests.
@protocol FLTCaptureInput <NSObject>

/// Underlying input instance. It is exposed as raw AVCaptureInput has to be passed to some
/// AVFoundation methods. The plugin implementation code shouldn't use it though.
@property(nonatomic, readonly) AVCaptureInput *input;

@property(nonatomic, readonly) NSArray<AVCaptureInputPort *> *ports;
@end

/// A protocol which wraps the creation of AVCaptureDeviceInput.
/// It exists to allow mocking instances of AVCaptureDeviceInput in tests.
@protocol FLTCaptureDeviceInputFactory <NSObject>
- (nullable NSObject<FLTCaptureInput> *)deviceInputWithDevice:(NSObject<FLTCaptureDevice> *)device
                                                        error:(NSError **)error;
@end

/// A default implementation of `FLTCaptureDevice` which is a direct passthrough to the underlying
/// `AVCaptureDevice`.
@interface FLTDefaultCaptureDevice : NSObject <FLTCaptureDevice>
- (instancetype)initWithDevice:(AVCaptureDevice *)device;
@end

/// A default implementation of `FLTCaptureInput` which is a direct passthrough to the underlying
/// `AVCaptureInput`.
@interface FLTDefaultCaptureInput : NSObject <FLTCaptureInput>
- (instancetype)initWithInput:(AVCaptureInput *)input;
@end

/// A default implementation of FLTCaptureDeviceInputFactory protocol which
/// wraps a call to AVCaptureInput static method `deviceInputWithDevice`.
@interface FLTDefaultCaptureDeviceInputFactory : NSObject <FLTCaptureDeviceInputFactory>
@end

NS_ASSUME_NONNULL_END
