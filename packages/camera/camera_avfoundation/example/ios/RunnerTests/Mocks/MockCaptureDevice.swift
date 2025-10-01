// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A mock implementation of `FLTCaptureDevice` that allows mocking the class
/// properties.
class MockCaptureDevice: NSObject, FLTCaptureDevice {
  var activeFormatStub: (() -> FLTCaptureDeviceFormat)?
  var setActiveFormatStub: ((FLTCaptureDeviceFormat) -> Void)?
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

  var device: AVCaptureDevice {
    preconditionFailure("Attempted to access unimplemented property: device")
  }

  var uniqueID = ""
  var position = AVCaptureDevice.Position.unspecified

  var activeFormat: FLTCaptureDeviceFormat {
    get {
      activeFormatStub?() ?? MockCaptureDeviceFormat()
    }
    set {
      setActiveFormatStub?(newValue)
    }
  }

  var formats: [FLTCaptureDeviceFormat] = []
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

  func setFocusMode(_ focusMode: AVCaptureDevice.FocusMode) {
    setFocusModeStub?(focusMode)
  }

  func setFocusPointOfInterest(_ point: CGPoint) {
    setFocusPointOfInterestStub?(point)
  }

  func setExposureMode(_ exposureMode: AVCaptureDevice.ExposureMode) {
    setExposureModeStub?(exposureMode)
  }

  func setExposurePointOfInterest(_ point: CGPoint) {
    setExposurePointOfInterestStub?(point)
  }

  func setExposureTargetBias(_ bias: Float, completionHandler handler: ((CMTime) -> Void)? = nil) {
    setExposureTargetBiasStub?(bias, handler)
  }

  func isExposureModeSupported(_ mode: AVCaptureDevice.ExposureMode) -> Bool {
    return isExposureModeSupportedStub?(mode) ?? false
  }

  func lensAperture() -> Float {
    return 0
  }

  func exposureDuration() -> CMTime {
    return CMTime(value: 1, timescale: 1)
  }

  func iso() -> Float {
    return 0
  }
  
  func isVideoStabilizationModeSupported(_ videoStabilizationMode: AVCaptureVideoStabilizationMode) -> Bool {
    return false
  }


  func lockForConfiguration() throws {
    try lockForConfigurationStub?()
  }

  func unlockForConfiguration() {}
}
