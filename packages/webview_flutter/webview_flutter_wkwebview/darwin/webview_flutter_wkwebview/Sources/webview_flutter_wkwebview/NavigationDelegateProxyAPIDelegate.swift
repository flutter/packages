// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// Implementation of `WKNavigationDelegate` that calls to Dart in callback methods.
class NavigationDelegateImpl: NSObject, WKNavigationDelegate {
  let api: PigeonApiProtocolWKNavigationDelegate
  let apiDelegate: ProxyAPIDelegate

  init(api: PigeonApiProtocolWKNavigationDelegate) {
    self.api = api
    self.apiDelegate = ((api as! PigeonApiWKNavigationDelegate).pigeonRegistrar.apiDelegate
                        as! ProxyAPIDelegate)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.didFinishNavigation(
        pigeonInstance: self, webView: webView, url: webView.url?.absoluteString
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFinishNavigation", error)
        }
      }
    }
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.didStartProvisionalNavigation(
        pigeonInstance: self, webView: webView, url: webView.url?.absoluteString
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didStartProvisionalNavigation", error)
        }
      }
    }
  }

  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
  ) {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.decidePolicyForNavigationAction(
        pigeonInstance: self, webView: webView, navigationAction: navigationAction
      ) { result in
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
              decisionHandler(.cancel)
              assertionFailure(
                self.apiDelegate.createUnsupportedVersionMessage(
                  "WKNavigationActionPolicy.download", versionRequirements: "iOS 14.5"))
            }
          }
        case .failure(let error):
          decisionHandler(.cancel)
          onFailure("WKNavigationDelegate.decidePolicyForNavigationAction", error)
        }
      }
    }
  }

  func webView(
    _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
    decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void
  ) {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.decidePolicyForNavigationResponse(
        pigeonInstance: self, webView: webView, navigationResponse: navigationResponse
      ) { result in
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
              decisionHandler(.cancel)
              assertionFailure(
                self.apiDelegate.createUnsupportedVersionMessage(
                  "WKNavigationResponsePolicy.download", versionRequirements: "iOS 14.5"))
            }
          }
        case .failure(let error):
          decisionHandler(.cancel)
          onFailure("WKNavigationDelegate.decidePolicyForNavigationResponse", error)
        }
      }
    }
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error)
  {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.didFailNavigation(pigeonInstance: self, webView: webView, error: error as NSError) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFailNavigation", error)
        }
      }
    }
  }

  func webView(
    _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
    withError error: any Error
  ) {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.didFailProvisionalNavigation(
        pigeonInstance: self, webView: webView, error: error as NSError
      ) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.didFailProvisionalNavigation", error)
        }
      }
    }
  }

  func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.webViewWebContentProcessDidTerminate(pigeonInstance: self, webView: webView) { result in
        if case .failure(let error) = result {
          onFailure("WKNavigationDelegate.webViewWebContentProcessDidTerminate", error)
        }
      }
    }
  }

  func webView(
    _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping @MainActor (URLSession.AuthChallengeDisposition, URLCredential?) ->
      Void
  ) {
    apiDelegate.dispatchOnMainThread { onFailure in
      self.api.didReceiveAuthenticationChallenge(
        pigeonInstance: self, webView: webView, challenge: challenge
      ) { result in
        switch result {
        case .success(let response):
          completionHandler(response.disposition, response.credential)
        case .failure(let error):
          completionHandler(.cancelAuthenticationChallenge, nil)
          onFailure("WKNavigationDelegate.didReceiveAuthenticationChallenge", error)
        }
      }
    }
  }
}

/// ProxyApi implementation for `WKNavigationDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NavigationDelegateProxyAPIDelegate: PigeonApiDelegateWKNavigationDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKNavigationDelegate) throws
    -> WKNavigationDelegate
  {
    return NavigationDelegateImpl(api: pigeonApi)
  }
}
