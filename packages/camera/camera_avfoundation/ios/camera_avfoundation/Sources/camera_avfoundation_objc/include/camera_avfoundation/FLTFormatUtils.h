// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTCamConfiguration.h"
#import "FLTCaptureDevice.h"
#import "FLTCaptureDeviceFormat.h"

NS_ASSUME_NONNULL_BEGIN

// Finds format with same resolution as current activeFormat in captureDevice for which
// bestFrameRateForFormat returned frame rate closest to mediaSettings.framesPerSecond.
// Preferred are formats with the same subtype as current activeFormat. Sets this format
// as activeFormat and also updates mediaSettings.framesPerSecond to value which
// bestFrameRateForFormat returned for that format.
extern void FLTSelectBestFormatForRequestedFrameRate(
    NSObject<FLTCaptureDevice> *captureDevice, FCPPlatformMediaSettings *mediaSettings,
    VideoDimensionsForFormat videoDimensionsForFormat);

NS_ASSUME_NONNULL_END
