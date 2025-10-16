// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// A mock implementation of `FCPCameraGlobalEventApi` that captures received
/// `deviceOrientationChanged` events and exposes whether they were received to the testing code.
final class MockGlobalEventApi: FCPCameraGlobalEventApi {

  /// Whether the `deviceOrientationChanged` callback was called.
  var deviceOrientationChangedCalled = false

  /// The last orientation received by the `deviceOrientationChanged` callback.
  var lastOrientation = FCPPlatformDeviceOrientation.portraitUp

  override func deviceOrientationChangedOrientation(
    _ orientation: FCPPlatformDeviceOrientation,
    completion: @escaping (FlutterError?) -> Void
  ) {
    deviceOrientationChangedCalled = true
    lastOrientation = orientation
    completion(nil)
  }
}
