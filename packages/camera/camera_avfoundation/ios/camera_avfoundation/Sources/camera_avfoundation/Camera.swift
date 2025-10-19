// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CoreMotion
import Flutter

// Import Objective-C part of the implementation when SwiftPM is used.
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

  var deviceOrientation: UIDeviceOrientation { get set }

  var minimumAvailableZoomFactor: CGFloat { get }
  var maximumAvailableZoomFactor: CGFloat { get }
  var minimumExposureOffset: CGFloat { get }
  var maximumExposureOffset: CGFloat { get }

  func setUpCaptureSessionForAudioIfNeeded()

  /// Informs the Dart side of the plugin of the current camera state and capabilities.
  func reportInitializationState()

  /// Acknowledges the receipt of one image stream frame.
  ///
  /// This should be called each time a frame is received. Failing to call it may
  /// cause later frames to be dropped instead of streamed.
  func receivedImageStreamData()

  func start()
  func stop()

  /// Starts recording a video with an optional streaming messenger.
  /// If the messenger is non-nil then it will be called for each
  /// captured frame, allowing streaming concurrently with recording.
  ///
  /// @param messenger Nullable messenger for capturing each frame.
  func startVideoRecording(
    completion: @escaping (_ error: FlutterError?) -> Void,
    messengerForStreaming: FlutterBinaryMessenger?
  )
  func pauseVideoRecording()
  func resumeVideoRecording()
  func stopVideoRecording(completion: @escaping (_ path: String?, _ error: FlutterError?) -> Void)

  func captureToFile(completion: @escaping (_ path: String?, _ error: FlutterError?) -> Void)

  func lockCaptureOrientation(_ orientation: FCPPlatformDeviceOrientation)
  func unlockCaptureOrientation()

  func setImageFileFormat(_ fileFormat: FCPPlatformImageFileFormat)

  func setExposureMode(_ mode: FCPPlatformExposureMode)
  func setExposureOffset(_ offset: Double)

  /// Sets the exposure point, in a (0,1) coordinate system.
  ///
  /// If @c point is nil, the exposure point will reset to the center.
  func setExposurePoint(
    _ point: FCPPlatformPoint?,
    withCompletion: @escaping (_ error: FlutterError?) -> Void
  )

  /// Sets FocusMode on the current AVCaptureDevice.
  ///
  /// If the @c focusMode is set to FocusModeAuto the AVCaptureDevice is configured to use
  /// AVCaptureFocusModeContinuousModeAutoFocus when supported, otherwise it is set to
  /// AVCaptureFocusModeAutoFocus. If neither AVCaptureFocusModeContinuousModeAutoFocus nor
  /// AVCaptureFocusModeAutoFocus are supported focus mode will not be set.
  /// If @c focusMode is set to FocusModeLocked the AVCaptureDevice is configured to use
  /// AVCaptureFocusModeAutoFocus. If AVCaptureFocusModeAutoFocus is not supported focus mode will not
  /// be set.
  ///
  /// @param mode The focus mode that should be applied.
  func setFocusMode(_ mode: FCPPlatformFocusMode)

  /// Sets the focus point, in a (0,1) coordinate system.
  ///
  /// If @c point is nil, the focus point will reset to the center.
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
