// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

public final class URLLauncherPlugin: NSObject, FlutterPlugin, UrlLauncherApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = URLLauncherPlugin()
    UrlLauncherApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    registrar.publish(plugin)
  }

  private var currentSession: URLLaunchSession?
  private let launcher: Launcher

  private var topViewController: UIViewController? {
    // TODO(stuartmorgan) Provide a non-deprecated codepath. See
    // https://github.com/flutter/flutter/issues/104117
    UIApplication.shared.keyWindow?.rootViewController?.topViewController
  }

  init(launcher: Launcher = DefaultLauncher()) {
    self.launcher = launcher
  }

  func canLaunchUrl(url: String) -> LaunchResult {
    guard let url = URL(string: url) else {
      return .invalidUrl
    }
    let canOpen = launcher.canOpenURL(url)
    return canOpen ? .success : .failure
  }

  func launchUrl(
    url: String,
    universalLinksOnly: Bool,
    completion: @escaping (Result<LaunchResult, Error>) -> Void
  ) {
    guard let url = URL(string: url) else {
      completion(.success(.invalidUrl))
      return
    }
    let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: universalLinksOnly]
    launcher.open(url, options: options) { result in
      completion(.success(result ? .success : .failure))
    }
  }

  func openUrlInSafariViewController(
    url: String,
    completion: @escaping (Result<InAppLoadResult, Error>) -> Void
  ) {
    guard let url = URL(string: url) else {
      completion(.success(.invalidUrl))
      return
    }

    let session = URLLaunchSession(url: url, completion: completion)
    currentSession = session

    session.didFinish = { [weak self] in
      self?.currentSession = nil
    }
    topViewController?.present(session.safariViewController, animated: true, completion: nil)
  }

  func closeSafariViewController() {
    currentSession?.close()
  }
}

/// This method recursively iterates through the view hierarchy
/// to return the top-most view controller.
///
/// It supports the following scenarios:
///
/// - The view controller is presenting another view.
/// - The view controller is a UINavigationController.
/// - The view controller is a UITabBarController.
///
/// @return The top most view controller.
extension UIViewController {
  var topViewController: UIViewController {
    if let navigationController = self as? UINavigationController {
      return navigationController.viewControllers.last?.topViewController
        ?? navigationController
        .visibleViewController ?? navigationController
    }
    if let tabBarController = self as? UITabBarController {
      return tabBarController.selectedViewController?.topViewController ?? tabBarController
    }
    if let presented = presentedViewController {
      return presented.topViewController
    }
    return self
  }
}
