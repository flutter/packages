// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

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

  /// Corresponds to the `availableVideoPixelFormatTypes` property of `AVCaptureVideoDataOutput`
  var availableVideoPixelFormatTypes: [FourCharCode] { get }

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

  /// Corresponds to the `isZeroShutterLagSupported` property of
  /// `AVCapturePhotoOutput` on iOS 17+/macOS 14+; `false` on older versions.
  var flutterZeroShutterLagSupported: Bool { get }

  /// Corresponds to the `isZeroShutterLagEnabled` property of
  /// `AVCapturePhotoOutput` on iOS 17+/macOS 14+; reads `false` and ignores
  /// writes on older versions.
  var flutterZeroShutterLagEnabled: Bool { get set }

  /// Corresponds to the `capturePhotoWithSettings` method of `AVCapturePhotoOutput`
  func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate)
}

/// Make AVCapturePhotoOutput conform to FLTCapturePhotoOutput protocol directly
extension AVCapturePhotoOutput: CapturePhotoOutput {
  var avOutput: AVCapturePhotoOutput {
    return self
  }

  var flutterZeroShutterLagSupported: Bool {
    if #available(iOS 17.0, macOS 14.0, *) {
      return isZeroShutterLagSupported
    }
    return false
  }

  var flutterZeroShutterLagEnabled: Bool {
    get {
      if #available(iOS 17.0, macOS 14.0, *) {
        return isZeroShutterLagEnabled
      }
      return false
    }
    set {
      if #available(iOS 17.0, macOS 14.0, *) {
        isZeroShutterLagEnabled = newValue
      }
    }
  }

  func connection(with mediaType: AVMediaType) -> CaptureConnection? {
    // Explicit type is required to access the underlying AVCapturePhotoOutput.connection method
    let connection: AVCaptureConnection? = connection(with: mediaType)
    return connection
  }
}
