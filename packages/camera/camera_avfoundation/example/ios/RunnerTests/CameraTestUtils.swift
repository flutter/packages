// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

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
      captureDeviceFactory: { _ in captureDeviceMock },
      audioCaptureDeviceFactory: { MockCaptureDevice() },
      captureSessionFactory: { videoSessionMock },
      captureSessionQueue: captureSessionQueue,
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      initialCameraName: "camera_name"
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

  static func createTestCamera(_ configuration: FLTCamConfiguration) -> DefaultCamera {
    return DefaultCamera(configuration: configuration, error: nil)
  }

  static func createTestCamera() -> DefaultCamera {
    return createTestCamera(createTestCameraConfiguration())
  }

  static func createCameraWithCaptureSessionQueue(_ captureSessionQueue: DispatchQueue)
    -> DefaultCamera
  {
    let configuration = createTestCameraConfiguration()
    configuration.captureSessionQueue = captureSessionQueue
    return createTestCamera(configuration)
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
  static func createTestAudioSampleBuffer() -> CMSampleBuffer {
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
      dataBuffer: blockBuffer!,
      formatDescription: formatDescription!,
      sampleCount: 1,
      presentationTimeStamp: .zero,
      packetDescriptions: nil,
      sampleBufferOut: &sampleBuffer)

    return sampleBuffer!
  }

  static func createTestAudioOutput() -> AVCaptureOutput {
    return AVCaptureAudioDataOutput()
  }

  static func createTestConnection(_ output: AVCaptureOutput) -> AVCaptureConnection {
    return AVCaptureConnection(inputPorts: [], output: output)
  }
}

extension XCTestCase {
  /// Wait until a round trip of a given `DispatchQueue` is complete. This allows for testing
  /// side-effects of async functions that do not provide any notification of completion.
  func waitForQueueRoundTrip(with queue: DispatchQueue) {
    let expectation = expectation(description: "Queue flush")

    queue.async {
      if queue == DispatchQueue.main {
        expectation.fulfill()
      } else {
        DispatchQueue.main.async {
          expectation.fulfill()
        }
      }
    }

    wait(for: [expectation], timeout: 1)
  }
}
