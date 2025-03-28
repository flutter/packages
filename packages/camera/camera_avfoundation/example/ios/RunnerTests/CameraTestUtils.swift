// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Utils for creating default class instances used in tests
enum CameraTestUtils {
  /// This method provides a convenient way to create media settings with minimal configuration.
  /// Audio is enabled by default, while other parameters use platform-specific defaults.
  static func createDefaultMediaSettings(resolutionPreset: FCPPlatformResolutionPreset)
    -> FCPPlatformMediaSettings
  {
    return FCPPlatformMediaSettings.make(
      with: resolutionPreset,
      framesPerSecond: nil,
      videoBitrate: nil,
      audioBitrate: nil,
      enableAudio: true)
  }

  /// Creates a test `FLTCamConfiguration` with a default mock setup.
  static func createTestCameraConfiguration() -> FLTCamConfiguration {
    let captureSessionQueue = DispatchQueue(label: "capture_session_queue")

    let videoSessionMock = MockCaptureSession()
    videoSessionMock.canSetSessionPresetStub = { _ in true }

    let audioSessionMock = MockCaptureSession()
    audioSessionMock.canSetSessionPresetStub = { _ in true }

    let frameRateRangeMock1 = MockFrameRateRange.init(minFrameRate: 3, maxFrameRate: 30)

    let captureDeviceFormatMock1 = MockCaptureDeviceFormat()
    captureDeviceFormatMock1.videoSupportedFrameRateRanges = [frameRateRangeMock1]

    let frameRateRangeMock2 = MockFrameRateRange.init(minFrameRate: 3, maxFrameRate: 60)

    let captureDeviceFormatMock2 = MockCaptureDeviceFormat()
    captureDeviceFormatMock2.videoSupportedFrameRateRanges = [frameRateRangeMock2]

    let captureDeviceMock = MockCaptureDevice()
    captureDeviceMock.formats = [captureDeviceFormatMock1, captureDeviceFormatMock2]

    var currentFormat: FLTCaptureDeviceFormat = captureDeviceFormatMock1

    captureDeviceMock.activeFormatStub = { currentFormat }
    captureDeviceMock.setActiveFormatStub = { format in
      currentFormat = format
    }

    let configuration = FLTCamConfiguration(
      mediaSettings: createDefaultMediaSettings(
        resolutionPreset: FCPPlatformResolutionPreset.medium),
      mediaSettingsWrapper: FLTCamMediaSettingsAVWrapper(),
      captureDeviceFactory: { captureDeviceMock },
      captureSessionFactory: { videoSessionMock },
      captureSessionQueue: captureSessionQueue,
      captureDeviceInputFactory: MockCaptureDeviceInputFactory()
    )

    configuration.videoCaptureSession = videoSessionMock
    configuration.audioCaptureSession = audioSessionMock
    configuration.orientation = .portrait

    configuration.assetWriterFactory = { _, _, _ in MockAssetWriter() }

    configuration.inputPixelBufferAdaptorFactory = { _, _ in
      MockAssetWriterInputPixelBufferAdaptor()
    }

    return configuration
  }

  static func createCameraWithCaptureSessionQueue(_ captureSessionQueue: DispatchQueue) -> FLTCam {
    let configuration = createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue
    return FLTCam(configuration: configuration, error: nil)
  }

  /// Creates a test sample buffer.
  /// @return a test sample buffer.
  static func createTestSampleBuffer() -> CMSampleBuffer {
    var pixelBuffer: CVPixelBuffer?
    CVPixelBufferCreate(kCFAllocatorDefault, 100, 100, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)

    var formatDescription: CMFormatDescription?
    CMVideoFormatDescriptionCreateForImageBuffer(
      allocator: kCFAllocatorDefault,
      imageBuffer: pixelBuffer!,
      formatDescriptionOut: &formatDescription)

    var timingInfo = CMSampleTimingInfo(
      duration: CMTimeMake(value: 1, timescale: 44100),
      presentationTimeStamp: CMTime.zero,
      decodeTimeStamp: CMTime.invalid)

    var sampleBuffer: CMSampleBuffer?
    CMSampleBufferCreateReadyWithImageBuffer(
      allocator: kCFAllocatorDefault,
      imageBuffer: pixelBuffer!,
      formatDescription: formatDescription!,
      sampleTiming: &timingInfo,
      sampleBufferOut: &sampleBuffer)

    return sampleBuffer!
  }

  /// Creates a test audio sample buffer.
  /// @return a test audio sample buffer.
  static func createTestAudioSampleBuffer() -> CMSampleBuffer? {
    var blockBuffer: CMBlockBuffer?
    CMBlockBufferCreateWithMemoryBlock(
      allocator: kCFAllocatorDefault,
      memoryBlock: nil,
      blockLength: 100,
      blockAllocator: kCFAllocatorDefault,
      customBlockSource: nil,
      offsetToData: 0,
      dataLength: 100,
      flags: kCMBlockBufferAssureMemoryNowFlag,
      blockBufferOut: &blockBuffer)

    guard let blockBuffer = blockBuffer else { return nil }

    var formatDescription: CMFormatDescription?
    var basicDescription = AudioStreamBasicDescription(
      mSampleRate: 44100,
      mFormatID: kAudioFormatLinearPCM,
      mFormatFlags: 0,
      mBytesPerPacket: 1,
      mFramesPerPacket: 1,
      mBytesPerFrame: 1,
      mChannelsPerFrame: 1,
      mBitsPerChannel: 8,
      mReserved: 0)

    CMAudioFormatDescriptionCreate(
      allocator: kCFAllocatorDefault,
      asbd: &basicDescription,
      layoutSize: 0,
      layout: nil,
      magicCookieSize: 0,
      magicCookie: nil,
      extensions: nil,
      formatDescriptionOut: &formatDescription)

    var sampleBuffer: CMSampleBuffer?
    CMAudioSampleBufferCreateReadyWithPacketDescriptions(
      allocator: kCFAllocatorDefault,
      dataBuffer: blockBuffer,
      formatDescription: formatDescription!,
      sampleCount: 1,
      presentationTimeStamp: .zero,
      packetDescriptions: nil,
      sampleBufferOut: &sampleBuffer)

    return sampleBuffer
  }
}
