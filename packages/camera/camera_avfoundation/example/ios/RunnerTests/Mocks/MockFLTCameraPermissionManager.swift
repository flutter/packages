// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class MockFLTCameraPermissionManager: FLTCameraPermissionManager {
  var requestCameraPermissionStub: ((((FlutterError?) -> Void)?) -> Void)?
  var requestAudioPermissionStub: ((((FlutterError?) -> Void)?) -> Void)?

  override func requestCameraPermission(completionHandler: ((FlutterError?) -> Void)?) {
    requestCameraPermissionStub?(completionHandler)
  }

  override func requestAudioPermission(completionHandler: ((FlutterError?) -> Void)?) {
    requestAudioPermissionStub?(completionHandler)
  }
}
