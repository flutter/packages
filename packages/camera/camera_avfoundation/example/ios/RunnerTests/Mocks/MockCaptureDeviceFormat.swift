// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A mock implementation of `FLTCaptureDeviceFormat` that allows mocking the class
/// properties.
final class MockCaptureDeviceFormat: NSObject, FLTCaptureDeviceFormat {

  /// The format associated with the capture device.
  var format: AVCaptureDevice.Format {
    preconditionFailure("Attempted to access unimplemented property: format")
  }

  var _formatDescription: CMVideoFormatDescription?

  /// The format description for the capture device.
  var formatDescription: CMFormatDescription {
    _formatDescription!
  }

  /// The array of frame rate ranges supported by the video format.
  var videoSupportedFrameRateRanges: [FLTFrameRateRange] = []

  override init() {
    super.init()

    CMVideoFormatDescriptionCreate(
      allocator: kCFAllocatorDefault, codecType: kCVPixelFormatType_32BGRA, width: 1920,
      height: 1080, extensions: nil, formatDescriptionOut: &_formatDescription)
  }
}
