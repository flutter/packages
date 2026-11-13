// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

public final class URLLauncherPlugin: NSObject, FlutterPlugin, UrlLauncherApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = URLLauncherPlugin(
      viewPresenterProvider: DefaultViewPresenterProvider(registrar: registrar))
    UrlLauncherApiSetup.register(api: plugin, registrar: registrar)
    registrar.publish(plugin)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    UrlLauncherApiSetup.unregister(api: self, registrar: registrar)
  }

  private var currentSession: URLLaunchSession?
  private let launcher: Launcher
  /// The view presenter provider, for showing a Safari view controller.
  private let viewPresenterProvider: ViewPresenterProvider

  init(launcher: Launcher = DefaultLauncher(), viewPresenterProvider: ViewPresenterProvider) {
    self.launcher = launcher
    self.viewPresenterProvider = viewPresenterProvider
  }

  func canLaunchUrl(url: String) throws -> LaunchResult {
    guard let url = URL(string: url) else {
      return .invalidUrl
    }
    let canOpen = launcher.canOpenURL(url)
    return canOpen ? .success : .failure
  }

  func launchUrl(url: String, universalLinksOnly: Bool) async throws -> LaunchResult {
    guard let url = URL(string: url) else {
      return .invalidUrl
    }
    let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: universalLinksOnly]
    // `UIApplication.open` must be called on the main thread, which native interop calls aren't
    // guaranteed to already be running on for `async` methods.
    let opened = await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        self.launcher.open(url, options: options) { result in
          continuation.resume(returning: result)
        }
      }
    }
    return opened ? .success : .failure
  }

  func openUrlInSafariViewController(url: String) async throws -> InAppLoadResult {
    guard let url = URL(string: url) else {
      return .invalidUrl
    }

    // Presenting a view controller must happen on the main thread, which native interop calls
    // aren't guaranteed to already be running on for `async` methods.
    return await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        guard let presenter = self.viewPresenterProvider.viewPresenter else {
          continuation.resume(returning: .noUI)
          return
        }

        let session = URLLaunchSession(url: url) { result in
          switch result {
          case .success(let value):
            continuation.resume(returning: value)
          case .failure:
            continuation.resume(returning: .failedToLoad)
          }
        }
        self.currentSession = session

        session.didFinish = { [weak self] in
          self?.currentSession = nil
        }
        presenter.present(session.safariViewController, animated: true, completion: nil)
      }
    }
  }

  func closeSafariViewController() throws {
    // Dismissing a view controller must happen on the main thread.
    DispatchQueue.main.async {
      self.currentSession?.close()
    }
  }
}
