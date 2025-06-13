// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CoreMotion
import Flutter

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A class that manages camera's state and performs camera operations.
protocol Camera: FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate,
  AVCaptureAudioDataOutputSampleBufferDelegate
{
  /// The API instance used to communicate with the Dart side of the plugin.
  /// Once initially set, this should only ever be accessed on the main thread.
  var dartAPI: FCPCameraEventApi? { get set }

  var onFrameAvailable: (() -> Void)? { get set }

  /// Format used for video and image streaming.
  var videoFormat: FourCharCode { get set }

  var isPreviewPaused: Bool { get }
  var isStreamingImages: Bool { get }

  var minimumAvailableZoomFactor: CGFloat { get }
  var maximumAvailableZoomFactor: CGFloat { get }
  var minimumExposureOffset: CGFloat { get }
  var maximumExposureOffset: CGFloat { get }

  func setUpCaptureSessionForAudioIfNeeded()

  func reportInitializationState()

  /// Acknowledges the receipt of one image stream frame.
  func receivedImageStreamData()

  func start()
  func stop()

  /// Starts recording a video with an optional streaming messenger.
  func startVideoRecording(
    completion: @escaping (_ error: FlutterError?) -> Void,
    messengerForStreaming: FlutterBinaryMessenger?
  )
  func pauseVideoRecording()
  func resumeVideoRecording()
  func stopVideoRecording(completion: @escaping (_ path: String?, _ error: FlutterError?) -> Void)

  func captureToFile(completion: @escaping (_ path: String?, _ error: FlutterError?) -> Void)

  func setDeviceOrientation(_ orientation: UIDeviceOrientation)
  func lockCaptureOrientation(_ orientation: FCPPlatformDeviceOrientation)
  func unlockCaptureOrientation()

  func setImageFileFormat(_ fileFormat: FCPPlatformImageFileFormat)

  func setExposureMode(_ mode: FCPPlatformExposureMode)
  func setExposureOffset(_ offset: Double)
  func setExposurePoint(
    _ point: FCPPlatformPoint?,
    withCompletion: @escaping (_ error: FlutterError?) -> Void
  )

  func setFocusMode(_ mode: FCPPlatformFocusMode)
  func setFocusPoint(
    _ point: FCPPlatformPoint?,
    completion: @escaping (_ error: FlutterError?) -> Void
  )

  func setZoomLevel(_ zoom: CGFloat, withCompletion: @escaping (_ error: FlutterError?) -> Void)

  func setFlashMode(
    _ mode: FCPPlatformFlashMode,
    withCompletion: @escaping (_ error: FlutterError?) -> Void
  )

  func pausePreview()
  func resumePreview()

  func setDescriptionWhileRecording(
    _ cameraName: String,
    withCompletion: @escaping (_ error: FlutterError?) -> Void
  )

  func startImageStream(
    with: FlutterBinaryMessenger, completion: @escaping (_ error: FlutterError?) -> Void)
  func stopImageStream()

  // Override to make `AVCaptureVideoDataOutputSampleBufferDelegate`/
  // `AVCaptureAudioDataOutputSampleBufferDelegate` method non optional
  override func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  )

  func close()
}
