// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objectice-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class MockDeviceOrientationProvider: NSObject, FLTDeviceOrientationProviding {
  var orientationStub: (() -> UIDeviceOrientation)?

  func orientation() -> UIDeviceOrientation {
    return orientationStub?() ?? .unknown
  }
}
