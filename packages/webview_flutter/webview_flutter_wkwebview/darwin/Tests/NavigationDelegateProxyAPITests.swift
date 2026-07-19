// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct NavigationDelegateProxyAPITests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    #expect(instance != nil)
  }

  @MainActor @Test func didFinishNavigation() throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = TestWebView(frame: .zero)

    instance.webView(webView, didFinish: nil)

    #expect(api.didFinishNavigationArgs == [webView, webView.url?.absoluteString])
  }

  @MainActor @Test func didStartProvisionalNavigation() throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = TestWebView(frame: .zero)
    instance.webView(webView, didStartProvisionalNavigation: nil)

    #expect(api.didStartProvisionalNavigationArgs == [webView, webView.url?.absoluteString])
  }

  @MainActor @Test func decidePolicyForNavigationAction() async throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationAction = TestNavigationAction()

    let result = await withCheckedContinuation { continuation in
      instance.webView(webView, decidePolicyFor: navigationAction) { policy in
        continuation.resume(returning: policy)
      }
    }

    #expect(api.decidePolicyForNavigationActionArgs == [webView, navigationAction])
    #expect(result == .allow)
  }

  @MainActor @Test func decidePolicyForNavigationResponse() async throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationResponse = TestNavigationResponse.instance

    let result = await withCheckedContinuation { continuation in
      instance.webView(webView, decidePolicyFor: navigationResponse) { policy in
        continuation.resume(returning: policy)
      }
    }

    #expect(api.decidePolicyForNavigationResponseArgs == [webView, navigationResponse])
    #expect(result == .cancel)
  }

  @MainActor @Test func didFailNavigation() throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let error = NSError(domain: "", code: 12)
    instance.webView(webView, didFail: nil, withError: error)

    #expect(api.didFailNavigationArgs == [webView, error])
  }

  @MainActor @Test func didFailProvisionalNavigation() throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let error = NSError(domain: "", code: 12)
    instance.webView(webView, didFailProvisionalNavigation: nil, withError: error)

    #expect(api.didFailProvisionalNavigationArgs == [webView, error])
  }

  @MainActor @Test func webViewWebContentProcessDidTerminate() throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    instance.webViewWebContentProcessDidTerminate(webView)

    #expect(api.webViewWebContentProcessDidTerminateArgs == [webView])
  }

  @MainActor @Test func didReceiveAuthenticationChallenge() async throws {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let challenge = URLAuthenticationChallenge(
      protectionSpace: URLProtectionSpace(), proposedCredential: nil, previousFailureCount: 3,
      failureResponse: nil, error: nil, sender: TestURLAuthenticationChallengeSender())

    let (dispositionResult, credentialResult) = await withCheckedContinuation { continuation in
      instance.webView(webView, didReceive: challenge) { disposition, credential in
        continuation.resume(returning: (disposition, credential))
      }
    }

    #expect(api.didReceiveAuthenticationChallengeArgs == [webView, challenge])
    #expect(dispositionResult == .useCredential)
    #expect(credentialResult?.user == "user1")
    #expect(credentialResult?.password == "password1")
    #expect(credentialResult?.persistence == URLCredential.Persistence.none)
  }
}

class TestNavigationDelegateApi: PigeonApiProtocolWKNavigationDelegate {
  var didFinishNavigationArgs: [AnyHashable?]? = nil
  var didStartProvisionalNavigationArgs: [AnyHashable?]? = nil
  var decidePolicyForNavigationActionArgs: [AnyHashable?]? = nil
  var decidePolicyForNavigationResponseArgs: [AnyHashable?]? = nil
  var didFailNavigationArgs: [AnyHashable?]? = nil
  var didFailProvisionalNavigationArgs: [AnyHashable?]? = nil
  var webViewWebContentProcessDidTerminateArgs: [AnyHashable?]? = nil
  var didReceiveAuthenticationChallengeArgs: [AnyHashable?]? = nil

  func registrar() -> ProxyAPIDelegate {
    return ProxyAPIDelegate()
  }

  func didFinishNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    url urlArg: String?,
    completion: @escaping (Result<Void, webview_flutter_wkwebview.PigeonError>) -> Void
  ) {
    didFinishNavigationArgs = [webViewArg, urlArg]
  }

  func didStartProvisionalNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    url urlArg: String?,
    completion: @escaping (Result<Void, webview_flutter_wkwebview.PigeonError>) -> Void
  ) {
    didStartProvisionalNavigationArgs = [webViewArg, urlArg]
  }

  func decidePolicyForNavigationAction(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    navigationAction navigationActionArg: WKNavigationAction,
    completion:
      @escaping (
        Result<
          webview_flutter_wkwebview.NavigationActionPolicy, webview_flutter_wkwebview.PigeonError
        >
      ) -> Void
  ) {
    decidePolicyForNavigationActionArgs = [webViewArg, navigationActionArg]
    completion(.success(.allow))
  }

  func decidePolicyForNavigationResponse(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    navigationResponse navigationResponseArg: WKNavigationResponse,
    completion:
      @escaping (
        Result<
          webview_flutter_wkwebview.NavigationResponsePolicy, webview_flutter_wkwebview.PigeonError
        >
      ) -> Void
  ) {
    decidePolicyForNavigationResponseArgs = [webViewArg, navigationResponseArg]
    completion(.success(.cancel))
  }

  func didFailNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    error errorArg: NSError,
    completion: @escaping (Result<Void, webview_flutter_wkwebview.PigeonError>) -> Void
  ) {
    didFailNavigationArgs = [webViewArg, errorArg]
  }

  func didFailProvisionalNavigation(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    error errorArg: NSError,
    completion: @escaping (Result<Void, webview_flutter_wkwebview.PigeonError>) -> Void
  ) {
    didFailProvisionalNavigationArgs = [webViewArg, errorArg]
  }

  func webViewWebContentProcessDidTerminate(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    completion: @escaping (Result<Void, webview_flutter_wkwebview.PigeonError>) -> Void
  ) {
    webViewWebContentProcessDidTerminateArgs = [webViewArg]
  }

  func didReceiveAuthenticationChallenge(
    pigeonInstance pigeonInstanceArg: WKNavigationDelegate, webView webViewArg: WKWebView,
    challenge challengeArg: URLAuthenticationChallenge,
    completion:
      @escaping (
        Result<
          webview_flutter_wkwebview.AuthenticationChallengeResponse,
          webview_flutter_wkwebview.PigeonError
        >
      ) -> Void
  ) {
    didReceiveAuthenticationChallengeArgs = [webViewArg, challengeArg]
    completion(
      .success(
        AuthenticationChallengeResponse(
          disposition: .useCredential,
          credential: URLCredential(user: "user1", password: "password1", persistence: .none))))
  }
}

class TestWebView: WKWebView {
  override var url: URL? {
    return URL(string: "http://google.com")
  }
}

class TestURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender,
  @unchecked Sendable
{
  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {

  }

  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {

  }

  func cancel(_ challenge: URLAuthenticationChallenge) {

  }
}
