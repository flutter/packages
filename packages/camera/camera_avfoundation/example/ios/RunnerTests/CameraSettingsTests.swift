// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

private let testResolutionPreset = FCPPlatformResolutionPreset.medium
private let testFramesPerSecond = 15
private let testVideoBitrate = 200000
private let testAudioBitrate = 32000
private let testEnableAudio = true

private final class TestMediaSettingsAVWrapper: FLTCamMediaSettingsAVWrapper {
  let lockExpectation: XCTestExpectation
  let unlockExpectation: XCTestExpectation
  let minFrameDurationExpectation: XCTestExpectation
  let maxFrameDurationExpectation: XCTestExpectation
  let beginConfigurationExpectation: XCTestExpectation
  let commitConfigurationExpectation: XCTestExpectation
  let audioSettingsExpectation: XCTestExpectation
  let videoSettingsExpectation: XCTestExpectation

  init(test: XCTestCase) {
    lockExpectation = test.expectation(description: "lockExpectation")
    unlockExpectation = test.expectation(description: "unlockExpectation")
    minFrameDurationExpectation = test.expectation(description: "minFrameDurationExpectation")
    maxFrameDurationExpectation = test.expectation(description: "maxFrameDurationExpectation")
    beginConfigurationExpectation = test.expectation(description: "beginConfigurationExpectation")
    commitConfigurationExpectation = test.expectation(description: "commitConfigurationExpectation")
    audioSettingsExpectation = test.expectation(description: "audioSettingsExpectation")
    videoSettingsExpectation = test.expectation(description: "videoSettingsExpectation")
  }

  override func lockDevice(_ captureDevice: FLTCaptureDevice) throws {
    lockExpectation.fulfill()
  }

  override func unlockDevice(_ captureDevice: FLTCaptureDevice) {
    unlockExpectation.fulfill()
  }

  override func beginConfiguration(for videoCaptureSession: FLTCaptureSession) {
    beginConfigurationExpectation.fulfill()
  }

  override func commitConfiguration(for videoCaptureSession: FLTCaptureSession) {
    commitConfigurationExpectation.fulfill()
  }

  override func setMinFrameDuration(_ duration: CMTime, on captureDevice: FLTCaptureDevice) {
    // FLTCam allows to set frame rate with 1/10 precision.
    let expectedDuration = CMTimeMake(value: 10, timescale: Int32(testFramesPerSecond * 10))
    if duration == expectedDuration {
      minFrameDurationExpectation.fulfill()
    }
  }

  override func setMaxFrameDuration(_ duration: CMTime, on captureDevice: FLTCaptureDevice) {
    // FLTCam allows to set frame rate with 1/10 precision.
    let expectedDuration = CMTimeMake(value: 10, timescale: Int32(testFramesPerSecond * 10))
    if duration == expectedDuration {
      maxFrameDurationExpectation.fulfill()
    }
  }

  override func assetWriterAudioInput(withOutputSettings outputSettings: [String: Any]?)
    -> FLTAssetWriterInput
  {
    if let bitrate = outputSettings?[AVEncoderBitRateKey] as? Int, bitrate == testAudioBitrate {
      audioSettingsExpectation.fulfill()
    }
    return MockAssetWriterInput()
  }

  override func assetWriterVideoInput(withOutputSettings outputSettings: [String: Any]?)
    -> FLTAssetWriterInput
  {
    if let compressionProperties = outputSettings?[AVVideoCompressionPropertiesKey]
      as? [String: Any],
      let bitrate = compressionProperties[AVVideoAverageBitRateKey] as? Int,
      let frameRate = compressionProperties[AVVideoExpectedSourceFrameRateKey] as? Int,
      bitrate == testVideoBitrate, frameRate == testFramesPerSecond
    {
      videoSettingsExpectation.fulfill()
    }

    // AVAssetWriterInput needs these three keys, otherwise it throws.
    var outputSettingsWithRequiredKeys = outputSettings ?? [:]
    outputSettingsWithRequiredKeys[AVVideoCodecKey] = AVVideoCodecType.h264
    outputSettingsWithRequiredKeys[AVVideoWidthKey] = 1280
    outputSettingsWithRequiredKeys[AVVideoHeightKey] = 720

    return MockAssetWriterInput()
  }

  override func addInput(_ writerInput: FLTAssetWriterInput, to writer: FLTAssetWriter) {
    // No-op.
  }

  override func recommendedVideoSettingsForAssetWriter(
    withFileType fileType: AVFileType, for output: AVCaptureVideoDataOutput
  ) -> [String: Any]? {
    return [:]
  }

}

final class CameraSettingsTests: XCTestCase {
  func testSettings_shouldPassConfigurationToCameraDeviceAndWriter() {
    let settings = FCPPlatformMediaSettings.make(
      with: testResolutionPreset,
      framesPerSecond: NSNumber(value: testFramesPerSecond),
      videoBitrate: NSNumber(value: testVideoBitrate),
      audioBitrate: NSNumber(value: testAudioBitrate),
      enableAudio: testEnableAudio
    )
    let injectedWrapper = TestMediaSettingsAVWrapper(test: self)

    let configuration = FLTCreateTestCameraConfiguration()
    configuration.mediaSettingsWrapper = injectedWrapper
    configuration.mediaSettings = settings
    let camera = FLTCreateCamWithConfiguration(configuration)

    // Expect FPS configuration is passed to camera device.
    wait(
      for: [
        injectedWrapper.lockExpectation,
        injectedWrapper.beginConfigurationExpectation,
        injectedWrapper.minFrameDurationExpectation,
        injectedWrapper.maxFrameDurationExpectation,
        injectedWrapper.commitConfigurationExpectation,
        injectedWrapper.unlockExpectation,
      ], timeout: 1, enforceOrder: true)

    camera.startVideoRecording(
      completion: { error in
        // No-op.
      }, messengerForStreaming: nil)

    wait(
      for: [
        injectedWrapper.audioSettingsExpectation,
        injectedWrapper.videoSettingsExpectation,
      ], timeout: 1)
  }

  func testSettings_ShouldBeSupportedByMethodCall() {
    let mockDevice = MockCaptureDevice()
    let mockSession = MockCaptureSession()
    mockSession.canSetSessionPreset = true
    let camera = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      deviceFactory: { _ in mockDevice },
      captureSessionFactory: { mockSession },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory()
    )

    let expectation = self.expectation(description: "Result finished")
    let mediaSettings = FCPPlatformMediaSettings.make(
      with: testResolutionPreset,
      framesPerSecond: NSNumber(value: testFramesPerSecond),
      videoBitrate: NSNumber(value: testVideoBitrate),
      audioBitrate: NSNumber(value: testAudioBitrate),
      enableAudio: testEnableAudio
    )
    var resultValue: NSNumber?
    camera.createCameraOnSessionQueue(
      withName: "acamera",
      settings: mediaSettings
    ) { result, error in
      XCTAssertNil(error)
      resultValue = result
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
    XCTAssertNotNil(resultValue)
  }

  func testSettings_ShouldSelectFormatWhichSupports60FPS() {
    let settings = FCPPlatformMediaSettings.make(
      with: testResolutionPreset,
      framesPerSecond: NSNumber(value: 60),
      videoBitrate: NSNumber(value: testVideoBitrate),
      audioBitrate: NSNumber(value: testAudioBitrate),
      enableAudio: testEnableAudio
    )

    let configuration = FLTCreateTestCameraConfiguration()
    configuration.mediaSettings = settings
    let camera = FLTCreateCamWithConfiguration(configuration)

    let range = camera.captureDevice.activeFormat.videoSupportedFrameRateRanges[0]
    XCTAssertLessThanOrEqual(range.minFrameRate, 60)
    XCTAssertGreaterThanOrEqual(range.maxFrameRate, 60)
  }
}
