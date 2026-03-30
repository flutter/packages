// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import XCTest

@testable import camera_avfoundation

private final class MockPermissionService: NSObject, PermissionServicing {
  var authorizationStatusStub: ((AVMediaType) -> AVAuthorizationStatus)?
  var requestAccessStub: ((AVMediaType, @escaping @Sendable (Bool) -> Void) -> Void)?

  func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
    return authorizationStatusStub?(mediaType) ?? .notDetermined
  }

  func requestAccess(for mediaType: AVMediaType, completion: @escaping @Sendable (Bool) -> Void) {
    requestAccessStub?(mediaType, completion)
  }
}

final class CameraPermissionManagerTests: XCTestCase {
  private func createSutAndMocks() -> (CameraPermissionManager, MockPermissionService) {
    let mockPermissionService = MockPermissionService()
    let permissionManager = CameraPermissionManager(permissionService: mockPermissionService)

    return (permissionManager, mockPermissionService)
  }

  // MARK: - Camera permissions

  func testRequestCameraPermission_completeWithoutErrorIfPreviouslyAuthorized() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete without error if camera access was previously authorized.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .video)
      return .authorized
    }
    permissionManager.requestCameraPermission { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestCameraPermission_completeWithErrorIfPreviouslyDenied() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete with error if camera access was previously denied.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .video)
      return .denied
    }
    permissionManager.requestCameraPermission { error in
      XCTAssertEqual(error?.code, "CameraAccessDeniedWithoutPrompt")
      XCTAssertEqual(
        error?.message,
        "User has previously denied the camera access request. Go to Settings to enable camera access."
      )
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestCameraPermission_completeWithErrorIfRestricted() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete with error if camera access is restricted.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .video)
      return .restricted
    }
    permissionManager.requestCameraPermission { error in
      XCTAssertEqual(error?.code, "CameraAccessRestricted")
      XCTAssertEqual(error?.message, "Camera access is restricted.")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestCameraPermission_completeWithoutErrorIfUserGrantAccess() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete without error if user granted access.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .video)
      return .notDetermined
    }
    mockPermissionService.requestAccessStub = { mediaType, handler in
      XCTAssertEqual(mediaType, .video)
      // Grant access.
      handler(true)
    }
    permissionManager.requestCameraPermission { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestCameraPermission_completeWithErrorIfUserDenyAccess() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete with error if user denied access.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .video)
      return .notDetermined
    }
    mockPermissionService.requestAccessStub = { mediaType, handler in
      XCTAssertEqual(mediaType, .video)
      // Deny access.
      handler(false)
    }
    permissionManager.requestCameraPermission { error in
      XCTAssertEqual(error?.code, "CameraAccessDenied")
      XCTAssertEqual(error?.message, "User denied the camera access request.")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  // MARK: - Audio permissions

  func testRequestAudioPermission_completeWithoutErrorIfPreviouslyAuthorized() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete without error if audio access was previously authorized.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .audio)
      return .authorized
    }
    permissionManager.requestAudioPermission { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestAudioPermission_completeWithErrorIfPreviouslyDenied() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete with error if audio access was previously denied.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .audio)
      return .denied
    }
    permissionManager.requestAudioPermission { error in
      XCTAssertEqual(error?.code, "AudioAccessDeniedWithoutPrompt")
      XCTAssertEqual(
        error?.message,
        "User has previously denied the audio access request. Go to Settings to enable audio access."
      )
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestAudioPermission_completeWithErrorIfRestricted() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete with error if audio access is restricted.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .audio)
      return .restricted
    }
    permissionManager.requestAudioPermission { error in
      XCTAssertEqual(error?.code, "AudioAccessRestricted")
      XCTAssertEqual(error?.message, "Audio access is restricted.")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestAudioPermission_completeWithoutErrorIfUserGrantAccess() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete without error if user granted access.")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .audio)
      return .notDetermined
    }
    mockPermissionService.requestAccessStub = { mediaType, handler in
      XCTAssertEqual(mediaType, .audio)
      // Grant access.
      handler(true)
    }
    permissionManager.requestAudioPermission { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }

  func testRequestAudioPermission_completeWithErrorIfUserDenyAccess() {
    let (permissionManager, mockPermissionService) = createSutAndMocks()
    let expectation = self.expectation(
      description: "Must complete with error if user denied access")

    mockPermissionService.authorizationStatusStub = { mediaType in
      XCTAssertEqual(mediaType, .audio)
      return .notDetermined
    }
    mockPermissionService.requestAccessStub = { mediaType, handler in
      XCTAssertEqual(mediaType, .audio)
      // Deny access.
      handler(false)
    }
    permissionManager.requestAudioPermission { error in
      XCTAssertEqual(error?.code, "AudioAccessDenied")
      XCTAssertEqual(error?.message, "User denied the audio access request.")
      expectation.fulfill()
    }

    waitForExpectations(timeout: 30, handler: nil)
  }
}
