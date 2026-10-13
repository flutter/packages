// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PhotosUI

/// Creates PHPickerViewController instances.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
@available(iOS 14, *)
protocol PHPickerCreating {
  func makePicker(configuration: PHPickerConfiguration) -> PHPickerViewController
}

/// Production implementation that constructs a real PHPickerViewController.
@available(iOS 14, *)
struct DefaultPHPickerCreator: PHPickerCreating {
  func makePicker(configuration: PHPickerConfiguration) -> PHPickerViewController {
    PHPickerViewController(configuration: configuration)
  }
}
