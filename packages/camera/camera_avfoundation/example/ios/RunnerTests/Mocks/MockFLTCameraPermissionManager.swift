// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
