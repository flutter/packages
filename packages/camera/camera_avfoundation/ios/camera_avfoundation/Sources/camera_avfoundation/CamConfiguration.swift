// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CoreMedia
import Foundation
import UIKit

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Factory block returning an FLTCaptureDevice.
/// Used in tests to inject a device into DefaultCamera.
typealias CaptureDeviceFactory = (String) -> FLTCaptureDevice

typealias AudioCaptureDeviceFactory = () -> FLTCaptureDevice

typealias CaptureSessionFactory = () -> FLTCaptureSession

typealias AssetWriterFactory = (URL, AVFileType, inout NSError?) -> FLTAssetWriter?

typealias InputPixelBufferAdaptorFactory = (FLTAssetWriterInput, [String: Any]?) ->
  FLTAssetWriterInputPixelBufferAdaptor

/// Determines the video dimensions (width and height) for a given capture device format.
/// Used in tests to mock CMVideoFormatDescriptionGetDimensions.
typealias VideoDimensionsForFormat = (FLTCaptureDeviceFormat) -> CMVideoDimensions

/// A configuration object that centralizes dependencies for `DefaultCamera`.
class FLTCamConfiguration {
  var mediaSettings: FCPPlatformMediaSettings
  var mediaSettingsWrapper: FLTCamMediaSettingsAVWrapper
  var captureSessionQueue: DispatchQueue
  var videoCaptureSession: FLTCaptureSession
  var audioCaptureSession: FLTCaptureSession
  var captureDeviceFactory: CaptureDeviceFactory
  let audioCaptureDeviceFactory: AudioCaptureDeviceFactory
  let captureDeviceInputFactory: FLTCaptureDeviceInputFactory
  var assetWriterFactory: AssetWriterFactory
  var inputPixelBufferAdaptorFactory: InputPixelBufferAdaptorFactory
  var videoDimensionsForFormat: VideoDimensionsForFormat
  var deviceOrientationProvider: FLTDeviceOrientationProviding
  let initialCameraName: String
  var orientation: UIDeviceOrientation

  init(
    mediaSettings: FCPPlatformMediaSettings,
    mediaSettingsWrapper: FLTCamMediaSettingsAVWrapper,
    captureDeviceFactory: @escaping CaptureDeviceFactory,
    audioCaptureDeviceFactory: @escaping AudioCaptureDeviceFactory,
    captureSessionFactory: @escaping CaptureSessionFactory,
    captureSessionQueue: DispatchQueue,
    captureDeviceInputFactory: FLTCaptureDeviceInputFactory,
    initialCameraName: String
  ) {
    self.mediaSettings = mediaSettings
    self.mediaSettingsWrapper = mediaSettingsWrapper
    self.captureDeviceFactory = captureDeviceFactory
    self.audioCaptureDeviceFactory = audioCaptureDeviceFactory
    self.captureSessionQueue = captureSessionQueue
    self.videoCaptureSession = captureSessionFactory()
    self.audioCaptureSession = captureSessionFactory()
    self.captureDeviceInputFactory = captureDeviceInputFactory
    self.initialCameraName = initialCameraName
    self.orientation = UIDevice.current.orientation
    self.deviceOrientationProvider = FLTDefaultDeviceOrientationProvider()

    self.videoDimensionsForFormat = { format in
      return CMVideoFormatDescriptionGetDimensions(format.formatDescription)
    }

    self.assetWriterFactory = { url, fileType, error in
      return FLTDefaultAssetWriter(url: url, fileType: fileType, error: &error)
    }

    self.inputPixelBufferAdaptorFactory = { assetWriterInput, sourcePixelBufferAttributes in
      let adaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: assetWriterInput.input,
        sourcePixelBufferAttributes: sourcePixelBufferAttributes
      )
      return FLTDefaultAssetWriterInputPixelBufferAdaptor(adaptor: adaptor)
    }
  }
}
