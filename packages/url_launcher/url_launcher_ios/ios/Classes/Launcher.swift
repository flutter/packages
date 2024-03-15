// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

/// Protocol for UIApplication methods relating to launching URLs.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol Launcher {
  /// Returns a Boolean value that indicates whether an app is available to handle a URL scheme.
  func canOpenURL(_ url: URL) -> Bool

  /// Attempts to asynchronously open the resource at the specified URL.
  func open(
    _ url: URL,
    options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?)
}

/// Launcher is intentionally a direct passthroguh to UIApplication.
extension UIApplication: Launcher {}
