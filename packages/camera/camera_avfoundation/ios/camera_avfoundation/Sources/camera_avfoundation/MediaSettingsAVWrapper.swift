// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CoreMedia

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// An interface for performing media settings operations.
///
/// xctest-expectation-checking implementation (`TestMediaSettingsAVWrapper`) of this interface can
/// be injected into `camera-avfoundation` plugin allowing to run media-settings tests without any
/// additional mocking of AVFoundation classes.
class FLTCamMediaSettingsAVWrapper {

  /// Requests exclusive access to configure device hardware properties.
  /// - Parameter captureDevice: The capture device.
  /// - Throws: An error if the device could not be locked for configuration.
  /// - Returns: A Bool indicating whether the device was successfully locked for configuration.
  func lockDevice(_ captureDevice: CaptureDevice) throws {
    return try captureDevice.lockForConfiguration()
  }

  /// Release exclusive control over device hardware properties.
  /// - Parameter captureDevice: The capture device.
  func unlockDevice(_ captureDevice: CaptureDevice) {
    captureDevice.unlockForConfiguration()
  }

  /// When paired with commitConfiguration, allows a client to batch multiple configuration
  /// operations on a running session into atomic updates.
  /// - Parameter videoCaptureSession: The video capture session.
  func beginConfiguration(for videoCaptureSession: CaptureSession) {
    videoCaptureSession.beginConfiguration()
  }

  /// When preceded by beginConfiguration, allows a client to batch multiple configuration
  /// operations on a running session into atomic updates.
  /// - Parameter videoCaptureSession: The video capture session.
  func commitConfiguration(for videoCaptureSession: CaptureSession) {
    videoCaptureSession.commitConfiguration()
  }

  /// Set receiver's current active minimum frame duration (the reciprocal of its max frame rate).
  /// - Parameters:
  ///   - duration: The frame duration.
  ///   - captureDevice: The capture device
  func setMinFrameDuration(_ duration: CMTime, on captureDevice: CaptureDevice) {
    captureDevice.activeVideoMinFrameDuration = duration
  }

  /// Set receiver's current active maximum frame duration (the reciprocal of its min frame rate).
  /// - Parameters:
  ///   - duration: The frame duration.
  ///   - captureDevice: The capture device
  func setMaxFrameDuration(_ duration: CMTime, on captureDevice: CaptureDevice) {
    captureDevice.activeVideoMaxFrameDuration = duration
  }

  /// Creates a new input of the audio media type to receive sample buffers for writing to
  /// the output file.
  /// - Parameter outputSettings: The settings used for encoding the audio appended to the output.
  /// - Returns: An instance of `AssetWriterInput`.
  func assetWriterAudioInput(withOutputSettings outputSettings: [String: Any]?)
    -> AssetWriterInput
  {
    return AVAssetWriterInput(mediaType: .audio, outputSettings: outputSettings)
  }

  /// Creates a new input of the video media type to receive sample buffers for writing to
  /// the output file.
  /// - Parameter outputSettings: The settings used for encoding the video appended to the output.
  /// - Returns: An instance of `AssetWriterInput`.
  func assetWriterVideoInput(withOutputSettings outputSettings: [String: Any]?)
    -> AssetWriterInput
  {
    return AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
  }

  /// Adds an input to the asset writer.
  /// - Parameters:
  ///   - writerInput: The `AssetWriterInput` object to be added.
  ///   - writer: The `AssetWriter` object.
  func addInput(_ writerInput: AssetWriterInput, to writer: AssetWriter) {
    writer.add(writerInput.avInput)
  }

  /// Specifies the recommended video settings for `FLTCaptureVideoDataOutput`.
  /// - Parameters:
  ///   - fileType: Specifies the UTI of the file type to be written (see AVMediaFormat.h for a list
  ///     of file format UTIs).
  ///   - output: The `FLTCaptureVideoDataOutput` instance.
  /// - Returns: A fully populated dictionary of keys and values that are compatible with AVAssetWriter.
  func recommendedVideoSettingsForAssetWriter(
    withFileType fileType: AVFileType,
    for output: CaptureVideoDataOutput
  ) -> [String: Any]? {
    return output.avOutput.recommendedVideoSettingsForAssetWriter(writingTo: fileType)
  }
}
