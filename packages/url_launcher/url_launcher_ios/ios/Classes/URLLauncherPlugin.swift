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

  init(launcher: Launcher = UIApplicationLauncher()) {
    self.launcher = launcher
  }

  func canLaunchUrl(url: String) -> Bool {
    guard let url = URL(string: url) else { return false }
    return launcher.canOpenURL(url)
  }

  func launchUrl(
    url: String, universalLinksOnly: Bool, completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    guard let url = URL(string: url) else {
      completion(Result.failure(invalidURLError(for: url)))
      return
    }
    let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: universalLinksOnly]
    launcher.openURL(url, options: options) { success in
      completion(Result.success(success))
    }
  }

  func openUrlInSafariViewController(
    url: String, completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    guard let url = URL(string: url) else {
      completion(Result.failure(invalidURLError(for: url)))
      return
    }

    currentSession = URLLaunchSession(url: url, completion: completion)
    guard let session = currentSession else { return }

    session.didFinish = { [weak self] in
      self?.currentSession = nil
    }
    topViewController?.present(session.safari, animated: true, completion: nil)
  }

  func closeSafariViewController() {
    currentSession?.close()
  }

  var topViewController: UIViewController? {
    // TODO(stuartmorgan) Provide a non-deprecated codepath. See
    // https://github.com/flutter/flutter/issues/104117
    UIApplication.shared.keyWindow?.rootViewController?.topViewController
  }

  /**
    * Creates an error for an invalid URL string.
    *
    * @param url The invalid URL string
    * @return The error to return
    */
  func invalidURLError(for url: String) -> Error {
    GeneralError(
      code: "argument_error", message: "Unable to parse URL", details: "Provided URL: \(url)")
  }
}

/// This method recursively iterate through the view hierarchy
/// to return the top most view controller.
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

class GeneralError: Error {
  let code: String
  let message: String
  let details: String?

  init(code: String, message: String, details: String? = nil) {
    self.code = code
    self.message = message
    self.details = details
  }
}
