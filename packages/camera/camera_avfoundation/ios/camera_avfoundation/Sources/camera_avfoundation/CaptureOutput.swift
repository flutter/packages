// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A protocol which is a direct passthrough to `AVCaptureOutput`. It exists to allow mocking
/// `AVCaptureOutput` in tests.
protocol CaptureOutput {
  /// Returns a connection with the specified media type, or nil if no such connection exists.
  func connection(with mediaType: AVMediaType) -> CaptureConnection?
}

/// A protocol which is a direct passthrough to `AVCaptureVideoDataOutput`. It exists to allow
/// mocking `AVCaptureVideoDataOutput` in tests.
protocol CaptureVideoDataOutput: CaptureOutput {
  /// The underlying instance of `AVCaptureVideoDataOutput`.
  var avOutput: AVCaptureVideoDataOutput { get }

  /// Corresponds to the `alwaysDiscardsLateVideoFrames` property of `AVCaptureVideoDataOutput`
  var alwaysDiscardsLateVideoFrames: Bool { get set }

  /// Corresponds to the `videoSettings` property of `AVCaptureVideoDataOutput`
  var videoSettings: [String: Any]! { get set }

  /// Corresponds to the `setSampleBufferDelegate` method of `AVCaptureVideoDataOutput`
  func setSampleBufferDelegate(
    _ sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?,
    queue sampleBufferCallbackQueue: DispatchQueue?
  )
}

extension AVCaptureVideoDataOutput: CaptureVideoDataOutput {
  var avOutput: AVCaptureVideoDataOutput {
    return self
  }

  func connection(with mediaType: AVMediaType) -> CaptureConnection? {
    let connection: AVCaptureConnection? = connection(with: mediaType)
    return connection
  }
}

/// A protocol which is a direct passthrough to `AVCapturePhotoOutput`. It exists to allow mocking
/// `AVCapturePhotoOutput` in tests.
protocol CapturePhotoOutput: CaptureOutput {
  /// The underlying instance of `AVCapturePhotoOutput`.
  var avOutput: AVCapturePhotoOutput { get }

  /// Corresponds to the `availablePhotoCodecTypes` property of `AVCapturePhotoOutput`
  var availablePhotoCodecTypes: [AVVideoCodecType] { get }

  /// Corresponds to the `isHighResolutionCaptureEnabled` property of `AVCapturePhotoOutput`
  var isHighResolutionCaptureEnabled: Bool { get set }

  /// Corresponds to the `supportedFlashModes` property of `AVCapturePhotoOutput`
  var supportedFlashModes: [AVCaptureDevice.FlashMode] { get }

  /// Corresponds to the `capturePhotoWithSettings` method of `AVCapturePhotoOutput`
  func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate)
}

/// Make AVCapturePhotoOutput conform to FLTCapturePhotoOutput protocol directly
extension AVCapturePhotoOutput: CapturePhotoOutput {
  var avOutput: AVCapturePhotoOutput {
    return self
  }

  func connection(with mediaType: AVMediaType) -> CaptureConnection? {
    // Explicit type is required to access the underlying AVCapturePhotoOutput.connection method
    let connection: AVCaptureConnection? = connection(with: mediaType)
    return connection
  }
}
