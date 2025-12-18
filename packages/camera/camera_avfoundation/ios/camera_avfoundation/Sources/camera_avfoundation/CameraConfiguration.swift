// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CoreMedia
import UIKit

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Factory block returning an FLTCaptureDevice.
/// Used in tests to inject a video capture device into DefaultCamera.
typealias VideoCaptureDeviceFactory = (_ cameraName: String) -> CaptureDevice

typealias AudioCaptureDeviceFactory = () -> CaptureDevice

typealias CaptureSessionFactory = () -> CaptureSession

typealias AssetWriterFactory = (_ assetUrl: URL, _ fileType: AVFileType) throws -> AssetWriter

typealias InputPixelBufferAdaptorFactory = (
  _ input: AssetWriterInput, _ settings: [String: Any]?
) ->
  AssetWriterInputPixelBufferAdaptor

/// A configuration object that centralizes dependencies for `DefaultCamera`.
class CameraConfiguration {
  var mediaSettings: FCPPlatformMediaSettings
  var mediaSettingsWrapper: FLTCamMediaSettingsAVWrapper
  var captureSessionQueue: DispatchQueue
  var videoCaptureSession: CaptureSession
  var audioCaptureSession: CaptureSession
  var videoCaptureDeviceFactory: VideoCaptureDeviceFactory
  let audioCaptureDeviceFactory: AudioCaptureDeviceFactory
  let captureDeviceInputFactory: CaptureDeviceInputFactory
  var assetWriterFactory: AssetWriterFactory
  var inputPixelBufferAdaptorFactory: InputPixelBufferAdaptorFactory
  var videoDimensionsConverter: VideoDimensionsConverter
  var deviceOrientationProvider: DeviceOrientationProvider
  let initialCameraName: String
  var orientation: UIDeviceOrientation

  init(
    mediaSettings: FCPPlatformMediaSettings,
    mediaSettingsWrapper: FLTCamMediaSettingsAVWrapper,
    captureDeviceFactory: @escaping VideoCaptureDeviceFactory,
    audioCaptureDeviceFactory: @escaping AudioCaptureDeviceFactory,
    captureSessionFactory: @escaping CaptureSessionFactory,
    captureSessionQueue: DispatchQueue,
    captureDeviceInputFactory: CaptureDeviceInputFactory,
    initialCameraName: String
  ) {
    self.mediaSettings = mediaSettings
    self.mediaSettingsWrapper = mediaSettingsWrapper
    self.videoCaptureDeviceFactory = captureDeviceFactory
    self.audioCaptureDeviceFactory = audioCaptureDeviceFactory
    self.captureSessionQueue = captureSessionQueue
    self.videoCaptureSession = captureSessionFactory()
    self.audioCaptureSession = captureSessionFactory()
    self.captureDeviceInputFactory = captureDeviceInputFactory
    self.initialCameraName = initialCameraName
    self.orientation = UIDevice.current.orientation
    self.deviceOrientationProvider = DefaultDeviceOrientationProvider()

    self.videoDimensionsConverter = { format in
      return CMVideoFormatDescriptionGetDimensions(format.formatDescription)
    }

    self.assetWriterFactory = { url, fileType in
      return try AVAssetWriter(outputURL: url, fileType: fileType)
    }

    self.inputPixelBufferAdaptorFactory = { assetWriterInput, sourcePixelBufferAttributes in
      return AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: assetWriterInput.avInput,
        sourcePixelBufferAttributes: sourcePixelBufferAttributes
      )
    }
  }
}
