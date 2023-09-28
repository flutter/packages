// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

protocol Launcher {
  func canOpenURL(_ url: URL) -> Bool
  func openURL(
    _ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?)
}

final class UIApplicationLauncher: Launcher {
  func canOpenURL(_ url: URL) -> Bool {
    UIApplication.shared.canOpenURL(url)
  }

  func openURL(
    _ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?
  ) {
    UIApplication.shared.open(url, options: options, completionHandler: completion)
  }
}
