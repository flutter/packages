// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

@testable import camera_avfoundation

/// Mock implementation of `CaptureSession` protocol which allows injecting a custom
/// implementation.
final class MockCaptureSession: NSObject, CaptureSession {
  var setSessionPresetStub: ((AVCaptureSession.Preset) -> Void)?
  var beginConfigurationStub: (() -> Void)?
  var commitConfigurationStub: (() -> Void)?
  var startRunningStub: (() -> Void)?
  var stopRunningStub: (() -> Void)?
  var canSetSessionPresetStub: ((AVCaptureSession.Preset) -> Bool)?

  var _sessionPreset = AVCaptureSession.Preset.high
  private(set) var captureInputs = [CaptureInput]()
  var inputs = [AVCaptureInput]()
  var outputs = [AVCaptureOutput]()
  private(set) var connections = [AVCaptureConnection]()

  private(set) var addedAudioOutputCount: Int = 0

  var automaticallyConfiguresApplicationAudioSession = false
  var isRunning = true

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

  func addInputWithNoConnections(_ input: CaptureInput) {
    captureInputs.append(input)
  }

  func addOutputWithNoConnections(_ output: AVCaptureOutput) {
    outputs.append(output)
  }

  func addConnection(_ connection: AVCaptureConnection) {
    connections.append(connection)
  }

  func addInput(_ input: CaptureInput) {
    captureInputs.append(input)
    for output in outputs where !connections.contains(where: { $0.output === output }) {
      connections.append(AVCaptureConnection(inputPorts: input.ports, output: output))
    }
  }

  func addOutput(_ output: AVCaptureOutput) {
    outputs.append(output)
    if !captureInputs.isEmpty && !connections.contains(where: { $0.output === output }) {
      connections.append(
        AVCaptureConnection(inputPorts: captureInputs.flatMap(\.ports), output: output))
    }
    if output is AVCaptureAudioDataOutput {
      addedAudioOutputCount += 1
    }
  }

  func removeInput(_ input: CaptureInput) {
    captureInputs.removeAll { $0 === input }
    // In unit tests, `MockCaptureInput.ports` is empty because `AVCaptureInput.Port` cannot be
    // instantiated without a real hardware device.
    if captureInputs.isEmpty {
      connections.removeAll()
    } else {
      connections.removeAll { connection in
        connection.inputPorts.contains { port in
          input.ports.contains { $0 === port }
        }
      }
    }
  }

  func removeOutput(_ output: AVCaptureOutput) {
    outputs.removeAll { $0 === output }
    connections.removeAll { $0.output === output }
  }

  func canAddInput(_: CaptureInput) -> Bool {
    return true
  }

  func canAddOutput(_: AVCaptureOutput) -> Bool {
    return true
  }

  func canAddConnection(_ connection: AVCaptureConnection) -> Bool {
    guard let output = connection.output else { return true }
    return !connections.contains(where: { $0.output === output })
  }
}
