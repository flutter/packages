// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A mock implementation of `CaptureDeviceFormat` that allows mocking the class
/// properties.
final class MockCaptureDeviceFormat: NSObject, CaptureDeviceFormat {

  /// The format associated with the capture device.
  var avFormat: AVCaptureDevice.Format {
    preconditionFailure("Attempted to access unimplemented property: avFormat")
  }

  var _formatDescription: CMVideoFormatDescription?

  /// The format description for the capture device.
  var formatDescription: CMFormatDescription {
    _formatDescription!
  }

  /// The array of frame rate ranges supported by the video format.
  var flutterVideoSupportedFrameRateRanges: [FrameRateRange] = []

  override init() {
    super.init()

    CMVideoFormatDescriptionCreate(
      allocator: kCFAllocatorDefault, codecType: kCVPixelFormatType_32BGRA, width: 1920,
      height: 1080, extensions: nil, formatDescriptionOut: &_formatDescription)
  }
}
