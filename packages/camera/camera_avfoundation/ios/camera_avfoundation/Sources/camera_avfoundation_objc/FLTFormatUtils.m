// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import AVFoundation;

#import "./include/camera_avfoundation/FLTFormatUtils.h"

NS_ASSUME_NONNULL_BEGIN

// Returns frame rate supported by format closest to targetFrameRate.
double FLTBestFrameRateForFormat(NSObject<FLTCaptureDeviceFormat> *format, double targetFrameRate) {
  double bestFrameRate = 0;
  double minDistance = DBL_MAX;
  for (NSObject<FLTFrameRateRange> *range in format.videoSupportedFrameRateRanges) {
    double frameRate = MIN(MAX(targetFrameRate, range.minFrameRate), range.maxFrameRate);
    double distance = fabs(frameRate - targetFrameRate);
    if (distance < minDistance) {
      bestFrameRate = frameRate;
      minDistance = distance;
    }
  }
  return bestFrameRate;
}

void FLTSelectBestFormatForRequestedFrameRate(NSObject<FLTCaptureDevice> *captureDevice,
                                              FCPPlatformMediaSettings *mediaSettings,
                                              VideoDimensionsForFormat videoDimensionsForFormat) {
  CMVideoDimensions targetResolution = videoDimensionsForFormat(captureDevice.activeFormat);
  double targetFrameRate = mediaSettings.framesPerSecond.doubleValue;
  FourCharCode preferredSubType =
      CMFormatDescriptionGetMediaSubType(captureDevice.activeFormat.formatDescription);
  NSObject<FLTCaptureDeviceFormat> *bestFormat = captureDevice.activeFormat;
  double bestFrameRate = FLTBestFrameRateForFormat(bestFormat, targetFrameRate);
  double minDistance = fabs(bestFrameRate - targetFrameRate);
  BOOL isBestSubTypePreferred = YES;
  for (NSObject<FLTCaptureDeviceFormat> *format in captureDevice.formats) {
    CMVideoDimensions resolution = videoDimensionsForFormat(format);
    if (resolution.width != targetResolution.width ||
        resolution.height != targetResolution.height) {
      continue;
    }
    double frameRate = FLTBestFrameRateForFormat(format, targetFrameRate);
    double distance = fabs(frameRate - targetFrameRate);
    FourCharCode subType = CMFormatDescriptionGetMediaSubType(format.formatDescription);
    BOOL isSubTypePreferred = subType == preferredSubType;
    if (distance < minDistance ||
        (distance == minDistance && isSubTypePreferred && !isBestSubTypePreferred)) {
      bestFormat = format;
      bestFrameRate = frameRate;
      minDistance = distance;
      isBestSubTypePreferred = isSubTypePreferred;
    }
  }
  captureDevice.activeFormat = bestFormat;
  mediaSettings.framesPerSecond = @(bestFrameRate);
}

NS_ASSUME_NONNULL_END
