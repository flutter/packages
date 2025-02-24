// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import camera_avfoundation

/// Tests of `CameraPlugin` methods forwarding to `FLTCam` instance methods
final class CameraPluginForwardingMethodTests: XCTestCase {
  private func createSutAndMocks() -> (CameraPlugin, MockFLTCam) {
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

  /// Universal function orchiestrating forwarding method test
  private func testForwaringMethod(
    setUp: (MockFLTCam, @escaping () -> Void) -> Void,
    act: (CameraPlugin, @escaping (FlutterError?) -> Void) -> Void
  ) {
    let (cameraPlugin, mockCamera) = createSutAndMocks()
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

    testForwaringMethod { mockCamera, markCalled in
      mockCamera.lockCaptureStub = { orientation in
        XCTAssertEqual(orientation, targetOrientation)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.lockCapture(targetOrientation, completion: complition)
    }
  }

  func testPausePreview_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.pausePreviewStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.pausePreview(completion: complition)
    }
  }

  func testPauseVideoRecording_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.pauseVideoRecordingStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.pauseVideoRecording(completion: complition)
    }
  }

  func testPrepareForVideoRecording_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.setUpCaptureSessionForAudioIfNeededStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.prepareForVideoRecording(completion: complition)
    }
  }

  func testReceivedImageStreamData_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.receivedImageStreamDataStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.receivedImageStreamData(completion: complition)
    }
  }

  func testResumeVideoRecording_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.resumeVideoRecordingStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.resumeVideoRecording(completion: complition)
    }
  }

  func testResumePreview_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.resumePreviewStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.resumePreview(completion: complition)
    }
  }

  func testSetExposureMode_callsDelegateMethod() {
    let targetExposureMode = FCPPlatformExposureMode.locked

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
      mockCamera.setImageFileFormatStub = { filerFormat in
        XCTAssertEqual(filerFormat, targetFileFormat)
        markCalled()
      }
    } act: { cameraPlugin, complition in
      cameraPlugin.setImageFileFormat(targetFileFormat, completion: complition)
    }
  }

  func testStartImageStream_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.startImageStreamStub = { _ in markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.startImageStream(completion: complition)
    }
  }

  func testStopImageStream_callsDelegateMethod() {
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.stopImageStreamStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.stopImageStream(completion: complition)
    }
  }

  func testStartVideoRecording_withStreamingTrue_callsDelegateMethodWithMessanger() {
    testForwaringMethod { mockCamera, markCalled in
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
    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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
    testForwaringMethod { mockCamera, markCalled in
      mockCamera.unlockCaptureOrientationStub = { markCalled() }
    } act: { cameraPlugin, complition in
      cameraPlugin.unlockCaptureOrientation(completion: complition)
    }
  }

  func testSetExposurePoint_callsDelegateMethod() {
    let targetExposurePoint = FCPPlatformPoint.makeWith(x: 1.0, y: 1.0)

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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

    testForwaringMethod { mockCamera, markCalled in
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
