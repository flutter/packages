// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

@testable import camera_avfoundation

final class MockDeviceOrientationProvider: NSObject, DeviceOrientationProvider {
  var orientationStub: (() -> UIDeviceOrientation)?

  var orientation: UIDeviceOrientation {
    return orientationStub?() ?? .unknown
  }
}
