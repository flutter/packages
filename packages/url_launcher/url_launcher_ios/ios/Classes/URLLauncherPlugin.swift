// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

public final class URLLauncherPlugin: NSObject, FlutterPlugin, UrlLauncherApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = URLLauncherPlugin()
    UrlLauncherApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    registrar.publish(plugin)
  }

  private var currentSession: URLLaunchSession?
  private let launcher: Launcher

  var topViewController: UIViewController? {
    // TODO(stuartmorgan) Provide a non-deprecated codepath. See
    // https://github.com/flutter/flutter/issues/104117
    UIApplication.shared.keyWindow?.rootViewController?.topViewController
  }

  init(launcher: Launcher = UIApplicationLauncher()) {
    self.launcher = launcher
  }

  func canLaunchUrl(url: String) -> LaunchResultDetails {
    guard let url = URL(string: url) else {
      return invalidURLError(for: url)
    }
    let canOpen = launcher.canOpenURL(url)
    return LaunchResultDetails(result: canOpen ? .success : .failure)
  }

  func launchUrl(
    url: String, universalLinksOnly: Bool,
    completion: @escaping (Result<LaunchResultDetails, Error>) -> Void
  ) {
    guard let url = URL(string: url) else {
      completion(.success(invalidURLError(for: url)))
      return
    }
    let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: universalLinksOnly]
    launcher.openURL(url, options: options) { success in
      let result = LaunchResultDetails(result: success ? .success : .failure)
      completion(.success(result))
    }
  }

  func openUrlInSafariViewController(
    url: String, completion: @escaping (Result<LaunchResultDetails, Error>) -> Void
  ) {
    guard let url = URL(string: url) else {
      completion(.success(invalidURLError(for: url)))
      return
    }

    let session = URLLaunchSession(url: url, completion: completion)
    currentSession = session

    session.didFinish = { [weak self] in
      self?.currentSession = nil
    }
    topViewController?.present(session.safariViewController, animated: true, completion: nil)
  }

  func closeSafariViewController() throws {
    currentSession?.close()
  }

  /**
    * Creates an error for an invalid URL string.
    *
    * @param url The invalid URL string
    * @return The error to return
    */
  func invalidURLError(for url: String) -> LaunchResultDetails {
    LaunchResultDetails(
      result: .invalidUrl, errorMessage: "Unable to parse URL", errorDetails: "Provided URL: \(url)"
    )
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
      return navigationController.viewControllers.last?.topViewController ?? navigationController
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
