// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// Protocol for UIViewController methods relating to presenting a controller.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol ViewPresenter {
  /// Presents a view controller modally.
  func present(
    _ viewControllerToPresent: UIViewController,
    animated flag: Bool,
    completion: (() -> Void)?
  )
}

/// ViewPresenter is intentionally a direct passthroguh to UIViewController.
extension UIViewController: ViewPresenter {}
