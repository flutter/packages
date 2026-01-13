// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A protocol which is a direct passthrough to AVCaptureDevice.
/// It exists to allow replacing AVCaptureDevice in tests.
protocol CaptureDevice: NSObjectProtocol {
  /// Underlying `AVCaptureDevice` instance. This is should not be used directly
  /// in the plugin implementation code, but it exists so that other protocol default
  /// implementation can pass the raw device to AVFoundation methods.
  var avDevice: AVCaptureDevice { get }

  // Device identifier
  var uniqueID: String { get }

  // Position/Orientation
  var position: AVCaptureDevice.Position { get }

  // Lens type
  var deviceType: AVCaptureDevice.DeviceType { get }

  // Format/Configuration
  var flutterActiveFormat: CaptureDeviceFormat { get set }
  var flutterFormats: [CaptureDeviceFormat] { get }

  // Flash/Torch
  var hasFlash: Bool { get }
  var hasTorch: Bool { get }
  var isTorchAvailable: Bool { get }
  var torchMode: AVCaptureDevice.TorchMode { get set }
  func isFlashModeSupported(_ mode: AVCaptureDevice.FlashMode) -> Bool

  // Focus
  var isFocusPointOfInterestSupported: Bool { get }
  func isFocusModeSupported(_ mode: AVCaptureDevice.FocusMode) -> Bool
  var focusMode: AVCaptureDevice.FocusMode { get set }
  var focusPointOfInterest: CGPoint { get set }

  // Exposure
  var isExposurePointOfInterestSupported: Bool { get }
  var exposureMode: AVCaptureDevice.ExposureMode { get set }
  var exposurePointOfInterest: CGPoint { get set }
  var minExposureTargetBias: Float { get }
  var maxExposureTargetBias: Float { get }
  func setExposureTargetBias(
    _ bias: Float, completionHandler handler: ((CMTime) -> Void)?)
  func isExposureModeSupported(_ mode: AVCaptureDevice.ExposureMode) -> Bool

  // Zoom
  var maxAvailableVideoZoomFactor: CGFloat { get }
  var minAvailableVideoZoomFactor: CGFloat { get }
  var videoZoomFactor: CGFloat { get set }

  // Camera Properties
  var lensAperture: Float { get }
  var exposureDuration: CMTime { get }
  var iso: Float { get }

  // Configuration Lock
  func lockForConfiguration() throws
  func unlockForConfiguration()

  // Frame Duration
  var activeVideoMinFrameDuration: CMTime { get set }
  var activeVideoMaxFrameDuration: CMTime { get set }
}

/// A protocol which is a direct passthrough to AVCaptureInput.
/// It exists to allow replacing AVCaptureInput in tests.
protocol CaptureInput: NSObjectProtocol {
  /// Underlying input instance. It is exposed as raw AVCaptureInput has to be passed to some
  /// AVFoundation methods. The plugin implementation code shouldn't use it though.
  var avInput: AVCaptureInput { get }

  var ports: [AVCaptureInput.Port] { get }
}

/// A protocol which wraps the creation of AVCaptureDeviceInput.
/// It exists to allow mocking instances of AVCaptureDeviceInput in tests.
protocol CaptureDeviceInputFactory: NSObjectProtocol {
  func deviceInput(with device: CaptureDevice) throws -> CaptureInput
}

extension AVCaptureDevice: CaptureDevice {
  var avDevice: AVCaptureDevice { self }

  var flutterActiveFormat: CaptureDeviceFormat {
    get { activeFormat }
    set { activeFormat = newValue.avFormat }
  }

  var flutterFormats: [CaptureDeviceFormat] { formats }
}

extension AVCaptureInput: CaptureInput {
  var avInput: AVCaptureInput { self }
}

/// A default implementation of CaptureDeviceInputFactory protocol which
/// wraps a call to AVCaptureInput static method `deviceInputWithDevice`.
class DefaultCaptureDeviceInputFactory: NSObject, CaptureDeviceInputFactory {
  func deviceInput(with device: CaptureDevice) throws -> CaptureInput {
    return try AVCaptureDeviceInput(device: device.avDevice)
  }
}
