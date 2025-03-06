// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

/// Tests of `CameraPlugin` methods delegating to `FLTCam` instance
final class CameraPluginDelegatingMethodTests: XCTestCase {
  private func createCameraPlugin() -> (CameraPlugin, MockFLTCam) {
    let mockCamera = MockFLTCam()

    let cameraPlugin = CameraPlugin(
      registry: MockFlutterTextureRegistry(),
      messenger: MockFlutterBinaryMessenger(),
      globalAPI: MockGlobalEventApi(),
      deviceDiscoverer: MockCameraDeviceDiscoverer(),
      permissionManager: MockFLTCameraPermissionManager(),
      deviceFactory: { _ in MockCaptureDevice() },
      captureSessionFactory: { MockCaptureSession() },
      captureDeviceInputFactory: MockCaptureDeviceInputFactory()
    )
    cameraPlugin.camera = mockCamera

    return (cameraPlugin, mockCamera)
  }

  // Universal function orchiestrating a test of a delegating method
  private func testDelegatingMethod(
    // Callback with MockFLTCam instance and a callback to call when the expected FLTCam method has
    // been called
    setUp: (MockFLTCam, @escaping () -> Void) -> Void,
    // Callback with CameraPlugin instance and a complition to call when the tested method finishes
    act: (CameraPlugin, @escaping (FlutterError?) -> Void) -> Void
  ) {
    let (cameraPlugin, mockCamera) = createCameraPlugin()
    // Expectation fulfilled when complition passed to `act` callback is called
    let expectation = expectation(description: "Call completed")

    var markCalled = false

    setUp(
      mockCamera,
      {
        markCalled = true
      }
    )

    act(cameraPlugin) { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)

    XCTAssertTrue(markCalled)
  }

  func testLockCapture_callsDelegateMethod() {
    let targetOrientation = FCPPlatformDeviceOrientation.landscapeLeft

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.lockCaptureStub = { orientation in
        XCTAssertEqual(orientation, targetOrientation)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.lockCapture(targetOrientation, completion: complition)
    }
  }

  func testPausePreview_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.pausePreviewStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.pausePreview(completion: complition)
    }
  }

  func testPauseVideoRecording_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.pauseVideoRecordingStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.pauseVideoRecording(completion: complition)
    }
  }

  func testPrepareForVideoRecording_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setUpCaptureSessionForAudioIfNeededStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.prepareForVideoRecording(completion: complition)
    }
  }

  func testReceivedImageStreamData_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.receivedImageStreamDataStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.receivedImageStreamData(completion: complition)
    }
  }

  func testResumeVideoRecording_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.resumeVideoRecordingStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.resumeVideoRecording(completion: complition)
    }
  }

  func testResumePreview_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.resumePreviewStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.resumePreview(completion: complition)
    }
  }

  func testSetExposureMode_callsDelegateMethod() {
    let targetExposureMode = FCPPlatformExposureMode.locked

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setExposureModeStub = { mode in
        XCTAssertEqual(mode, targetExposureMode)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setExposureMode(targetExposureMode, completion: complition)
    }
  }

  func testSetExposureOffset_callsDelegateMethod() {
    let targetExposureOffset = 1.0

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setExposureOffsetStub = { offset in
        XCTAssertEqual(offset, targetExposureOffset)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setExposureOffset(targetExposureOffset, completion: complition)
    }
  }

  func testSetFocusMode_callsDelegateMethod() {
    let targetFocusMode = FCPPlatformFocusMode.locked

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setFocusModeStub = { mode in
        XCTAssertEqual(mode, targetFocusMode)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setFocusMode(targetFocusMode, completion: complition)
    }
  }

  func testSetImageFileFormat_callsDelegateMethod() {
    let targetFileFormat = FCPPlatformImageFileFormat.heif

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setImageFileFormatStub = { filerFormat in
        XCTAssertEqual(filerFormat, targetFileFormat)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setImageFileFormat(targetFileFormat, completion: complition)
    }
  }

  func testStartImageStream_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.startImageStreamStub = { _ in markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.startImageStream(completion: complition)
    }
  }

  func testStopImageStream_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.stopImageStreamStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.stopImageStream(completion: complition)
    }
  }

  func testStartVideoRecording_withStreamingTrue_callsDelegateMethodWithMessanger() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.startVideoRecordingStub = { complition, messanger in
        XCTAssertNotNil(messanger)
        complition(nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.startVideoRecording(withStreaming: true, completion: complition)
    }
  }

  func testStartVideoRecording_withStreamingFalse_callsDelegateMethodWithoutMessagner() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.startVideoRecordingStub = { complition, messanger in
        XCTAssertNil(messanger)
        complition(nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.startVideoRecording(withStreaming: false, completion: complition)
    }
  }

  func testStopVideoRecording_callsDelegateMethod() {
    let targetPath = "path"

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.stopVideoRecordingStub = { completion in
        completion?(targetPath, nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.stopVideoRecording { path, error in
        XCTAssertEqual(path, targetPath)
        complition(error)
      }
    }
  }

  func testUnlockCaptureOrientation_callsDelegateMethod() {
    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.unlockCaptureOrientationStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.unlockCaptureOrientation(completion: complition)
    }
  }

  func testSetExposurePoint_callsDelegateMethod() {
    let targetExposurePoint = FCPPlatformPoint.makeWith(x: 1.0, y: 1.0)

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setExposurePointStub = { point, complition in
        XCTAssertEqual(point, targetExposurePoint)
        complition?(nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setExposurePoint(targetExposurePoint, completion: complition)
    }
  }

  func testSetFlashMode_callsDelegateMethod() {
    let targetFlashMode = FCPPlatformFlashMode.auto

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setFlashModeStub = { mode, complition in
        XCTAssertEqual(mode, targetFlashMode)
        complition?(nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setFlashMode(targetFlashMode, completion: complition)
    }
  }

  func testSetFocusPoint_callsDelegateMethod() {
    let targetFocusPoint = FCPPlatformPoint.makeWith(x: 1.0, y: 1.0)

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setFocusPointStub = { point, complition in
        XCTAssertEqual(point, targetFocusPoint)
        complition?(nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setFocus(targetFocusPoint, completion: complition)
    }
  }

  func testSetZoomLevel_callsDelegateMethod() {
    let targetZoomLevel = 1.0

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setZoomLevelStub = { zoom, complition in
        XCTAssertEqual(zoom, targetZoomLevel)
        complition?(nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setZoomLevel(targetZoomLevel, completion: complition)
    }
  }

  func testTakePicture_callsDelegateMethod() {
    let targetPath = "path"

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.captureToFileStub = { completion in
        completion?(targetPath, nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.takePicture { path, error in
        XCTAssertEqual(path, targetPath)
        complition(error)
      }
    }
  }

  func testUpdateDescriptionWhileRecordingCameraName_callsDelegateMethod() {
    let targetCameraName = "camera_name"

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.setDescriptionWhileRecordingStub = { cameraName, complition in
        XCTAssertEqual(cameraName, targetCameraName)
        complition?(nil)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.updateDescriptionWhileRecordingCameraName(
        targetCameraName, completion: complition)
    }
  }

  func testGetMaximumZoomLevel_returnsValueFromDelegateMethod() {
    let targetMaximumZoomLevel = CGFloat(1.0)

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.getMaximumAvailableZoomFactorStub = {
        markCalled()
        return targetMaximumZoomLevel
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.getMaximumZoomLevel { zoom, error in
        XCTAssertNil(error)
        XCTAssertEqual(zoom?.doubleValue, targetMaximumZoomLevel)
        complition(nil)
      }
    }
  }

  func testGetMinimumZoomLevel_returnsValueFromDelegateMethod() {
    let targetMinimumZoomLevel = CGFloat(1.0)

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.getMinimumAvailableZoomFactorStub = {
        markCalled()
        return targetMinimumZoomLevel
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.getMinimumZoomLevel { zoom, error in
        XCTAssertNil(error)
        XCTAssertEqual(zoom?.doubleValue, targetMinimumZoomLevel)
        complition(nil)
      }
    }
  }

  func testGetMaximumExposureOffset_returnsValueFromDelegateMethod() {
    let targetMaximumExposureOffset = CGFloat(1.0)

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.getMaximumExposureOffsetStub = {
        markCalled()
        return targetMaximumExposureOffset
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.getMaximumExposureOffset { offset, error in
        XCTAssertNil(error)
        XCTAssertEqual(offset?.doubleValue, targetMaximumExposureOffset)
        complition(nil)
      }
    }
  }

  func testGetMinimumExposureOffset_returnsValueFromDelegateMethod() {
    let targetMinimumExposureOffset = CGFloat(1.0)

    testDelegatingMethod { mockCamera, markCalled in
      mockCamera.getMinimumExposureOffsetStub = {
        markCalled()
        return targetMinimumExposureOffset
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.getMinimumExposureOffset { offset, error in
        XCTAssertNil(error)
        XCTAssertEqual(offset?.doubleValue, targetMinimumExposureOffset)
        complition(nil)
      }
    }
  }
}
