// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class MockCameraPermissionManager: CameraPermissionManager {
  var requestCameraPermissionStub: ((@escaping CameraPermissionRequestCompletionHandler) -> Void)?
  var requestAudioPermissionStub: ((@escaping CameraPermissionRequestCompletionHandler) -> Void)?

  init() {
    super.init(permissionService: DefaultPermissionService())
  }

  override func requestCameraPermission(completionHandler: @escaping (FlutterError?) -> Void) {
    if let stub = requestCameraPermissionStub {
      stub(completionHandler)
    } else {
      super.requestCameraPermission(completionHandler: completionHandler)
    }
  }

  override func requestAudioPermission(completionHandler: @escaping (FlutterError?) -> Void) {
    if let stub = requestAudioPermissionStub {
      stub(completionHandler)
    } else {
      super.requestAudioPermission(completionHandler: completionHandler)
    }
  }
}
