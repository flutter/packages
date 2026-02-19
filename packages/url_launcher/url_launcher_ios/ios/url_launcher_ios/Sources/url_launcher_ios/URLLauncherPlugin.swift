// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

public final class URLLauncherPlugin: NSObject, FlutterPlugin, UrlLauncherApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = URLLauncherPlugin(
      viewPresenterProvider: DefaultViewPresenterProvider(registrar: registrar))
    UrlLauncherApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    registrar.publish(plugin)
  }

  private var currentSession: URLLaunchSession?
  private let launcher: Launcher
  /// The view presenter provider, for showing a Safari view controller.
  private let viewPresenterProvider: ViewPresenterProvider

  init(launcher: Launcher = DefaultLauncher(), viewPresenterProvider: ViewPresenterProvider) {
    self.launcher = launcher
    self.viewPresenterProvider = viewPresenterProvider
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

    guard let presenter = viewPresenterProvider.viewPresenter else {
      completion(.success(.noUI))
      return
    }

    let session = URLLaunchSession(url: url, completion: completion)
    currentSession = session

    session.didFinish = { [weak self] in
      self?.currentSession = nil
    }
    presenter.present(session.safariViewController, animated: true, completion: nil)
  }

  func closeSafariViewController() {
    currentSession?.close()
  }
}
