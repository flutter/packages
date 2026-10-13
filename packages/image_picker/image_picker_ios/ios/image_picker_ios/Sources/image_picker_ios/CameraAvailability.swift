// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// Camera source and device availability checks.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol CameraAvailabilityChecking {
  func isSourceTypeAvailable(_ sourceType: UIImagePickerController.SourceType) -> Bool
  func isCameraDeviceAvailable(_ cameraDevice: UIImagePickerController.CameraDevice) -> Bool
}

/// Production implementation that forwards to UIImagePickerController.
struct DefaultCameraAvailability: CameraAvailabilityChecking {
  func isSourceTypeAvailable(_ sourceType: UIImagePickerController.SourceType) -> Bool {
    UIImagePickerController.isSourceTypeAvailable(sourceType)
  }

  func isCameraDeviceAvailable(_ cameraDevice: UIImagePickerController.CameraDevice) -> Bool {
    UIImagePickerController.isCameraDeviceAvailable(cameraDevice)
  }
}
