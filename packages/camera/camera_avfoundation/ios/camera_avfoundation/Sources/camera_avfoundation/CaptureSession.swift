// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A protocol which is a direct passthrough to AVCaptureSession.
/// It exists to allow replacing AVCaptureSession in tests.
protocol CaptureSession: NSObjectProtocol {
  var sessionPreset: AVCaptureSession.Preset { get set }
  var inputs: [AVCaptureInput] { get }
  var outputs: [AVCaptureOutput] { get }
  var automaticallyConfiguresApplicationAudioSession: Bool { get set }

  func beginConfiguration()
  func commitConfiguration()
  func startRunning()
  func stopRunning()
  func canSetSessionPreset(_ preset: AVCaptureSession.Preset) -> Bool
  func addInputWithNoConnections(_ input: CaptureInput)
  func addOutputWithNoConnections(_ output: AVCaptureOutput)
  func addConnection(_ connection: AVCaptureConnection)
  func addInput(_ input: CaptureInput)
  func addOutput(_ output: AVCaptureOutput)
  func removeInput(_ input: CaptureInput)
  func removeOutput(_ output: AVCaptureOutput)
  func canAddInput(_ input: CaptureInput) -> Bool
  func canAddOutput(_ output: AVCaptureOutput) -> Bool
  func canAddConnection(_ connection: AVCaptureConnection) -> Bool
}

extension AVCaptureSession: CaptureSession {
  func addInputWithNoConnections(_ input: CaptureInput) {
    addInputWithNoConnections(input.avInput)
  }

  func addInput(_ input: CaptureInput) {
    addInput(input.avInput)
  }

  func removeInput(_ input: CaptureInput) {
    removeInput(input.avInput)
  }

  func canAddInput(_ input: CaptureInput) -> Bool {
    canAddInput(input.avInput)
  }
}
