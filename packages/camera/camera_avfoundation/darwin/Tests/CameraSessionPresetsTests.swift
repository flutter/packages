// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

/// Includes test cases related to resolution presets setting operations for Camera class.
final class CameraSessionPresetsTests: XCTestCase {
  func testResolutionPresetWithBestFormat_mustUpdateCaptureSessionPreset() {
    let expectedPreset = AVCaptureSession.Preset.inputPriority
    let presetExpectation = expectation(description: "Expected preset set")
    let lockForConfigurationExpectation = expectation(
      description: "Expected lockForConfiguration called")

    let videoSessionMock = MockCaptureSession()
    videoSessionMock.canSetSessionPresetStub = { _ in true }
    videoSessionMock.setSessionPresetStub = { preset in
      if preset == expectedPreset {
        presetExpectation.fulfill()
      }
    }
    let captureFormatMock = MockCaptureDeviceFormat()
    let captureDeviceMock = MockCaptureDevice()
    captureDeviceMock.flutterFormats = [captureFormatMock]
    let currentFormat: CaptureDeviceFormat = captureFormatMock
    captureDeviceMock.activeFormatStub = {
      return currentFormat
    }
    captureDeviceMock.lockForConfigurationStub = {
      lockForConfigurationExpectation.fulfill()
    }

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureDeviceFactory = { _ in captureDeviceMock }
    configuration.videoDimensionsConverter = { _ in
      return CMVideoDimensions(width: 4, height: 3)
    }
    configuration.videoCaptureSession = videoSessionMock
    configuration.mediaSettings = CameraTestUtils.createDefaultMediaSettings(
      resolutionPreset: PlatformResolutionPreset.max)

    let _ = CameraTestUtils.createTestCamera(configuration)

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testResolutionPresetWithCanSetSessionPresetMax_mustUpdateCaptureSessionPreset() {
    let expectedPreset = AVCaptureSession.Preset.hd4K3840x2160
    let expectation = self.expectation(description: "Expected preset set")

    let videoSessionMock = MockCaptureSession()
    // Make sure that setting resolution preset for session always succeeds.
    videoSessionMock.canSetSessionPresetStub = { _ in true }
    videoSessionMock.setSessionPresetStub = { preset in
      if preset == expectedPreset {
        expectation.fulfill()
      }
    }

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureSession = videoSessionMock
    configuration.mediaSettings = CameraTestUtils.createDefaultMediaSettings(
      resolutionPreset: PlatformResolutionPreset.max)
    configuration.videoCaptureDeviceFactory = { _ in MockCaptureDevice() }

    let _ = CameraTestUtils.createTestCamera(configuration)

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testResolutionPresetWithCanSetSessionPresetUltraHigh_mustUpdateCaptureSessionPreset() {
    let expectedPreset = AVCaptureSession.Preset.hd4K3840x2160
    let expectation = self.expectation(description: "Expected preset set")

    let videoSessionMock = MockCaptureSession()
    // Make sure that setting resolution preset for session always succeeds.
    videoSessionMock.canSetSessionPresetStub = { _ in true }
    // Expect that setting "ultraHigh" resolutionPreset correctly updates videoCaptureSession.
    videoSessionMock.setSessionPresetStub = { preset in
      if preset == expectedPreset {
        expectation.fulfill()
      }
    }

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureSession = videoSessionMock
    configuration.mediaSettings = CameraTestUtils.createDefaultMediaSettings(
      resolutionPreset: PlatformResolutionPreset.ultraHigh)

    let _ = CameraTestUtils.createTestCamera(configuration)

    waitForExpectations(timeout: 30, handler: nil)
  }

  // MARK: Aspect ratio

  private let sdr8 = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
  private let btp2: OSType = 1_651_798_066
  private let x420 = kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange
  private let x422 = kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange

  private func format(
    _ codecType: OSType, _ width: Int32, _ height: Int32, photo: [(Int32, Int32)]
  ) -> MockCaptureDeviceFormat {
    let format = MockCaptureDeviceFormat(codecType: codecType, width: width, height: height)
    format.supportedMaxPhotoDimensions = photo.map { CMVideoDimensions(width: $0.0, height: $0.1) }
    format.flutterVideoSupportedFrameRateRanges = [
      MockFrameRateRange(minFrameRate: 1, maxFrameRate: 30)
    ]
    return format
  }

  /// Representative back wide camera formats that matter here, in device order.
  private struct IPhone14ProFormats {
    let sdr1024x768: MockCaptureDeviceFormat
    let sdr1280x720: MockCaptureDeviceFormat
    let hlg1280x720: MockCaptureDeviceFormat
    let sdr1280x720Binned: MockCaptureDeviceFormat
    let sdr1920x1080: MockCaptureDeviceFormat
    let hlg1920x1080: MockCaptureDeviceFormat
    let hlg1920x1440x422: MockCaptureDeviceFormat
    let sdr1920x1440: MockCaptureDeviceFormat
    let hlg1920x1440: MockCaptureDeviceFormat
    let sdr1920x1440Binned: MockCaptureDeviceFormat
    let sdr3840x2160: MockCaptureDeviceFormat
    let hlg3840x2160: MockCaptureDeviceFormat
    let hlg3840x2160NoPhoto: MockCaptureDeviceFormat
    let sdr4032x3024: MockCaptureDeviceFormat
    let sdr4032x3024Full: MockCaptureDeviceFormat
    let btp2x4032x3024: MockCaptureDeviceFormat

    var all: [MockCaptureDeviceFormat] {
      [
        sdr1024x768, sdr1280x720, hlg1280x720, sdr1280x720Binned, sdr1920x1080, hlg1920x1080,
        hlg1920x1440x422, sdr1920x1440, hlg1920x1440, sdr1920x1440Binned, sdr3840x2160,
        hlg3840x2160, hlg3840x2160NoPhoto, sdr4032x3024, sdr4032x3024Full, btp2x4032x3024,
      ]
    }
  }

  private func iPhone14ProFormats() -> IPhone14ProFormats {
    return IPhone14ProFormats(
      sdr1024x768: format(sdr8, 1024, 768, photo: [(1024, 768), (4032, 3024)]),
      sdr1280x720: format(sdr8, 1280, 720, photo: [(1280, 720), (4224, 2376)]),
      hlg1280x720: format(x420, 1280, 720, photo: [(1280, 720), (4224, 2376)]),
      sdr1280x720Binned: format(sdr8, 1280, 720, photo: [(1280, 720), (2112, 1188)]),
      sdr1920x1080: format(sdr8, 1920, 1080, photo: [(1920, 1080), (4224, 2376)]),
      hlg1920x1080: format(x420, 1920, 1080, photo: [(1920, 1080), (4224, 2376)]),
      hlg1920x1440x422: format(x422, 1920, 1440, photo: [(1920, 1440), (4032, 3024)]),
      sdr1920x1440: format(sdr8, 1920, 1440, photo: [(1920, 1440), (4032, 3024)]),
      hlg1920x1440: format(x420, 1920, 1440, photo: [(1920, 1440), (4032, 3024)]),
      sdr1920x1440Binned: format(sdr8, 1920, 1440, photo: [(1920, 1440), (2016, 1512)]),
      sdr3840x2160: format(sdr8, 3840, 2160, photo: [(3840, 2160), (4224, 2376)]),
      hlg3840x2160: format(x420, 3840, 2160, photo: [(3840, 2160), (4224, 2376)]),
      hlg3840x2160NoPhoto: format(x420, 3840, 2160, photo: [(3840, 2160)]),
      sdr4032x3024: format(sdr8, 4032, 3024, photo: [(4032, 3024)]),
      sdr4032x3024Full: format(sdr8, 4032, 3024, photo: [(4032, 3024), (8064, 6048)]),
      btp2x4032x3024: format(btp2, 4032, 4032 * 3 / 4, photo: [(4032, 3024), (16128, 12096)]))
  }

  private func device(_ formats: [MockCaptureDeviceFormat]) -> MockCaptureDevice {
    let device = MockCaptureDevice()
    device.flutterFormats = formats
    var active: CaptureDeviceFormat = formats[0]
    device.activeFormatStub = { active }
    device.setActiveFormatStub = { active = $0 }
    return device
  }

  private func find(
    _ formats: IPhone14ProFormats, _ aspectRatio: PlatformCameraAspectRatio,
    _ preset: PlatformResolutionPreset
  ) -> [CaptureDeviceFormat] {
    return FormatUtils.findAspectRatioFormats(
      for: device(formats.all), aspectRatio: aspectRatio, preset: preset,
      videoDimensionsConverter: { CMVideoFormatDescriptionGetDimensions($0.formatDescription) })
  }

  func testAspectRatioFormats_presetIsATierOfTheShorterSide() {
    let formats = iPhone14ProFormats()

    XCTAssertTrue(find(formats, .ratio4x3, .high).first === formats.sdr1024x768)
    XCTAssertTrue(find(formats, .ratio16x9, .high).first === formats.sdr1280x720)
    XCTAssertTrue(find(formats, .ratio16x9, .veryHigh).first === formats.sdr1920x1080)
    XCTAssertTrue(find(formats, .ratio16x9, .ultraHigh).first === formats.sdr3840x2160)
  }

  func testAspectRatioFormats_maxIsTheLargestFormatWithTheLargestPhotoFirst() {
    let formats = iPhone14ProFormats()

    let fourByThree = find(formats, .ratio4x3, .max)
    XCTAssertEqual(fourByThree.count, 2)
    XCTAssertTrue(fourByThree.first === formats.sdr4032x3024Full)
  }

  func testAspectRatioFormats_prefersLargerPhotosAmongFormatsOfTheSameSize() {
    let formats = iPhone14ProFormats()

    XCTAssertTrue(find(formats, .ratio16x9, .high).last === formats.sdr1280x720Binned)
    XCTAssertTrue(find(formats, .ratio4x3, .veryHigh).first === formats.sdr1920x1440)
  }

  func testAspectRatioFormats_excludeFormatsTheFlutterEngineDoesNotSupport() {
    let formats = iPhone14ProFormats()

    XCTAssertFalse(find(formats, .ratio4x3, .max).contains { $0 === formats.btp2x4032x3024 })
    XCTAssertTrue(find(formats, .ratio4x3, .max).first === formats.sdr4032x3024Full)
  }

  func testAspectRatioFormats_isEmptyWithoutTheAspectRatio() {
    let formats = iPhone14ProFormats()

    XCTAssertTrue(
      FormatUtils.findAspectRatioFormats(
        for: device([formats.sdr1280x720]), aspectRatio: .ratio4x3, preset: .high,
        videoDimensionsConverter: { CMVideoFormatDescriptionGetDimensions($0.formatDescription) }
      ).isEmpty)
  }

  private func makeCamera(
    _ captureDevice: MockCaptureDevice, aspectRatio: PlatformCameraAspectRatio?,
    preset: PlatformResolutionPreset,
    framesPerSecond: Int64? = nil, session: MockCaptureSession = MockCaptureSession()
  ) -> DefaultCamera {
    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.videoCaptureDeviceFactory = { _ in captureDevice }
    session.canSetSessionPresetStub = { _ in true }
    session.setSessionPresetStub = { [unowned session] in session._sessionPreset = $0 }
    configuration.videoCaptureSession = session
    configuration.mediaSettings = PlatformMediaSettings(
      resolutionPreset: preset, framesPerSecond: framesPerSecond, videoBitrate: nil,
      audioBitrate: nil, enableAudio: false, aspectRatio: aspectRatio)
    return CameraTestUtils.createTestCamera(configuration)
  }

  func testAspectRatio_appliesTheChosenFormat() {
    let formats = iPhone14ProFormats()
    let captureDevice = device(formats.all)
    let session = MockCaptureSession()

    _ = makeCamera(captureDevice, aspectRatio: .ratio4x3, preset: .max, session: session)

    XCTAssertTrue(captureDevice.flutterActiveFormat === formats.sdr4032x3024Full)
    XCTAssertEqual(session.sessionPreset, .inputPriority)
  }

  func testAspectRatio_zeroShutterLagSwitchesToAFormatOfTheSameSizeThatSupportsIt() {
    let formats = iPhone14ProFormats()
    let captureDevice = device(formats.all)
    let camera = makeCamera(captureDevice, aspectRatio: .ratio4x3, preset: .max)
    XCTAssertTrue(captureDevice.flutterActiveFormat === formats.sdr4032x3024Full)
    let photoOutput = MockCapturePhotoOutput()
    photoOutput.flutterZeroShutterLagSupportedStub = {
      captureDevice.flutterActiveFormat === formats.sdr4032x3024
    }
    camera.capturePhotoOutput = photoOutput

    camera.setZeroShutterLagEnabled(true)

    XCTAssertTrue(captureDevice.flutterActiveFormat === formats.sdr4032x3024)
    XCTAssertTrue(photoOutput.flutterZeroShutterLagEnabled)
  }

  func testAspectRatio_zeroShutterLagKeepsTheFormatWhenNoneSupportsIt() {
    let formats = iPhone14ProFormats()
    let captureDevice = device(formats.all)
    let camera = makeCamera(captureDevice, aspectRatio: .ratio4x3, preset: .max)
    let photoOutput = MockCapturePhotoOutput()
    camera.capturePhotoOutput = photoOutput

    camera.setZeroShutterLagEnabled(true)

    XCTAssertTrue(captureDevice.flutterActiveFormat === formats.sdr4032x3024Full)
    XCTAssertFalse(photoOutput.flutterZeroShutterLagEnabled)
  }

  func testAspectRatio_withAFrameRateKeepsTheChosenSize() {
    let formats = iPhone14ProFormats()
    let captureDevice = device(formats.all)

    _ = makeCamera(captureDevice, aspectRatio: .ratio4x3, preset: .veryHigh, framesPerSecond: 30)

    XCTAssertTrue(captureDevice.flutterActiveFormat === formats.sdr1920x1440)
  }

  func testWithoutAspectRatio_keepsThePresetFormatChoice() {
    let formats = iPhone14ProFormats()
    let session = MockCaptureSession()

    _ = makeCamera(device(formats.all), aspectRatio: nil, preset: .veryHigh, session: session)

    XCTAssertEqual(session.sessionPreset, .hd1920x1080)
  }

  func testAspectRatioWithoutMatchingFormat_fallsBackToTheSessionPreset() {
    let formats = iPhone14ProFormats()
    let captureDevice = device([formats.sdr1280x720, formats.sdr1920x1080])
    let session = MockCaptureSession()

    _ = makeCamera(captureDevice, aspectRatio: .ratio4x3, preset: .veryHigh, session: session)

    XCTAssertEqual(session.sessionPreset, .hd1920x1080)
    XCTAssertTrue(captureDevice.flutterActiveFormat === formats.sdr1280x720)
  }

  func testAspectRatioWithoutMatchingFormat_withAFrameRateFallsBackToTheSessionPreset() {
    let formats = iPhone14ProFormats()
    let captureDevice = device([formats.sdr1280x720, formats.sdr1920x1080])
    let session = MockCaptureSession()

    _ = makeCamera(
      captureDevice, aspectRatio: .ratio4x3, preset: .veryHigh, framesPerSecond: 30,
      session: session)

    XCTAssertEqual(session.sessionPreset, .hd1920x1080)
  }
}
