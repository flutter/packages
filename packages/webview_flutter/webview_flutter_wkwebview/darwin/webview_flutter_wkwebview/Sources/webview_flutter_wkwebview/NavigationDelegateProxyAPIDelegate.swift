// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit

/// Implementation of `WKNavigationDelegate` that calls to Dart in callback methods.
class NavigationDelegateImpl: NSObject, WKNavigationDelegate {
  let api: PigeonApiProtocolWKNavigationDelegate

  init(api: PigeonApiProtocolWKNavigationDelegate) {
    self.api = api
  }
  
  func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
    api.didFinishNavigation(pigeonInstance: self, webView: webView, url: webView.url?.absoluteString) {  _ in }
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    api.didStartProvisionalNavigation(pigeonInstance: self, webView: webView, url: webView.url?.absoluteString) {  _ in }
  }
  
  func webView(
      _ webView: WKWebView,
      decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
  ) {
    api.decidePolicyForNavigationAction(pigeonInstance: self, webView: webView, navigationAction: navigationAction) { result in
      switch result {
      case .success(let policy):
        switch policy {
        case .allow:
          decisionHandler(.allow)
        case .cancel:
          decisionHandler(.cancel)
        case .download:
          if #available(iOS 14.5, *) {
            decisionHandler(.download)
          } else {
            let apiDelegate = ((self.api as! PigeonApiWKNavigationDelegate).pigeonRegistrar.apiDelegate as! ProxyAPIDelegate)
            assertionFailure(apiDelegate.createUnsupportedVersionMessage("WKNavigationActionPolicy.download", versionRequirements: "iOS 14.5"))
          }
        }
      case .failure(let error):
        assertionFailure("\(error)")
      }
    }
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
    api.decidePolicyForNavigationResponse(pigeonInstance: self, webView: webView, navigationResponse: navigationResponse) { result in
      switch result {
      case .success(let policy):
        switch policy {
        case .allow:
          decisionHandler(.allow)
        case .cancel:
          decisionHandler(.cancel)
        case .download:
          if #available(iOS 14.5, *) {
            decisionHandler(.download)
          } else {
            let apiDelegate = ((self.api as! PigeonApiWKNavigationDelegate).pigeonRegistrar.apiDelegate as! ProxyAPIDelegate)
            assertionFailure(apiDelegate.createUnsupportedVersionMessage("WKNavigationResponsePolicy.download", versionRequirements: "iOS 14.5"))
          }
        }
      case .failure(let error):
        assertionFailure("\(String(describing: error)): \(String(describing: error.message))")
      }
    }
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
    api.didFailNavigation(pigeonInstance: self, webView: webView, error: error as NSError) {  _ in }
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
    api.didFailProvisionalNavigation(pigeonInstance: self, webView: webView, error: error as NSError) {  _ in }
  }
  
  func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    api.webViewWebContentProcessDidTerminate(pigeonInstance: self, webView: webView) {  _ in }
  }

  func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    api.didReceiveAuthenticationChallenge(pigeonInstance: self, webView: webView, challenge: challenge) { result in
      switch result {
      case .success(let response):
        completionHandler(response.disposition, response.credential)
      case .failure(let error):
        assertionFailure("\(error)")
      }
    }
  }
}

/// ProxyApi implementation for `WKNavigationDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NavigationDelegateProxyAPIDelegate : PigeonApiDelegateWKNavigationDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKNavigationDelegate) throws -> WKNavigationDelegate {
    return NavigationDelegateImpl(api: pigeonApi)
  }
}
