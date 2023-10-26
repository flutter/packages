// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v11.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let flutterError = error as? FlutterError {
    return [
      flutterError.code,
      flutterError.message,
      flutterError.details,
    ]
  }
  return [
    "\(error)",
    "\(type(of: error))",
    "Stacktrace: \(Thread.callStackSymbols)",
  ]
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

/// Possible outcomes of launching a URL.
enum LaunchResult: Int {
  /// The URL was successfully launched (or could be, for `canLaunchUrl`).
  case success = 0
  /// There was no handler available for the URL.
  case failure = 1
  /// The URL could not be launched because it is invalid.
  case invalidUrl = 2
}

/// Possible outcomes of handling a URL within the application.
enum InAppLoadResult: Int {
  /// The URL was successfully loaded.
  case success = 0
  /// The URL did not load successfully.
  case failedToLoad = 1
  /// The URL could not be launched because it is invalid.
  case invalidUrl = 2
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol UrlLauncherApi {
  /// Checks whether a URL can be loaded.
  func canLaunchUrl(url: String) throws -> LaunchResult
  /// Opens the URL externally, returning the status of launching it.
  func launchUrl(
    url: String, universalLinksOnly: Bool,
    completion: @escaping (Result<LaunchResult, Error>) -> Void)
  /// Opens the URL in an in-app SFSafariViewController, returning the results
  /// of loading it.
  func openUrlInSafariViewController(
    url: String, completion: @escaping (Result<InAppLoadResult, Error>) -> Void)
  /// Closes the view controller opened by [openUrlInSafariViewController].
  func closeSafariViewController() throws
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class UrlLauncherApiSetup {
  /// The codec used by UrlLauncherApi.
  /// Sets up an instance of `UrlLauncherApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: UrlLauncherApi?) {
    /// Checks whether a URL can be loaded.
    let canLaunchUrlChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.url_launcher_ios.UrlLauncherApi.canLaunchUrl",
      binaryMessenger: binaryMessenger)
    if let api = api {
      canLaunchUrlChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let urlArg = args[0] as! String
        do {
          let result = try api.canLaunchUrl(url: urlArg)
          reply(wrapResult(result.rawValue))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      canLaunchUrlChannel.setMessageHandler(nil)
    }
    /// Opens the URL externally, returning the status of launching it.
    let launchUrlChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.url_launcher_ios.UrlLauncherApi.launchUrl",
      binaryMessenger: binaryMessenger)
    if let api = api {
      launchUrlChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let urlArg = args[0] as! String
        let universalLinksOnlyArg = args[1] as! Bool
        api.launchUrl(url: urlArg, universalLinksOnly: universalLinksOnlyArg) { result in
          switch result {
          case .success(let res):
            reply(wrapResult(res.rawValue))
          case .failure(let error):
            reply(wrapError(error))
          }
        }
      }
    } else {
      launchUrlChannel.setMessageHandler(nil)
    }
    /// Opens the URL in an in-app SFSafariViewController, returning the results
    /// of loading it.
    let openUrlInSafariViewControllerChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.url_launcher_ios.UrlLauncherApi.openUrlInSafariViewController",
      binaryMessenger: binaryMessenger)
    if let api = api {
      openUrlInSafariViewControllerChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let urlArg = args[0] as! String
        api.openUrlInSafariViewController(url: urlArg) { result in
          switch result {
          case .success(let res):
            reply(wrapResult(res.rawValue))
          case .failure(let error):
            reply(wrapError(error))
          }
        }
      }
    } else {
      openUrlInSafariViewControllerChannel.setMessageHandler(nil)
    }
    /// Closes the view controller opened by [openUrlInSafariViewController].
    let closeSafariViewControllerChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.url_launcher_ios.UrlLauncherApi.closeSafariViewController",
      binaryMessenger: binaryMessenger)
    if let api = api {
      closeSafariViewControllerChannel.setMessageHandler { _, reply in
        do {
          try api.closeSafariViewController()
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      closeSafariViewControllerChannel.setMessageHandler(nil)
    }
  }
}
