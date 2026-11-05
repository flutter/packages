// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

private class FakeMediaSettingsAVWrapper: FLTCamMediaSettingsAVWrapper {
  let inputMock: MockAssetWriterInput

  init(inputMock: MockAssetWriterInput) {
    self.inputMock = inputMock
  }

  override func lockDevice(_ captureDevice: CaptureDevice) throws {
    // No-op.
  }

  override func unlockDevice(_ captureDevice: CaptureDevice) {
    // No-op.
  }

  override func beginConfiguration(for videoCaptureSession: CaptureSession) {
    // No-op.
  }

  override func commitConfiguration(for videoCaptureSession: CaptureSession) {
    // No-op.
  }

  override func setMinFrameDuration(_ duration: CMTime, on captureDevice: CaptureDevice) {
    // No-op.
  }

  override func setMaxFrameDuration(_ duration: CMTime, on captureDevice: CaptureDevice) {
    // No-op.
  }

  override func assetWriterAudioInput(withOutputSettings outputSettings: [String: Any]?)
    -> AssetWriterInput
  {
    return inputMock
  }

  override func assetWriterVideoInput(withOutputSettings outputSettings: [String: Any]?)
    -> AssetWriterInput
  {
    return inputMock
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

/// Includes test cases related to sample buffer handling for Camera class.
final class CameraSampleBufferTests: XCTestCase {
  private func createCamera() -> (
    DefaultCamera,
    MockAssetWriter,
    MockAssetWriterInputPixelBufferAdaptor,
    MockAssetWriterInput
  ) {
    let assetWriter = MockAssetWriter()
    let adaptor = MockAssetWriterInputPixelBufferAdaptor()
    let input = MockAssetWriterInput()

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.mediaSettings = PlatformMediaSettings(
      resolutionPreset: .medium,
      framesPerSecond: nil,
      videoBitrate: nil,
      audioBitrate: nil,
      enableAudio: true)
    configuration.mediaSettingsWrapper = FakeMediaSettingsAVWrapper(inputMock: input)

    configuration.assetWriterFactory = { url, fileType in
      return assetWriter
    }
    configuration.inputPixelBufferAdaptorFactory = { input, settings in
      return adaptor
    }

    return (
      CameraTestUtils.createTestCamera(configuration),
      assetWriter,
      adaptor,
      input
    )
  }

  func testSampleBufferCallbackQueueMustBeCaptureSessionQueue() {
    let captureSessionQueue = DispatchQueue(label: "testing")
    let camera = CameraTestUtils.createCameraWithCaptureSessionQueue(captureSessionQueue)
    XCTAssertEqual(
      captureSessionQueue, camera.captureVideoOutput.avOutput.sampleBufferCallbackQueue,
      "Sample buffer callback queue must be the capture session queue.")
  }

  func testCopyPixelBuffer() {
    let (camera, _, _, _) = createCamera()
    let capturedSampleBuffer = CameraTestUtils.createTestSampleBuffer()
    let capturedPixelBuffer = CMSampleBufferGetImageBuffer(capturedSampleBuffer)!
    let testConnection = CameraTestUtils.createTestConnection(camera.captureVideoOutput.avOutput)

    // Mimic sample buffer callback when captured a new video sample.
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: capturedSampleBuffer,
      from: testConnection)
    let deliveredPixelBuffer = camera.copyPixelBuffer()?.takeRetainedValue()
    XCTAssertEqual(
      deliveredPixelBuffer, capturedPixelBuffer,
      "Camera must deliver the latest captured pixel buffer to copyPixelBuffer API.")
  }

  func testDidOutputSampleBuffer_mustNotChangeSampleBufferRetainCountAfterPauseResumeRecording() {
    let (camera, _, _, _) = createCamera()
    let sampleBuffer = CameraTestUtils.createTestSampleBuffer()
    let testConnection = CameraTestUtils.createTestConnection(camera.captureVideoOutput.avOutput)

    let initialRetainCount = CFGetRetainCount(sampleBuffer)

    // Pause then resume the recording.
    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)
    camera.pauseVideoRecording()
    camera.resumeVideoRecording()

    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: sampleBuffer,
      from: testConnection)

    let finalRetainCount = CFGetRetainCount(sampleBuffer)
    XCTAssertEqual(
      finalRetainCount, initialRetainCount,
      "didOutputSampleBuffer must not change the sample buffer retain count after pause resume recording."
    )
  }

  func testDidOutputSampleBufferIgnoreAudioSamplesBeforeVideoSamples() {
    let (camera, writerMock, adaptorMock, inputMock) = createCamera()
    var status = AVAssetWriter.Status.unknown
    writerMock.startWritingStub = {
      status = .writing
      return true
    }
    writerMock.statusStub = {
      return status
    }

    let videoSample = CameraTestUtils.createTestSampleBuffer()
    let testVideoConnection = CameraTestUtils.createTestConnection(
      camera.captureVideoOutput.avOutput)

    let audioSample = CameraTestUtils.createTestAudioSampleBuffer()
    let testAudioOutput = CameraTestUtils.createTestAudioOutput()
    let testAudioConnection = CameraTestUtils.createTestConnection(testAudioOutput)

    var writtenSamples: [String] = []
    adaptorMock.appendStub = { buffer, time in
      writtenSamples.append("video")
      return true
    }
    inputMock.isReadyForMoreMediaData = true
    inputMock.appendStub = { buffer in
      writtenSamples.append("audio")
      return true
    }

    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)
    camera.captureOutput(testAudioOutput, didOutput: audioSample, from: testAudioConnection)
    camera.captureOutput(testAudioOutput, didOutput: audioSample, from: testAudioConnection)
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: videoSample,
      from: testVideoConnection)
    camera.captureOutput(testAudioOutput, didOutput: audioSample, from: testAudioConnection)

    let expectedSamples = ["video", "audio"]
    XCTAssertEqual(writtenSamples, expectedSamples, "First appended sample must be video.")
  }

  func testDidOutputSampleBufferSampleTimesMustBeNumericAfterPauseResume() {
    let (camera, writerMock, adaptorMock, inputMock) = createCamera()

    let videoSample = CameraTestUtils.createTestSampleBuffer()
    let testVideoConnection = CameraTestUtils.createTestConnection(
      camera.captureVideoOutput.avOutput)

    let audioSample = CameraTestUtils.createTestAudioSampleBuffer()
    let testAudioOutput = CameraTestUtils.createTestAudioOutput()
    let testAudioConnection = CameraTestUtils.createTestConnection(testAudioOutput)

    var status = AVAssetWriter.Status.unknown
    writerMock.startWritingStub = {
      status = .writing
      return true
    }
    writerMock.statusStub = {
      return status
    }

    var videoAppended = false
    adaptorMock.appendStub = { buffer, time in
      XCTAssert(CMTIME_IS_NUMERIC(time))
      videoAppended = true
      return true
    }

    var audioAppended = false
    inputMock.isReadyForMoreMediaData = true
    inputMock.appendStub = { buffer in
      let sampleTime = CMSampleBufferGetPresentationTimeStamp(buffer)
      XCTAssert(CMTIME_IS_NUMERIC(sampleTime))
      audioAppended = true
      return true
    }

    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)
    camera.pauseVideoRecording()
    camera.resumeVideoRecording()
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: videoSample,
      from: testVideoConnection)
    camera.captureOutput(testAudioOutput, didOutput: audioSample, from: testAudioConnection)
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: videoSample,
      from: testVideoConnection)
    camera.captureOutput(testAudioOutput, didOutput: audioSample, from: testAudioConnection)

    XCTAssert(videoAppended && audioAppended, "Video or audio was not appended.")
  }

  func testDidOutputSampleBufferMustNotAppendSampleWhenReadyForMoreMediaDataIsFalse() {
    let (camera, _, adaptorMock, inputMock) = createCamera()

    let videoSample = CameraTestUtils.createTestSampleBuffer()
    let testVideoConnection = CameraTestUtils.createTestConnection(
      camera.captureVideoOutput.avOutput)

    var sampleAppended = false
    adaptorMock.appendStub = { buffer, time in
      sampleAppended = true
      return true
    }

    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)

    inputMock.isReadyForMoreMediaData = true
    sampleAppended = false
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: videoSample,
      from: testVideoConnection)
    XCTAssertTrue(sampleAppended, "Sample was not appended.")

    inputMock.isReadyForMoreMediaData = false
    sampleAppended = false
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: videoSample,
      from: testVideoConnection)
    XCTAssertFalse(sampleAppended, "Sample cannot be appended when readyForMoreMediaData is NO.")
  }

  func testStopVideoRecordingWithCompletionMustCallCompletion() {
    let (camera, writerMock, _, _) = createCamera()

    var status = AVAssetWriter.Status.unknown
    writerMock.startWritingStub = {
      status = .writing
      return true
    }
    writerMock.statusStub = {
      return status
    }
    writerMock.finishWritingStub = { handler in
      XCTAssert(
        writerMock.status == .writing,
        "Cannot call finishWritingWithCompletionHandler when status is not AVAssetWriter.Status.writing."
      )
      handler()
    }

    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)
    var completionCalled = false
    camera.stopVideoRecording(completion: { result in
      completionCalled = true
    })

    XCTAssert(completionCalled, "Completion was not called.")
  }

  func testStartWritingShouldNotBeCalledBetweenSampleCreationAndAppending() {
    let (camera, writerMock, adaptorMock, inputMock) = createCamera()

    let videoSample = CameraTestUtils.createTestSampleBuffer()
    let testVideoConnection = CameraTestUtils.createTestConnection(
      camera.captureVideoOutput.avOutput)

    var startWritingCalled = false
    writerMock.startWritingStub = {
      startWritingCalled = true
      return true

    }

    var videoAppended = false
    adaptorMock.appendStub = { buffer, time in
      videoAppended = true
      return true
    }

    inputMock.isReadyForMoreMediaData = true

    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)

    let startWritingCalledBefore = startWritingCalled
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: videoSample,
      from: testVideoConnection)
    XCTAssert(
      (startWritingCalledBefore && videoAppended) || (startWritingCalled && !videoAppended),
      "The startWriting was called between sample creation and appending.")

    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: videoSample,
      from: testVideoConnection)
    XCTAssert(videoAppended, "Video was not appended.")
  }

  func testStartVideoRecordingWithCompletionShouldNotDisableMixWithOthers() {
    let cam = CameraTestUtils.createCameraWithCaptureSessionQueue(DispatchQueue(label: "testing"))

    try? AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    cam.startVideoRecording(completion: { error in }, messengerForStreaming: nil)
    XCTAssert(
      AVAudioSession.sharedInstance().categoryOptions.contains(.mixWithOthers),
      "Flag MixWithOthers was removed.")
    XCTAssert(
      AVAudioSession.sharedInstance().category == .playAndRecord,
      "Category should be PlayAndRecord.")
  }

  func testDidOutputSampleBufferMustUseSingleOffsetForVideoAndAudio() {
    let (camera, writerMock, adaptorMock, inputMock) = createCamera()

    let testVideoConnection = CameraTestUtils.createTestConnection(
      camera.captureVideoOutput.avOutput)
    let testAudioOutput = CameraTestUtils.createTestAudioOutput()
    let testAudioConnection = CameraTestUtils.createTestConnection(testAudioOutput)

    var status = AVAssetWriter.Status.unknown
    writerMock.startWritingStub = {
      status = .writing
      return true
    }
    writerMock.statusStub = {
      return status
    }

    var appendedTime = CMTime.invalid

    adaptorMock.appendStub = { buffer, time in
      appendedTime = time
      return true
    }

    inputMock.isReadyForMoreMediaData = true
    inputMock.appendStub = { buffer in
      appendedTime = CMSampleBufferGetPresentationTimeStamp(buffer)
      return true
    }

    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)

    let appendVideoSample = { (time: Int64) in
      camera.captureOutput(
        camera.captureVideoOutput.avOutput,
        didOutput: CameraTestUtils.createTestSampleBuffer(
          timestamp: CMTimeMake(value: time, timescale: 1),
          duration: .invalid),
        from: testVideoConnection)
    }

    let appendAudioSample = { (time: Int64, duration: Int64) in
      camera.captureOutput(
        testAudioOutput,
        didOutput: CameraTestUtils.createTestAudioSampleBuffer(
          timestamp: CMTimeMake(value: time, timescale: 1),
          duration: CMTimeMake(value: duration, timescale: 1)),
        from: testAudioConnection)
    }

    appendedTime = .invalid
    camera.pauseVideoRecording()
    camera.resumeVideoRecording()
    appendVideoSample(1)
    XCTAssertEqual(appendedTime, CMTimeMake(value: 1, timescale: 1))

    appendedTime = .invalid
    camera.pauseVideoRecording()
    camera.resumeVideoRecording()
    appendVideoSample(11)
    XCTAssertEqual(appendedTime, .invalid)
    appendVideoSample(12)
    XCTAssertEqual(appendedTime, CMTimeMake(value: 2, timescale: 1))

    appendedTime = .invalid
    camera.pauseVideoRecording()
    camera.resumeVideoRecording()
    appendAudioSample(20, 2)
    XCTAssertEqual(appendedTime, .invalid)
    appendVideoSample(23)
    XCTAssertEqual(appendedTime, CMTimeMake(value: 3, timescale: 1))

    appendedTime = .invalid
    camera.pauseVideoRecording()
    camera.resumeVideoRecording()
    appendVideoSample(28)
    XCTAssertEqual(appendedTime, .invalid)
    appendAudioSample(30, 2)
    XCTAssertEqual(appendedTime, .invalid)
    appendVideoSample(33)
    XCTAssertEqual(appendedTime, .invalid)
    appendAudioSample(32, 2)
    XCTAssertEqual(appendedTime, CMTimeMake(value: 2, timescale: 1))
  }

  func testDidOutputSampleBufferMustConnectVideoAfterSessionInterruption() {
    let (camera, writerMock, adaptorMock, inputMock) = createCamera()

    let testVideoConnection = CameraTestUtils.createTestConnection(
      camera.captureVideoOutput.avOutput)
    let testAudioOutput = CameraTestUtils.createTestAudioOutput()
    let testAudioConnection = CameraTestUtils.createTestConnection(testAudioOutput)

    var status = AVAssetWriter.Status.unknown
    writerMock.startWritingStub = {
      status = .writing
      return true
    }
    writerMock.statusStub = {
      return status
    }

    var appendedTime = CMTime.invalid

    adaptorMock.appendStub = { buffer, time in
      appendedTime = time
      return true
    }

    inputMock.isReadyForMoreMediaData = true
    inputMock.appendStub = { buffer in
      appendedTime = CMSampleBufferGetPresentationTimeStamp(buffer)
      return true
    }

    camera.startVideoRecording(completion: { error in }, messengerForStreaming: nil)

    let appendVideoSample = { (time: Int64) in
      camera.captureOutput(
        camera.captureVideoOutput.avOutput,
        didOutput: CameraTestUtils.createTestSampleBuffer(
          timestamp: CMTimeMake(value: time, timescale: 1),
          duration: .invalid),
        from: testVideoConnection)
    }

    let appendAudioSample = { (time: Int64, duration: Int64) in
      camera.captureOutput(
        testAudioOutput,
        didOutput: CameraTestUtils.createTestAudioSampleBuffer(
          timestamp: CMTimeMake(value: time, timescale: 1),
          duration: CMTimeMake(value: duration, timescale: 1)),
        from: testAudioConnection)
    }

    appendVideoSample(1)
    appendAudioSample(1, 1)

    NotificationCenter.default.post(
      name: AVCaptureSession.wasInterruptedNotification,
      object: camera.audioCaptureSession)

    appendedTime = .invalid
    appendAudioSample(11, 1)
    XCTAssertEqual(appendedTime, .invalid)
    appendVideoSample(12)
    XCTAssertEqual(appendedTime, CMTimeMake(value: 2, timescale: 1))
    appendedTime = .invalid
    appendAudioSample(12, 1)
    XCTAssertEqual(appendedTime, CMTimeMake(value: 2, timescale: 1))
  }

  func testStartVideoRecordingReportsErrorWhenStartWritingFails() {
    let (camera, writerMock, _, _) = createCamera()

    // Configure the mock to return false for startWriting
    writerMock.startWritingStub = {
      return false
    }

    // Configure a mock error
    let mockError = NSError(
      domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Mock write error"])
    writerMock.error = mockError

    let expectation = self.expectation(description: "Completion handler called with error")

    camera.startVideoRecording(
      completion: { result in
        switch result {
        case .failure(let error as PigeonError):
          XCTAssertEqual(error.code, "IOError")
          XCTAssertEqual(error.message, "AVAssetWriter failed to start writing")
          XCTAssertEqual(error.details as? String, "Mock write error")
          XCTAssertFalse(camera.isRecording)
          expectation.fulfill()
        default:
          XCTFail("Expected PigeonError")
        }

      }, messengerForStreaming: nil)

    waitForExpectations(timeout: 1.0, handler: nil)
  }

  func testSetDescriptionWhileRecording_reconnectsBothOutputsAndUpdatesMaxPhotoDimensions()
    throws
  {
    guard #available(iOS 16.0, *) else {
      throw XCTSkip("maxPhotoDimensions requires iOS 16.")
    }

    let inputMock = MockAssetWriterInput()
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.mediaSettingsWrapper = FakeMediaSettingsAVWrapper(inputMock: inputMock)

    let videoSessionMock = MockCaptureSession()
    videoSessionMock.canSetSessionPresetStub = { _ in true }
    configuration.videoCaptureSession = videoSessionMock

    let initialDeviceMock = MockCaptureDevice()
    let newFormatMock = MockCaptureDeviceFormat()
    newFormatMock.supportedMaxPhotoDimensions = [
      CMVideoDimensions(width: 1920, height: 1080),
      CMVideoDimensions(width: 4032, height: 3024),
    ]
    let newDeviceMock = MockCaptureDevice()
    newDeviceMock.activeFormatStub = { newFormatMock }

    configuration.videoCaptureDeviceFactory = { name in
      return name == "new_camera" ? newDeviceMock : initialDeviceMock
    }

    let camera = CameraTestUtils.createTestCamera(configuration)
    let mockPhotoOutput = MockCapturePhotoOutput()
    mockPhotoOutput.avOutput = camera.capturePhotoOutput.avOutput
    camera.capturePhotoOutput = mockPhotoOutput

    camera.startVideoRecording(completion: { _ in }, messengerForStreaming: nil)

    let expectation = self.expectation(description: "setDescriptionWhileRecording completed")
    camera.setDescriptionWhileRecording("new_camera") { result in
      let _ = self.assertSuccess(result)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1.0, handler: nil)

    XCTAssertEqual(videoSessionMock.connections.count, 2)
    XCTAssertTrue(
      videoSessionMock.connections.contains(where: {
        $0.output === camera.captureVideoOutput.avOutput
      }))
    XCTAssertTrue(
      videoSessionMock.connections.contains(where: {
        $0.output === mockPhotoOutput.avOutput
      }))
    XCTAssertEqual(mockPhotoOutput.maxPhotoDimensions.width, 4032)
    XCTAssertEqual(mockPhotoOutput.maxPhotoDimensions.height, 3024)
  }

  func testDidOutputSampleBuffer_reportsVideoRecordingDuration() {
    let (camera, _, _, inputMock) = createCamera()
    inputMock.isReadyForMoreMediaData = true
    let messenger = MockFlutterBinaryMessenger()
    var sentChannels: [String] = []
    messenger.sendOnChannelStub = { channel, _, callback in
      sentChannels.append(channel)
      callback?(nil)
    }
    camera.dartAPI = CameraEventApi(binaryMessenger: messenger, messageChannelSuffix: "0")

    let startSample = CameraTestUtils.createTestSampleBuffer(
      timestamp: CMTime(value: 0, timescale: 1000))
    let earlySample = CameraTestUtils.createTestSampleBuffer(
      timestamp: CMTime(value: 50, timescale: 1000))
    let secondSample = CameraTestUtils.createTestSampleBuffer(
      timestamp: CMTime(value: 250, timescale: 1000))
    let testConnection = CameraTestUtils.createTestConnection(camera.captureVideoOutput.avOutput)

    camera.startVideoRecording(completion: { _ in }, messengerForStreaming: nil)

    // First sample establishes start time (duration 0ms) and reports it.
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: startSample,
      from: testConnection)

    // Sample after 50ms (< 100ms threshold) should not report duration.
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: earlySample,
      from: testConnection)

    // Second sample 250ms later reports duration.
    camera.captureOutput(
      camera.captureVideoOutput.avOutput,
      didOutput: secondSample,
      from: testConnection)

    waitForQueueRoundTrip(with: DispatchQueue.main)
    XCTAssertEqual(
      sentChannels,
      [
        "dev.flutter.pigeon.camera_avfoundation.CameraEventApi.videoRecordingDurationChanged.0",
        "dev.flutter.pigeon.camera_avfoundation.CameraEventApi.videoRecordingDurationChanged.0",
      ])
  }
}
