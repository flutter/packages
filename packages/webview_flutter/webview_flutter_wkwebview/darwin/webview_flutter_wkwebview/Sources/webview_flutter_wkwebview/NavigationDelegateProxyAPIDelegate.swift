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
        
      }
    }
  }

  func fixMe() {
    api.decidePolicyForNavigationResponse(pigeonInstance: self, webView: webView, navigationResponse: navigationResponse) {  _ in }
  }

  func fixMe() {
    api.didFailNavigation(pigeonInstance: self, webView: webView, error: error) {  _ in }
  }

  func fixMe() {
    api.didFailProvisionalNavigation(pigeonInstance: self, webView: webView, error: error) {  _ in }
  }

  func fixMe() {
    api.webViewWebContentProcessDidTerminate(pigeonInstance: self, webView: webView) {  _ in }
  }

  func fixMe() {
    api.didReceiveAuthenticationChallenge(pigeonInstance: self, webView: webView, challenge: challenge) {  _ in }
  }
}

/// ProxyApi implementation for `WKNavigationDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NavigationDelegateProxyAPIDelegate : PigeonApiDelegateWKNavigationDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKNavigationDelegate) throws -> WKNavigationDelegate {
    return WKNavigationDelegateImpl(api: pigeonApi)
  }
}
