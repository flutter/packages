// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v9.2.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

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
  return (value as Any) as! T?
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol UrlLauncherApi {
  /// Returns true if the URL can definitely be launched.
  func canLaunchUrl(url: String) throws -> Bool
  /// Opens the URL externally, returning true if successful.
  func launchUrl(
    url: String, universalLinksOnly: Bool, completion: @escaping (Result<Bool, Error>) -> Void)
  /// Opens the URL in an in-app SFSafariViewController, returning true
  /// when it has loaded successfully.
  func openUrlInSafariViewController(
    url: String, completion: @escaping (Result<Bool, Error>) -> Void)
  /// Closes the view controller opened by [openUrlInSafariViewController].
  func closeSafariViewController() throws
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class UrlLauncherApiSetup {
  /// The codec used by UrlLauncherApi.
  /// Sets up an instance of `UrlLauncherApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: UrlLauncherApi?) {
    /// Returns true if the URL can definitely be launched.
    let canLaunchUrlChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.UrlLauncherApi.canLaunchUrl", binaryMessenger: binaryMessenger)
    if let api = api {
      canLaunchUrlChannel.setMessageHandler { message, reply in
        let args = message as! [Any]
        let urlArg = args[0] as! String
        do {
          let result = try api.canLaunchUrl(url: urlArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      canLaunchUrlChannel.setMessageHandler(nil)
    }
    /// Opens the URL externally, returning true if successful.
    let launchUrlChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.UrlLauncherApi.launchUrl", binaryMessenger: binaryMessenger)
    if let api = api {
      launchUrlChannel.setMessageHandler { message, reply in
        let args = message as! [Any]
        let urlArg = args[0] as! String
        let universalLinksOnlyArg = args[1] as! Bool
        api.launchUrl(url: urlArg, universalLinksOnly: universalLinksOnlyArg) { result in
          switch result {
          case .success(let res):
            reply(wrapResult(res))
          case .failure(let error):
            reply(wrapError(error))
          }
        }
      }
    } else {
      launchUrlChannel.setMessageHandler(nil)
    }
    /// Opens the URL in an in-app SFSafariViewController, returning true
    /// when it has loaded successfully.
    let openUrlInSafariViewControllerChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.UrlLauncherApi.openUrlInSafariViewController",
      binaryMessenger: binaryMessenger)
    if let api = api {
      openUrlInSafariViewControllerChannel.setMessageHandler { message, reply in
        let args = message as! [Any]
        let urlArg = args[0] as! String
        api.openUrlInSafariViewController(url: urlArg) { result in
          switch result {
          case .success(let res):
            reply(wrapResult(res))
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
      name: "dev.flutter.pigeon.UrlLauncherApi.closeSafariViewController",
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
