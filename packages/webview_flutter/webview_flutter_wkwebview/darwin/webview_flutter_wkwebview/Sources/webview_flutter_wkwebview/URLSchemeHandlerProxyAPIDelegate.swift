// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// Tracks whether a `WKURLSchemeTask` has been stopped by the web view.
///
/// Calling any method of a `WKURLSchemeTask` after the web view has requested
/// the task be stopped raises an `NSException`, so calls coming from Dart must
/// be ignored after `webView(_:stop:)`. The flag is stored as an associated
/// object, so its lifetime is tied to the task instance. All access happens on
/// the main thread (both `WKURLSchemeHandler` callbacks and platform channel
/// messages), so no synchronization is needed.
enum URLSchemeTaskState {
  private static var stoppedAssociationKey: UInt8 = 0

  static func markStopped(_ task: WKURLSchemeTask) {
    objc_setAssociatedObject(
      task, &stoppedAssociationKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }

  static func isStopped(_ task: WKURLSchemeTask) -> Bool {
    return objc_getAssociatedObject(task, &stoppedAssociationKey) as? Bool ?? false
  }
}

/// Implementation of `WKURLSchemeHandler` that calls to Dart in callback methods.
class URLSchemeHandlerImpl: NSObject, WKURLSchemeHandler {
  let api: PigeonApiProtocolWKURLSchemeHandler
  unowned let registrar: ProxyAPIRegistrar

  init(api: PigeonApiProtocolWKURLSchemeHandler, registrar: ProxyAPIRegistrar) {
    self.api = api
    self.registrar = registrar
  }

  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    registrar.dispatchOnMainThread { onFailure in
      self.api.startUrlSchemeTask(
        pigeonInstance: self, webView: webView, urlSchemeTask: urlSchemeTask
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKURLSchemeHandler.startUrlSchemeTask", error)
        }
      }
    }
  }

  func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    URLSchemeTaskState.markStopped(urlSchemeTask)
    registrar.dispatchOnMainThread { onFailure in
      self.api.stopUrlSchemeTask(
        pigeonInstance: self, webView: webView, urlSchemeTask: urlSchemeTask
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKURLSchemeHandler.stopUrlSchemeTask", error)
        }
      }
    }
  }
}

/// ProxyApi implementation for `WKURLSchemeHandler`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLSchemeHandlerProxyAPIDelegate: PigeonApiDelegateWKURLSchemeHandler {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKURLSchemeHandler) throws
    -> WKURLSchemeHandler
  {
    return URLSchemeHandlerImpl(
      api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
  }
}
