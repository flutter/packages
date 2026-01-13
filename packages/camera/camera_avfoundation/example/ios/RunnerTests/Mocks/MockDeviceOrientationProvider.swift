// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class MockDeviceOrientationProvider: NSObject, DeviceOrientationProvider {
  var orientationStub: (() -> UIDeviceOrientation)?

  var orientation: UIDeviceOrientation {
    return orientationStub?() ?? .unknown
  }
}
