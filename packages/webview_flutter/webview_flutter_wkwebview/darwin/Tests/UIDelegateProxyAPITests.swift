// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

class UIDelegateProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUIDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  @MainActor func testOnCreateWebView() {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let configuration = WKWebViewConfiguration()
    let navigationAction = TestNavigationAction()

    let result = instance.webView(
      webView, createWebViewWith: configuration, for: navigationAction,
      windowFeatures: WKWindowFeatures())

    XCTAssertEqual(api.onCreateWebViewArgs, [webView, configuration, navigationAction])
    XCTAssertNil(result)
  }

  @available(iOS 15.0, macOS 12.0, *)
  @MainActor func testRequestMediaCapturePermission() {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let origin = SecurityOriginProxyAPITests.testSecurityOrigin
    let frame = TestFrameInfo()
    let type: WKMediaCaptureType = .camera

    var resultDecision: WKPermissionDecision?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(
      webView, requestMediaCapturePermissionFor: origin, initiatedByFrame: frame, type: type
    ) { decision in
      resultDecision = decision
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(
      api.requestMediaCapturePermissionArgs, [webView, origin, frame, MediaCaptureType.camera])
    XCTAssertEqual(resultDecision, .prompt)
  }

  @MainActor func testRunJavaScriptAlertPanel() {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let message = "myString"
    let frame = TestFrameInfo()

    instance.webView(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame)
    {
    }

    XCTAssertEqual(api.runJavaScriptAlertPanelArgs, [webView, message, frame])
  }

  @MainActor func testRunJavaScriptConfirmPanel() {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let message = "myString"
    let frame = TestFrameInfo()

    var confirmedResult: Bool?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(
      webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame
    ) { confirmed in
      confirmedResult = confirmed
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.runJavaScriptConfirmPanelArgs, [webView, message, frame])
    XCTAssertEqual(confirmedResult, true)
  }

  @MainActor func testRunJavaScriptTextInputPanel() {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let prompt = "myString"
    let defaultText = "myString3"
    let frame = TestFrameInfo()

    var inputResult: String?
    let callbackExpectation = expectation(description: "Wait for callback.")
    instance.webView(
      webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText,
      initiatedByFrame: frame
    ) { input in
      inputResult = input
      callbackExpectation.fulfill()
    }

    wait(for: [callbackExpectation], timeout: 1.0)

    XCTAssertEqual(api.runJavaScriptTextInputPanelArgs, [webView, prompt, defaultText, frame])
    XCTAssertEqual(inputResult, "myString2")
  }
}

class TestDelegateApi: PigeonApiProtocolWKUIDelegate {
  var onCreateWebViewArgs: [AnyHashable?]? = nil
  var requestMediaCapturePermissionArgs: [AnyHashable?]? = nil
  var runJavaScriptAlertPanelArgs: [AnyHashable?]? = nil
  var runJavaScriptConfirmPanelArgs: [AnyHashable?]? = nil
  var runJavaScriptTextInputPanelArgs: [AnyHashable?]? = nil

  func onCreateWebView(
    pigeonInstance pigeonInstanceArg: WKUIDelegate, webView webViewArg: WKWebView,
    configuration configurationArg: WKWebViewConfiguration,
    navigationAction navigationActionArg: WKNavigationAction,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    onCreateWebViewArgs = [webViewArg, configurationArg, navigationActionArg]
  }

  func requestMediaCapturePermission(
    pigeonInstance pigeonInstanceArg: WKUIDelegate, webView webViewArg: WKWebView,
    origin originArg: WKSecurityOrigin, frame frameArg: WKFrameInfo, type typeArg: MediaCaptureType,
    completion: @escaping (Result<PermissionDecision, PigeonError>) -> Void
  ) {
    requestMediaCapturePermissionArgs = [webViewArg, originArg, frameArg, typeArg]
    completion(.success(.prompt))
  }

  func runJavaScriptAlertPanel(
    pigeonInstance pigeonInstanceArg: WKUIDelegate, webView webViewArg: WKWebView,
    message messageArg: String, frame frameArg: WKFrameInfo,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    runJavaScriptAlertPanelArgs = [webViewArg, messageArg, frameArg]
  }

  func runJavaScriptConfirmPanel(
    pigeonInstance pigeonInstanceArg: WKUIDelegate, webView webViewArg: WKWebView,
    message messageArg: String, frame frameArg: WKFrameInfo,
    completion: @escaping (Result<Bool, PigeonError>) -> Void
  ) {
    runJavaScriptConfirmPanelArgs = [webViewArg, messageArg, frameArg]
    completion(.success(true))
  }

  func runJavaScriptTextInputPanel(
    pigeonInstance pigeonInstanceArg: WKUIDelegate, webView webViewArg: WKWebView,
    prompt promptArg: String, defaultText defaultTextArg: String?, frame frameArg: WKFrameInfo,
    completion: @escaping (Result<String?, PigeonError>) -> Void
  ) {
    runJavaScriptTextInputPanelArgs = [webViewArg, promptArg, defaultTextArg, frameArg]
    completion(.success("myString2"))
  }
}
