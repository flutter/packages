// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

/// Includes test cases related to resolution presets setting operations for FLTCam class.
final class CameraSessionPresetsTests: XCTestCase {
  func testResolutionPresetWithBestFormat_mustUpdateCaptureSessionPreset() {
    let expectedPreset = AVCaptureSession.Preset.inputPriority
    let presetExpectation = expectation(description: "Expected preset set")
    let lockForConfigurationExpectation = expectation(
      description: "Expected lockForConfiguration called")

    let videoSessionMock = MockCaptureSession()
    videoSessionMock.setSessionPresetStub = { preset in
      if preset == expectedPreset {
        presetExpectation.fulfill()
      }
    }
    let captureFormatMock = MockCaptureDeviceFormat()
    let captureDeviceMock = MockCaptureDevice()
    captureDeviceMock.formats = [captureFormatMock]
    captureDeviceMock.activeFormat = captureFormatMock
    captureDeviceMock.lockForConfigurationStub = { error in
      lockForConfigurationExpectation.fulfill()
      return true
    }

    let configuration = CameraTestUtils.createTestCameraConfiguration()
    configuration.captureDeviceFactory = { captureDeviceMock }
    configuration.videoDimensionsForFormat = { format in
      return CMVideoDimensions(width: 1, height: 1)
    }
    configuration.videoCaptureSession = videoSessionMock
    configuration.mediaSettings = CameraTestUtils.createDefaultMediaSettings(
      resolutionPreset: FCPPlatformResolutionPreset.max)

    let _ = FLTCam(configuration: configuration, error: nil)

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
      resolutionPreset: FCPPlatformResolutionPreset.max)
    configuration.captureDeviceFactory = { MockCaptureDevice() }

    let _ = FLTCam(configuration: configuration, error: nil)

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
      resolutionPreset: FCPPlatformResolutionPreset.ultraHigh)

    let _ = FLTCam(configuration: configuration, error: nil)

    waitForExpectations(timeout: 30, handler: nil)
  }
}
