// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

@testable import camera_avfoundation

/// Mock implementation of `CapturePhotoOutput` protocol which allows injecting a custom
/// implementation.
final class MockCapturePhotoOutput: NSObject, CapturePhotoOutput {
  var avOutput = AVCapturePhotoOutput()
  var availablePhotoCodecTypes: [AVVideoCodecType] = []
  var isHighResolutionCaptureEnabled = false
  var maxPhotoDimensions = CMVideoDimensions()
  var supportedFlashModes: [AVCaptureDevice.FlashMode] = []
  var flutterZeroShutterLagSupported = false
  /// Every write to the ZSL/responsive properties, in order, as `("zsl" or "responsive", value)`.
  var assignments: [(String, Bool)] = []
  /// Set when responsive capture was enabled while it was unsupported.
  var setResponsiveWhileUnsupported = false
  /// Models Apple's dependency: responsive capture is supported only while
  /// zero-shutter-lag is enabled.
  var responsiveCaptureSupportedWhenZslEnabled = false
  var flutterZeroShutterLagEnabled = false {
    didSet {
      assignments.append(("zsl", flutterZeroShutterLagEnabled))
      if !flutterZeroShutterLagEnabled {
        // Apple reverts responsive capture to NO when its support goes away.
        storedResponsiveCaptureEnabled = false
      }
    }
  }
  var flutterResponsiveCaptureSupported: Bool {
    return responsiveCaptureSupportedWhenZslEnabled && flutterZeroShutterLagEnabled
  }
  private var storedResponsiveCaptureEnabled = false
  var flutterResponsiveCaptureEnabled: Bool {
    get { return storedResponsiveCaptureEnabled }
    set {
      assignments.append(("responsive", newValue))
      if newValue && !flutterResponsiveCaptureSupported {
        setResponsiveWhileUnsupported = true
      }
      storedResponsiveCaptureEnabled = newValue
    }
  }

  // Stub that is called when the corresponding public method is called.
  var capturePhotoWithSettingsStub:
    ((_ settings: AVCapturePhotoSettings, _ delegate: AVCapturePhotoCaptureDelegate) -> Void)?

  // Stub that is called when the corresponding public method is called.
  var connectionWithMediaTypeStub: ((_ mediaType: AVMediaType) -> CaptureConnection?)?

  func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate)
  {
    capturePhotoWithSettingsStub?(settings, delegate)
  }

  func connection(with mediaType: AVMediaType) -> CaptureConnection? {
    return connectionWithMediaTypeStub?(mediaType)
  }
}
