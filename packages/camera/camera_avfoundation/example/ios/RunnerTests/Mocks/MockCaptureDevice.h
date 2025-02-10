// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

@interface MockCaptureDevice : NSObject <FLTCaptureDevice>

@property(nonatomic, assign) NSString *uniqueID;

// Position/Orientation
@property(nonatomic, assign) AVCaptureDevicePosition position;

// Format/Configuration
@property(nonatomic, strong) NSArray<NSObject<FLTCaptureDeviceFormat> *> *formats;
/// Overrides the default implementation of getting the active format.
@property(nonatomic, copy) NSObject<FLTCaptureDeviceFormat> * (^activeFormatStub)(void);
/// Overrides the default implementation of setting active format.
/// @param format The format being set
@property(nonatomic, copy) void (^setActiveFormatStub)(NSObject<FLTCaptureDeviceFormat> *format);

// Flash/Torch
@property(nonatomic, assign) BOOL hasFlash;
@property(nonatomic, assign) BOOL hasTorch;
@property(nonatomic, assign) BOOL isTorchAvailable;
@property(nonatomic, assign) AVCaptureTorchMode torchMode;
/// Overrides the default implementation of setting torch mode.
/// @param mode The torch mode being set
@property(nonatomic, copy) void (^setTorchModeStub)(AVCaptureTorchMode mode);
@property(nonatomic, assign) BOOL flashModeSupported;

// Focus
@property(nonatomic, assign) BOOL focusPointOfInterestSupported;
/// Overrides the default implementation of checking if focus mode is supported.
/// @param mode The focus mode to check
/// @return Whether the focus mode is supported
@property(nonatomic, copy) BOOL (^isFocusModeSupportedStub)(AVCaptureFocusMode mode);
@property(nonatomic, assign) AVCaptureFocusMode focusMode;
/// Overrides the default implementation of setting focus mode.
/// @param mode The focus mode being set
@property(nonatomic, copy) void (^setFocusModeStub)(AVCaptureFocusMode mode);
@property(nonatomic, assign) CGPoint focusPointOfInterest;
/// Overrides the default implementation of setting focus point of interest.
/// @param point The focus point being set
@property(nonatomic, copy) void (^setFocusPointOfInterestStub)(CGPoint point);

// Exposure
@property(nonatomic, assign) BOOL exposurePointOfInterestSupported;
@property(nonatomic, assign) AVCaptureExposureMode exposureMode;
@property(nonatomic, assign) BOOL exposureModeSupported;
/// Overrides the default implementation of setting exposure mode.
/// @param mode The exposure mode being set
@property(nonatomic, copy) void (^setExposureModeStub)(AVCaptureExposureMode mode);
@property(nonatomic, assign) CGPoint exposurePointOfInterest;
/// Override the default implementation of setting exposure point of interest.
/// @param point The exposure point being set
@property(nonatomic, copy) void (^setExposurePointOfInterestStub)(CGPoint point);
@property(nonatomic, assign) float minExposureTargetBias;
@property(nonatomic, assign) float maxExposureTargetBias;
/// Overrides the default implementation of setting exposure target bias.
/// @param bias The exposure bias being set
/// @param handler The completion handler to be called
@property(nonatomic, copy) void (^setExposureTargetBiasStub)
    (float bias, void (^_Nullable handler)(CMTime));

// Zoom
@property(nonatomic, assign) float maxAvailableVideoZoomFactor;
@property(nonatomic, assign) float minAvailableVideoZoomFactor;
@property(nonatomic, assign) float videoZoomFactor;
/// Overrides the default implementation of setting video zoom factor.
/// @param factor The zoom factor being set
@property(nonatomic, copy) void (^setVideoZoomFactorStub)(float factor);

// Camera Properties
@property(nonatomic, assign) float lensAperture;
@property(nonatomic, assign) CMTime exposureDuration;
@property(nonatomic, assign) float ISO;

// Configuration Lock
/// Overrides the default implementation of locking device for configuration.
/// @param error Error pointer to be set if lock fails
@property(nonatomic, copy) BOOL (^lockForConfigurationStub)(NSError **error);
/// Overrides the default implementation of unlocking device configuration.
@property(nonatomic, copy) void (^unlockForConfigurationStub)(void);

// Frame Duration
@property(nonatomic, assign) CMTime activeVideoMinFrameDuration;
@property(nonatomic, assign) CMTime activeVideoMaxFrameDuration;
/// Overrides the default implementation of setting minimum frame duration.
/// @param duration The minimum frame duration being set
@property(nonatomic, copy) void (^setActiveVideoMinFrameDurationStub)(CMTime duration);
/// Overrides the default implementation of setting maximum frame duration.
/// @param duration The maximum frame duration being set
@property(nonatomic, copy) void (^setActiveVideoMaxFrameDurationStub)(CMTime duration);

@end

/// A mocked implementation of FLTCaptureDeviceInputFactory which allows injecting a custom
/// implementation.
@interface MockCaptureInput : NSObject <FLTCaptureInput>

/// This property is re-declared to be read/write to allow setting a mocked value for testing.
@property(nonatomic, strong) NSArray<AVCaptureInputPort *> *ports;

@end

/// A mocked implementation of FLTCaptureDeviceInputFactory which allows injecting a custom
/// implementation.
@interface MockCaptureDeviceInputFactory : NSObject <FLTCaptureDeviceInputFactory>

/// Initializes a new instance with the given mock device input. Whenever `deviceInputWithDevice` is
/// called on this instance, it will return the mock device input.
- (nonnull instancetype)initWithMockDeviceInput:(NSObject<FLTCaptureInput> *)mockDeviceInput;

/// The mock device input to be returned by `deviceInputWithDevice`.
@property(nonatomic, strong) NSObject<FLTCaptureInput> *mockDeviceInput;

@end

NS_ASSUME_NONNULL_END
