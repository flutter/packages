// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// A protocol which is a direct passthrough to `AVFrameRateRange`. It exists to allow replacing
/// `AVFrameRateRange` in tests as it has no public initializer.
protocol FrameRateRange: NSObjectProtocol {
  var minFrameRate: Float64 { get }
  var maxFrameRate: Float64 { get }
}

/// A protocol which is a direct passthrough to `AVCaptureDeviceFormat`. It exists to allow
/// replacing `AVCaptureDeviceFormat` in tests as it has no public initializer.
protocol CaptureDeviceFormat: NSObjectProtocol {
  /// The underlying `AVCaptureDeviceFormat` instance. This exists so that the format
  /// can be extracted when setting the active format on a device.
  var avFormat: AVCaptureDevice.Format { get }

  var formatDescription: CMFormatDescription { get }
  var flutterVideoSupportedFrameRateRanges: [FrameRateRange] { get }
}

extension AVFrameRateRange: FrameRateRange {}

extension AVCaptureDevice.Format: CaptureDeviceFormat {
  var avFormat: AVCaptureDevice.Format { self }

  var flutterVideoSupportedFrameRateRanges: [FrameRateRange] { videoSupportedFrameRateRanges }
}
