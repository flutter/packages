// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// Determines the video dimensions (width and height) for a given capture device format.
/// Used in tests to mock CMVideoFormatDescriptionGetDimensions.
typealias VideoDimensionsConverter = (CaptureDeviceFormat) -> CMVideoDimensions

enum FormatUtils {
  /// Compressed, lossy pixel formats that the Flutter Engine does not support and that crash it.
  private static let unsupportedSubTypes: [FourCharCode] = [
    1_651_798_066  // Hex for 'btp2', or kCVPixelFormatType_96VersatileBayerPacked12
  ]

  /// The 8-bit pixel formats. The plugin's video data output and photo settings expect 8-bit
  /// formats, so 10-bit ones (for example `x420` and `x422`) are not chosen for an aspect ratio.
  private static let eightBitSubTypes: [FourCharCode] = [
    kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
    kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
    kCVPixelFormatType_32BGRA,
  ]

  /// Returns whether the format has a pixel subtype that crashes the Flutter Engine.
  static func hasUnsupportedSubType(_ format: CaptureDeviceFormat) -> Bool {
    return unsupportedSubTypes.contains(
      CMFormatDescriptionGetMediaSubType(format.formatDescription))
  }

  /// Returns whether the format has an 8-bit pixel subtype.
  static func hasEightBitSubType(_ format: CaptureDeviceFormat) -> Bool {
    return eightBitSubTypes.contains(CMFormatDescriptionGetMediaSubType(format.formatDescription))
  }

  /// Returns whether a format can be chosen for an aspect ratio.
  static func isAspectRatioCandidate(_ format: CaptureDeviceFormat) -> Bool {
    return !hasUnsupportedSubType(format) && hasEightBitSubType(format)
  }

  /// Returns frame rate supported by format closest to targetFrameRate.
  static private func bestFrameRate(for format: CaptureDeviceFormat, targetFrameRate: Double)
    -> Double
  {
    var bestFrameRate: Double = 0
    var minDistance: Double = Double.greatestFiniteMagnitude

    for range in format.flutterVideoSupportedFrameRateRanges {
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
  /// Preferred are formats with the same subtype as current activeFormat. Returns this format
  /// and frame rate which bestFrameRate returned for that format. Only formats that pass
  /// `formatFilter`, if given, are considered besides the active one.
  static func findBestFormat(
    for captureDevice: CaptureDevice,
    mediaSettings: PlatformMediaSettings,
    videoDimensionsConverter: VideoDimensionsConverter,
    formatFilter: ((CaptureDeviceFormat) -> Bool)? = nil
  ) -> (format: CaptureDeviceFormat, frameRate: Double) {
    let targetResolution = videoDimensionsConverter(captureDevice.flutterActiveFormat)
    let targetFrameRate = Double(mediaSettings.framesPerSecond ?? 0)
    let preferredSubType = CMFormatDescriptionGetMediaSubType(
      captureDevice.flutterActiveFormat.formatDescription)

    var bestFormat = captureDevice.flutterActiveFormat
    var resolvedBestFrameRate = bestFrameRate(for: bestFormat, targetFrameRate: targetFrameRate)
    var minDistance = abs(resolvedBestFrameRate - targetFrameRate)
    var isBestSubTypePreferred = true

    for format in captureDevice.flutterFormats {
      if let formatFilter, !formatFilter(format) {
        continue
      }
      let resolution = videoDimensionsConverter(format)
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
        resolvedBestFrameRate = frameRate
        minDistance = distance
        isBestSubTypePreferred = isSubTypePreferred
      }
    }

    return (bestFormat, resolvedBestFrameRate)
  }

  /// The length of the shorter side that a resolution preset asks for within an aspect ratio, or
  /// nil for the highest resolution.
  static func shortSide(for preset: PlatformResolutionPreset) -> Int32? {
    switch preset {
    case .low: return 240
    case .medium: return 480
    case .high: return 720
    case .veryHigh: return 1080
    case .ultraHigh: return 2160
    case .max: return nil
    }
  }

  /// Returns whether `dimensions` have the given aspect ratio, in either orientation.
  static func matches(_ dimensions: CMVideoDimensions, _ aspectRatio: PlatformCameraAspectRatio)
    -> Bool
  {
    let (long, short): (Int64, Int64) =
      aspectRatio == .ratio4x3 ? (4, 3) : (16, 9)
    let width = Int64(max(dimensions.width, dimensions.height))
    let height = Int64(min(dimensions.width, dimensions.height))
    return width * short == height * long
  }

  /// Returns the formats of `captureDevice` for an aspect ratio and a resolution preset, best
  /// first, or an empty array when the device has no format with that aspect ratio.
  ///
  /// The formats have the aspect ratio and are 8-bit formats the Flutter Engine supports. Among
  /// them, the video size is the smallest whose shorter side is at least the preset's (the largest
  /// if none is, or for `max`). All returned formats have that size, ordered by the largest photo
  /// they can take.
  static func findAspectRatioFormats(
    for captureDevice: CaptureDevice,
    aspectRatio: PlatformCameraAspectRatio,
    preset: PlatformResolutionPreset,
    videoDimensionsConverter: VideoDimensionsConverter
  ) -> [CaptureDeviceFormat] {
    let candidates = captureDevice.flutterFormats.filter { format in
      guard isAspectRatioCandidate(format) else { return false }
      return matches(videoDimensionsConverter(format), aspectRatio)
    }
    func shortSide(of format: CaptureDeviceFormat) -> Int32 {
      let size = videoDimensionsConverter(format)
      return min(size.width, size.height)
    }
    let sizes = Set(candidates.map(shortSide(of:))).sorted()
    guard let largest = sizes.last else { return [] }
    let target = FormatUtils.shortSide(for: preset).flatMap { minimum in
      sizes.first { $0 >= minimum }
    }
    let chosenSize = target ?? largest

    return orderedByPhotoSize(candidates.filter { shortSide(of: $0) == chosenSize })
  }

  /// Orders formats by the largest photo they can take, largest first, keeping the device's order
  /// among formats that take the same photo size.
  static func orderedByPhotoSize(_ formats: [CaptureDeviceFormat]) -> [CaptureDeviceFormat] {
    func photoPixels(_ format: CaptureDeviceFormat) -> Int64 {
      guard #available(iOS 16.0, *) else { return 0 }
      return format.supportedMaxPhotoDimensions
        .map { Int64($0.width) * Int64($0.height) }
        .max() ?? 0
    }
    return formats.enumerated()
      .sorted {
        let (lhs, rhs) = (photoPixels($0.element), photoPixels($1.element))
        return lhs != rhs ? lhs > rhs : $0.offset < $1.offset
      }
      .map(\.element)
  }
}
