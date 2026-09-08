// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// A protocol which provides the current device orientation.
/// It exists to allow replacing UIDevice in tests.
protocol DeviceOrientationProvider {
  /// Returns the physical orientation of the device.
  var orientation: UIDeviceOrientation { get }
}

/// A default implementation of DeviceOrientationProvider which uses orientation
/// of the current device from UIDevice.
@objc public class DefaultDeviceOrientationProvider: NSObject, DeviceOrientationProvider {
  @objc public var orientation: UIDeviceOrientation {
    return UIDevice.current.orientation
  }
}
