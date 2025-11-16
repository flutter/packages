// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A mock implementation of `FLTCaptureDevice` that allows mocking the class
/// properties.
class MockCaptureDevice: NSObject, CaptureDevice {
  var activeFormatStub: (() -> CaptureDeviceFormat)?
  var setActiveFormatStub: ((CaptureDeviceFormat) -> Void)?
  var getTorchModeStub: (() -> AVCaptureDevice.TorchMode)?
  var setTorchModeStub: ((AVCaptureDevice.TorchMode) -> Void)?
  var isFocusModeSupportedStub: ((AVCaptureDevice.FocusMode) -> Bool)?
  var setFocusModeStub: ((AVCaptureDevice.FocusMode) -> Void)?
  var setFocusPointOfInterestStub: ((CGPoint) -> Void)?
  var setExposureModeStub: ((AVCaptureDevice.ExposureMode) -> Void)?
  var setExposurePointOfInterestStub: ((CGPoint) -> Void)?
  var setExposureTargetBiasStub: ((Float, ((CMTime) -> Void)?) -> Void)?
  var isExposureModeSupportedStub: ((AVCaptureDevice.ExposureMode) -> Bool)?
  var setVideoZoomFactorStub: ((CGFloat) -> Void)?
  var lockForConfigurationStub: (() throws -> Void)?

  var avDevice: AVCaptureDevice {
    preconditionFailure("Attempted to access unimplemented property: device")
  }

  var uniqueID = ""
  var position = AVCaptureDevice.Position.unspecified
  var deviceType = AVCaptureDevice.DeviceType.builtInWideAngleCamera

  var flutterActiveFormat: CaptureDeviceFormat {
    get {
      activeFormatStub?() ?? MockCaptureDeviceFormat()
    }
    set {
      setActiveFormatStub?(newValue)
    }
  }

  var flutterFormats: [CaptureDeviceFormat] = []
  var hasFlash = false
  var hasTorch = false
  var isTorchAvailable = false
  var torchMode: AVCaptureDevice.TorchMode {
    get {
      getTorchModeStub?() ?? .off
    }
    set {
      setTorchModeStub?(newValue)
    }
  }
  var isFocusPointOfInterestSupported = false
  var maxAvailableVideoZoomFactor = CGFloat(0)
  var minAvailableVideoZoomFactor = CGFloat(0)
  var videoZoomFactor: CGFloat {
    get { 0 }
    set {
      setVideoZoomFactorStub?(newValue)
    }
  }
  var isExposurePointOfInterestSupported = false
  var minExposureTargetBias = Float(0)
  var maxExposureTargetBias = Float(0)
  var activeVideoMinFrameDuration = CMTime(value: 1, timescale: 1)
  var activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 1)

  func isFlashModeSupported(_ mode: AVCaptureDevice.FlashMode) -> Bool {
    return false
  }

  func isFocusModeSupported(_ mode: AVCaptureDevice.FocusMode) -> Bool {
    return isFocusModeSupportedStub?(mode) ?? false
  }

  var focusMode: AVCaptureDevice.FocusMode {
    get { .autoFocus }
    set { setFocusModeStub?(newValue) }
  }

  func setFocusMode(_ focusMode: AVCaptureDevice.FocusMode) {
    setFocusModeStub?(focusMode)
  }

  var focusPointOfInterest: CGPoint {
    get { CGPoint.zero }
    set { setFocusPointOfInterestStub?(newValue) }
  }

  var exposureMode: AVCaptureDevice.ExposureMode {
    get { .autoExpose }
    set { setExposureModeStub?(newValue) }
  }

  var exposurePointOfInterest: CGPoint {
    get { CGPoint.zero }
    set { setExposurePointOfInterestStub?(newValue) }
  }

  func setExposureTargetBias(_ bias: Float, completionHandler handler: ((CMTime) -> Void)? = nil) {
    setExposureTargetBiasStub?(bias, handler)
  }

  func isExposureModeSupported(_ mode: AVCaptureDevice.ExposureMode) -> Bool {
    return isExposureModeSupportedStub?(mode) ?? false
  }

  var lensAperture: Float { 0 }

  var exposureDuration: CMTime { CMTime(value: 1, timescale: 1) }

  var iso: Float { 0 }

  func lockForConfiguration() throws {
    try lockForConfigurationStub?()
  }

  func unlockForConfiguration() {}
}
