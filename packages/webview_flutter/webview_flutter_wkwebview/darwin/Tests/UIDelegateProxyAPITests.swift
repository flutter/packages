// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

@Suite struct UIDelegateProxyAPITests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiWKUIDelegate(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    #expect(instance != nil)
  }

  @MainActor @Test func onCreateWebView() throws {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let configuration = WKWebViewConfiguration()
    let navigationAction = TestNavigationAction()

    let result = instance.webView(
      webView, createWebViewWith: configuration, for: navigationAction,
      windowFeatures: WKWindowFeatures())

    #expect(api.onCreateWebViewArgs == [webView, configuration, navigationAction])
    #expect(result == nil)
  }

  @available(iOS 15.0, macOS 12.0, *)
  @MainActor @Test func requestMediaCapturePermission() async throws {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let origin = SecurityOriginProxyAPITests.testSecurityOrigin
    let frame = TestFrameInfo.instance
    let type: WKMediaCaptureType = .camera

    let resultDecision = await withCheckedContinuation { continuation in
      instance.webView(
        webView, requestMediaCapturePermissionFor: origin, initiatedByFrame: frame, type: type
      ) { decision in
        continuation.resume(returning: decision)
      }
    }

    #expect(
      api.requestMediaCapturePermissionArgs == [webView, origin, frame, MediaCaptureType.camera])
    #expect(resultDecision == .prompt)
  }

  @MainActor @Test func runJavaScriptAlertPanel() throws {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let message = "myString"
    let frame = TestFrameInfo.instance

    instance.webView(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame)
    {
    }

    #expect(api.runJavaScriptAlertPanelArgs == [webView, message, frame])
  }

  @MainActor @Test func runJavaScriptConfirmPanel() async throws {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let message = "myString"
    let frame = TestFrameInfo.instance

    let confirmedResult = await withCheckedContinuation { continuation in
      instance.webView(
        webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame
      ) { confirmed in
        continuation.resume(returning: confirmed)
      }
    }

    #expect(api.runJavaScriptConfirmPanelArgs == [webView, message, frame])
    #expect(confirmedResult == true)
  }

  @MainActor @Test func runJavaScriptTextInputPanel() async throws {
    let api = TestDelegateApi()
    let registrar = TestProxyApiRegistrar()
    let instance = UIDelegateImpl(api: api, registrar: registrar)
    let webView = WKWebView(frame: .zero)
    let prompt = "myString"
    let defaultText = "myString3"
    let frame = TestFrameInfo.instance

    let inputResult = await withCheckedContinuation { continuation in
      instance.webView(
        webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText,
        initiatedByFrame: frame
      ) { input in
        continuation.resume(returning: input)
      }
    }

    #expect(api.runJavaScriptTextInputPanelArgs == [webView, prompt, defaultText, frame])
    #expect(inputResult == "myString2")
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
