// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;
@import UIKit;

#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Gets AVCaptureFlashMode from FLTFlashMode.
/// @param mode flash mode.
extern AVCaptureFlashMode FCPGetAVCaptureFlashModeForPigeonFlashMode(FCPPlatformFlashMode mode);

/// Gets UIDeviceOrientation from its Pigeon representation.
extern UIDeviceOrientation FCPGetUIDeviceOrientationForPigeonDeviceOrientation(
    FCPPlatformDeviceOrientation orientation);

/// Gets a Pigeon representation of UIDeviceOrientation.
extern FCPPlatformDeviceOrientation FCPGetPigeonDeviceOrientationForOrientation(
    UIDeviceOrientation orientation);

/// Gets VideoFormat from its Pigeon representation.
extern OSType FCPGetPixelFormatForPigeonFormat(FCPPlatformImageFormatGroup imageFormat);

NS_ASSUME_NONNULL_END
