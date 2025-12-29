// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

private let testResolutionPreset = FCPPlatformResolutionPreset.medium
private let testFramesPerSecond = 15
private let testVideoBitrate = 200000
private let testAudioBitrate = 32000

private final class TestMediaSettingsAVWrapper: FLTCamMediaSettingsAVWrapper {
  let lockExpectation: XCTestExpectation
  let unlockExpectation: XCTestExpectation
  let minFrameDurationExpectation: XCTestExpectation
  let maxFrameDurationExpectation: XCTestExpectation
  let beginConfigurationExpectation: XCTestExpectation
  let commitConfigurationExpectation: XCTestExpectation
  let audioSettingsExpectation: XCTestExpectation
  let videoSettingsExpectation: XCTestExpectation

  init(test: XCTestCase, expectAudio: Bool) {
    lockExpectation = test.expectation(description: "lockExpectation")
    unlockExpectation = test.expectation(description: "unlockExpectation")
    minFrameDurationExpectation = test.expectation(description: "minFrameDurationExpectation")
    maxFrameDurationExpectation = test.expectation(description: "maxFrameDurationExpectation")
    beginConfigurationExpectation = test.expectation(description: "beginConfigurationExpectation")
    commitConfigurationExpectation = test.expectation(description: "commitConfigurationExpectation")
    audioSettingsExpectation = test.expectation(description: "audioSettingsExpectation")
    audioSettingsExpectation.isInverted = !expectAudio
    videoSettingsExpectation = test.expectation(description: "videoSettingsExpectation")
  }

  override func lockDevice(_ captureDevice: CaptureDevice) throws {
    lockExpectation.fulfill()
  }

  override func unlockDevice(_ captureDevice: CaptureDevice) {
    unlockExpectation.fulfill()
  }

  override func beginConfiguration(for videoCaptureSession: CaptureSession) {
    beginConfigurationExpectation.fulfill()
  }

  override func commitConfiguration(for videoCaptureSession: CaptureSession) {
    commitConfigurationExpectation.fulfill()
  }

  override func setMinFrameDuration(_ duration: CMTime, on captureDevice: CaptureDevice) {
    // FLTCam allows to set frame rate with 1/10 precision.
    let expectedDuration = CMTimeMake(value: 10, timescale: Int32(testFramesPerSecond * 10))
    if duration == expectedDuration {
      minFrameDurationExpectation.fulfill()
    }
  }

  override func setMaxFrameDuration(_ duration: CMTime, on captureDevice: CaptureDevice) {
    // FLTCam allows to set frame rate with 1/10 precision.
    let expectedDuration = CMTimeMake(value: 10, timescale: Int32(testFramesPerSecond * 10))
    if duration == expectedDuration {
      maxFrameDurationExpectation.fulfill()
    }
  }

  override func assetWriterAudioInput(withOutputSettings outputSettings: [String: Any]?)
    -> AssetWriterInput
  {
    if let bitrate = outputSettings?[AVEncoderBitRateKey] as? Int, bitrate == testAudioBitrate {
      audioSettingsExpectation.fulfill()
    }
    return MockAssetWriterInput()
  }

  override func assetWriterVideoInput(withOutputSettings outputSettings: [String: Any]?)
    -> AssetWriterInput
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

  override func addInput(_ writerInput: AssetWriterInput, to writer: AssetWriter) {
    // No-op.
  }

  override func recommendedVideoSettingsForAssetWriter(
    withFileType fileType: AVFileType, for output: CaptureVideoDataOutput
  ) -> [String: Any]? {
    return [:]
  }
}

final class CameraSettingsTests: XCTestCase {
  func testSettings_shouldPassConfigurationToCameraDeviceAndWriter() {
    let enableAudio: Bool = true
    let settings = FCPPlatformMediaSettings.make(
      with: testResolutionPreset,
      framesPerSecond: NSNumber(value: testFramesPerSecond),
      videoBitrate: NSNumber(value: testVideoBitrate),
      audioBitrate: NSNumber(value: testAudioBitrate),
      enableAudio: enableAudio
    )
    let injectedWrapper = TestMediaSettingsAVWrapper(test: self, expectAudio: enableAudio)

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.mediaSettingsWrapper = injectedWrapper
    configuration.mediaSettings = settings
    let camera = CameraTestUtils.createTestCamera(configuration)

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
    mockSession.canSetSessionPresetStub = { _ in true }
    let camera = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      permissionManager: MockCameraPermissionManager(),
      deviceFactory: { _ in mockDevice },
      captureSessionFactory: { mockSession },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory(),
      captureSessionQueue: DispatchQueue(label: "io.flutter.camera.captureSessionQueue")
    )

    let expectation = self.expectation(description: "Result finished")
    let mediaSettings = FCPPlatformMediaSettings.make(
      with: testResolutionPreset,
      framesPerSecond: NSNumber(value: testFramesPerSecond),
      videoBitrate: NSNumber(value: testVideoBitrate),
      audioBitrate: NSNumber(value: testAudioBitrate),
      enableAudio: false
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
      enableAudio: false
    )

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.mediaSettings = settings
    let camera = CameraTestUtils.createTestCamera(configuration)

    let range = camera.captureDevice.flutterActiveFormat.flutterVideoSupportedFrameRateRanges[0]
    XCTAssertLessThanOrEqual(range.minFrameRate, 60)
    XCTAssertGreaterThanOrEqual(range.maxFrameRate, 60)
  }
  func test_setUpCaptureSessionForAudioIfNeeded_skipsAudioSession_whenAudioDisabled() {
    let settings = FCPPlatformMediaSettings.make(
      with: testResolutionPreset,
      framesPerSecond: NSNumber(value: testFramesPerSecond),
      videoBitrate: NSNumber(value: testVideoBitrate),
      audioBitrate: NSNumber(value: testAudioBitrate),
      enableAudio: false
    )

    let wrapper = TestMediaSettingsAVWrapper(test: self, expectAudio: false)
    let mockAudioSession = MockCaptureSession()

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.mediaSettingsWrapper = wrapper
    configuration.mediaSettings = settings
    configuration.audioCaptureSession = mockAudioSession
    let camera = CameraTestUtils.createTestCamera(configuration)

    wait(
      for: [
        wrapper.lockExpectation,
        wrapper.beginConfigurationExpectation,
        wrapper.minFrameDurationExpectation,
        wrapper.maxFrameDurationExpectation,
        wrapper.commitConfigurationExpectation,
        wrapper.unlockExpectation,
      ],
      timeout: 1,
      enforceOrder: true
    )

    camera.startVideoRecording(completion: { _ in }, messengerForStreaming: nil)

    wait(
      for: [
        wrapper.audioSettingsExpectation,
        wrapper.videoSettingsExpectation,
      ],
      timeout: 1
    )

    XCTAssertEqual(
      mockAudioSession.addedAudioOutputCount, 0,
      "Audio session should not receive AVCaptureAudioDataOutput when enableAudio is false"
    )
  }

  func test_setUpCaptureSessionForAudioIfNeeded_addsAudioSession_whenAudioEnabled() {
    let settings = FCPPlatformMediaSettings.make(
      with: testResolutionPreset,
      framesPerSecond: NSNumber(value: testFramesPerSecond),
      videoBitrate: NSNumber(value: testVideoBitrate),
      audioBitrate: NSNumber(value: testAudioBitrate),
      enableAudio: true
    )

    let wrapper = TestMediaSettingsAVWrapper(test: self, expectAudio: true)
    let mockAudioSession = MockCaptureSession()

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.mediaSettingsWrapper = wrapper
    configuration.mediaSettings = settings
    configuration.audioCaptureSession = mockAudioSession
    let camera = CameraTestUtils.createTestCamera(configuration)

    wait(
      for: [
        wrapper.lockExpectation,
        wrapper.beginConfigurationExpectation,
        wrapper.minFrameDurationExpectation,
        wrapper.maxFrameDurationExpectation,
        wrapper.commitConfigurationExpectation,
        wrapper.unlockExpectation,
      ],
      timeout: 1,
      enforceOrder: true
    )

    camera.startVideoRecording(completion: { _ in }, messengerForStreaming: nil)

    wait(
      for: [
        wrapper.audioSettingsExpectation,
        wrapper.videoSettingsExpectation,
      ],
      timeout: 1
    )

    XCTAssertGreaterThan(
      mockAudioSession.addedAudioOutputCount, 0,
      "Audio session should receive AVCaptureAudioDataOutput when enableAudio is true"
    )
  }
}
