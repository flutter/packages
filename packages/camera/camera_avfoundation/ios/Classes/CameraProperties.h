// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - flash mode

/// Represents camera's flash mode. Mirrors `FlashMode` enum in flash_mode.dart.
typedef NS_ENUM(NSInteger, FLTFlashMode) {
  FLTFlashModeOff,
  FLTFlashModeAuto,
  FLTFlashModeAlways,
  FLTFlashModeTorch,
  // This should never occur; it indicates an unknown value was received over
  // the platform channel.
  FLTFlashModeInvalid,
};

/// Gets FLTFlashMode from its string representation.
/// @param mode a string representation of the FLTFlashMode.
extern FLTFlashMode FLTGetFLTFlashModeForString(NSString *mode);

/// Gets AVCaptureFlashMode from FLTFlashMode.
/// @param mode flash mode.
extern AVCaptureFlashMode FLTGetAVCaptureFlashModeForFLTFlashMode(FLTFlashMode mode);

#pragma mark - exposure mode

/// Gets FCPPlatformExposureMode from its string representation.
/// @param mode a string representation of the exposure mode.
extern FCPPlatformExposureMode FCPGetExposureModeForString(NSString *mode);

#pragma mark - focus mode

/// Gets FCPPlatformFocusMode from its string representation.
/// @param mode a string representation of focus mode.
extern FCPPlatformFocusMode FCPGetFocusModeForString(NSString *mode);

#pragma mark - device orientation

/// Gets UIDeviceOrientation from its string representation.
extern UIDeviceOrientation FLTGetUIDeviceOrientationForString(NSString *orientation);

/// Gets a Pigeon representation of UIDeviceOrientation.
extern FCPPlatformDeviceOrientation FCPGetPigeonDeviceOrientationForOrientation(
    UIDeviceOrientation orientation);

#pragma mark - resolution preset

/// Represents camera's resolution present. Mirrors ResolutionPreset in camera.dart.
typedef NS_ENUM(NSInteger, FLTResolutionPreset) {
  FLTResolutionPresetVeryLow,
  FLTResolutionPresetLow,
  FLTResolutionPresetMedium,
  FLTResolutionPresetHigh,
  FLTResolutionPresetVeryHigh,
  FLTResolutionPresetUltraHigh,
  FLTResolutionPresetMax,
  // This should never occur; it indicates an unknown value was received over
  // the platform channel.
  FLTResolutionPresetInvalid,
};

/// Gets FLTResolutionPreset from its string representation.
/// @param preset a string representation of FLTResolutionPreset.
extern FLTResolutionPreset FLTGetFLTResolutionPresetForString(NSString *preset);

#pragma mark - video format

/// Gets VideoFormat from its string representation.
extern OSType FLTGetVideoFormatFromString(NSString *videoFormatString);

/// Represents image format. Mirrors ImageFileFormat in camera.dart.
typedef NS_ENUM(NSInteger, FCPFileFormat) {
  FCPFileFormatJPEG,
  FCPFileFormatHEIF,
  FCPFileFormatInvalid,
};

#pragma mark - image extension

/// Gets a string representation of ImageFileFormat.
extern FCPFileFormat FCPGetFileFormatFromString(NSString *fileFormatString);

NS_ASSUME_NONNULL_END
