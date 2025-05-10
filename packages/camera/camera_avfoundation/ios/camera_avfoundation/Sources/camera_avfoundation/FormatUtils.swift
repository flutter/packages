// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

enum FormatUtils {
  // Returns frame rate supported by format closest to targetFrameRate.
  private static func bestFrameRate(for format: FLTCaptureDeviceFormat, targetFrameRate: Double)
    -> Double
  {
    var bestFrameRate = 0.0
    var minDistance = Double.greatestFiniteMagnitude
    for range in format.videoSupportedFrameRateRanges {
      let frameRate = min(
        max(targetFrameRate, Double(range.minFrameRate)), Double(range.maxFrameRate))
      let distance = abs(frameRate - targetFrameRate)
      if distance < minDistance {
        bestFrameRate = frameRate
        minDistance = distance
      }
    }
    return bestFrameRate
  }

  // Finds format with same resolution as current activeFormat in captureDevice for which
  // bestFrameRateForFormat returned frame rate closest to mediaSettings.framesPerSecond.
  // Preferred are formats with the same subtype as current activeFormat. Sets this format
  // as activeFormat and also updates mediaSettings.framesPerSecond to value which
  // bestFrameRateForFormat returned for that format.
  static func selectBestFormatForRequestedFrameRate(
    captureDevice: FLTCaptureDevice,
    mediaSettings: FCPPlatformMediaSettings,
    targetFrameRate: Double,
    videoDimensionsForFormat: (FLTCaptureDeviceFormat) -> CMVideoDimensions
  ) {
    let targetResolution = videoDimensionsForFormat(captureDevice.activeFormat)
    let preferredSubType = CMFormatDescriptionGetMediaSubType(
      captureDevice.activeFormat.formatDescription)
    var bestFormat = captureDevice.activeFormat
    var _bestFrameRate = bestFrameRate(for: bestFormat, targetFrameRate: targetFrameRate)
    var minDistance = abs(_bestFrameRate - targetFrameRate)
    var isBestSubTypePreferred = true

    for format in captureDevice.formats {
      let resolution = videoDimensionsForFormat(format)
      if resolution.width != targetResolution.width || resolution.height != targetResolution.height
      {
        continue
      }
      let frameRate = bestFrameRate(for: format, targetFrameRate: targetFrameRate)
      let distance = abs(frameRate - targetFrameRate)
      let subType = CMFormatDescriptionGetMediaSubType(format.formatDescription)
      let isSubTypePreferred = subType == preferredSubType
      if distance < minDistance
        || (distance == minDistance && isSubTypePreferred && !isBestSubTypePreferred)
      {
        bestFormat = format
        _bestFrameRate = frameRate
        minDistance = distance
        isBestSubTypePreferred = isSubTypePreferred
      }
    }
    captureDevice.activeFormat = bestFormat
    mediaSettings.framesPerSecond = NSNumber(value: _bestFrameRate)
  }
}
