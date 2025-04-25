// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class NavigationDelegateProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKNavigationDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  @MainActor func testDidFinishNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = TestWebView(frame: .zero)

    instance.webView(webView, didFinish: nil)

    XCTAssertEqual(api.didFinishNavigationArgs, [webView, webView.url?.absoluteString])
  }

  @MainActor func testDidStartProvisionalNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = TestWebView(frame: .zero)
    instance.webView(webView, didStartProvisionalNavigation: nil)

    XCTAssertEqual(api.didStartProvisionalNavigationArgs, [webView, webView.url?.absoluteString])
  }

  @MainActor func testDecidePolicyForNavigationAction() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationAction = TestNavigationAction()

    let callbackExpectation = expectation(description: "Wait for callback.")
    var result: WKNavigationActionPolicy?
    instance.webView(webView, decidePolicyFor: navigationAction) { policy in
      result = policy
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.decidePolicyForNavigationActionArgs, [webView, navigationAction])
    XCTAssertEqual(result, .allow)
  }

  @MainActor func testDecidePolicyForNavigationResponse() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let navigationResponse = TestNavigationResponse()

    var result: WKNavigationResponsePolicy?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(webView, decidePolicyFor: navigationResponse) { policy in
      result = policy
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.decidePolicyForNavigationResponseArgs, [webView, navigationResponse])
    XCTAssertEqual(result, .cancel)
  }

  @MainActor func testDidFailNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let error = NSError(domain: "", code: 12)
    instance.webView(webView, didFail: nil, withError: error)

    XCTAssertEqual(api.didFailNavigationArgs, [webView, error])
  }

  @MainActor func testDidFailProvisionalNavigation() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let error = NSError(domain: "", code: 12)
    instance.webView(webView, didFailProvisionalNavigation: nil, withError: error)

    XCTAssertEqual(api.didFailProvisionalNavigationArgs, [webView, error])
  }

  @MainActor func testWebViewWebContentProcessDidTerminate() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    instance.webViewWebContentProcessDidTerminate(webView)

    XCTAssertEqual(api.webViewWebContentProcessDidTerminateArgs, [webView])
  }

  @MainActor func testDidReceiveAuthenticationChallenge() {
    let api = TestNavigationDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = NavigationDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let challenge = URLAuthenticationChallenge(
      protectionSpace: URLProtectionSpace(), proposedCredential: nil, previousFailureCount: 3,
      failureResponse: nil, error: nil, sender: TestURLAuthenticationChallengeSender())

    var dispositionResult: URLSession.AuthChallengeDisposition?
    var credentialResult: URLCredential?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(webView, didReceive: challenge) { disposition, credential in
      dispositionResult = disposition
      credentialResult = credential
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.didReceiveAuthenticationChallengeArgs, [webView, challenge])
    XCTAssertEqual(dispositionResult, .useCredential)
    XCTAssertEqual(credentialResult?.user, "user1")
    XCTAssertEqual(credentialResult?.password, "password1")
    XCTAssertEqual(credentialResult?.persistence, URLCredential.Persistence.none)
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
    completion: @escaping (
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
    completion: @escaping (
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
    completion: @escaping (
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

class TestURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender, @unchecked
  Sendable
{
  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {

  }

  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {

  }

  func cancel(_ challenge: URLAuthenticationChallenge) {

  }
}
