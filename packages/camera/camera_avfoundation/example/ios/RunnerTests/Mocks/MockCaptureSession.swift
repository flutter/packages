// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Mock implementation of `FLTCaptureSession` protocol which allows injecting a custom
/// implementation.
final class MockCaptureSession: NSObject, FLTCaptureSession {
  var setSessionPresetStub: ((AVCaptureSession.Preset) -> Void)?
  var beginConfigurationStub: (() -> Void)?
  var commitConfigurationStub: (() -> Void)?
  var startRunningStub: (() -> Void)?
  var stopRunningStub: (() -> Void)?
  var canSetSessionPresetStub: ((AVCaptureSession.Preset) -> Bool)?

  var _sessionPreset = AVCaptureSession.Preset.high
  var inputs = [AVCaptureInput]()
  var outputs = [AVCaptureOutput]()
  var automaticallyConfiguresApplicationAudioSession = false

  var sessionPreset: AVCaptureSession.Preset {
    get {
      return _sessionPreset
    }
    set {
      setSessionPresetStub?(newValue)
    }
  }

  func beginConfiguration() {
    beginConfigurationStub?()
  }

  func commitConfiguration() {
    commitConfigurationStub?()
  }

  func startRunning() {
    startRunningStub?()
  }

  func stopRunning() {
    stopRunningStub?()
  }

  func canSetSessionPreset(_ preset: AVCaptureSession.Preset) -> Bool {
    return canSetSessionPresetStub?(preset) ?? true
  }

  func addInputWithNoConnections(_ input: FLTCaptureInput) {}

  func addOutputWithNoConnections(_ output: AVCaptureOutput) {}

  func addConnection(_: AVCaptureConnection) {}

  func addInput(_: FLTCaptureInput) {}

  func addOutput(_: AVCaptureOutput) {}

  func removeInput(_: FLTCaptureInput) {}

  func removeOutput(_: AVCaptureOutput) {}

  func canAddInput(_: FLTCaptureInput) -> Bool {
    return true
  }

  func canAddOutput(_: AVCaptureOutput) -> Bool {
    return true
  }

  func canAddConnection(_: AVCaptureConnection) -> Bool {
    return true
  }
}
