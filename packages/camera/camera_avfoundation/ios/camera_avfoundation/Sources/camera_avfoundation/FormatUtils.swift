// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Determines the video dimensions (width and height) for a given capture device format.
/// Used in tests to mock CMVideoFormatDescriptionGetDimensions.
typealias VideoDimensionsForFormat = (FLTCaptureDeviceFormat) -> CMVideoDimensions

/// Returns frame rate supported by format closest to targetFrameRate.
private func bestFrameRate(for format: FLTCaptureDeviceFormat, targetFrameRate: Double) -> Double {
  var bestFrameRate: Double = 0
  var minDistance: Double = Double.greatestFiniteMagnitude

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

/// Finds format with same resolution as current activeFormat in captureDevice for which
/// bestFrameRate returned frame rate closest to mediaSettings.framesPerSecond.
/// Preferred are formats with the same subtype as current activeFormat. Sets this format
/// as activeFormat and also updates mediaSettings.framesPerSecond to value which
/// bestFrameRate returned for that format.
func selectBestFormat(
  for captureDevice: CaptureDevice,
  mediaSettings: FCPPlatformMediaSettings,
  videoDimensionsForFormat: VideoDimensionsForFormat
) {
  let targetResolution = videoDimensionsForFormat(captureDevice.fltActiveFormat)
  let targetFrameRate = mediaSettings.framesPerSecond?.doubleValue ?? 0
  let preferredSubType = CMFormatDescriptionGetMediaSubType(
    captureDevice.fltActiveFormat.formatDescription)

  var bestFormat = captureDevice.fltActiveFormat
  var resolvedBastFrameRate = bestFrameRate(for: bestFormat, targetFrameRate: targetFrameRate)
  var minDistance = abs(resolvedBastFrameRate - targetFrameRate)
  var isBestSubTypePreferred = true

  for format in captureDevice.fltFormats {
    let resolution = videoDimensionsForFormat(format)
    if resolution.width != targetResolution.width || resolution.height != targetResolution.height {
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
      resolvedBastFrameRate = frameRate
      minDistance = distance
      isBestSubTypePreferred = isSubTypePreferred
    }
  }

  captureDevice.fltActiveFormat = bestFormat
  mediaSettings.framesPerSecond = NSNumber(value: resolvedBastFrameRate)
}
