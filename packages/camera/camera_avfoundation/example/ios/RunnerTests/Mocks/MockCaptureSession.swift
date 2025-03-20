// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  func addConnection(connection: AVCaptureConnection) {}

  func addInput(input: FLTCaptureInput) {}

  func addOutput(output: AVCaptureOutput) {}

  func removeInput(input: FLTCaptureInput) {}

  func removeOutput(output: AVCaptureOutput) {}

  func canAddInput(input: FLTCaptureInput) -> Bool {
    return true
  }

  func canAddOutput(output: AVCaptureOutput) -> Bool {
    return true
  }

  func canAddConnection(connection: AVCaptureConnection) -> Bool {
    return true
  }
}
