// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Implementation of `WebKitLibraryPigeonProxyApiDelegate` that provides each ProxyApi delegate implementation
/// and any additional resources needed by an implementation.
open class ProxyAPIDelegate: WebKitLibraryPigeonProxyApiDelegate {
  func createUnknownEnumError(withEnum enumValue: Any) -> PigeonError {
    return PigeonError(
      code: "UnknownEnumError", message: "\(enumValue) doesn't represent a native value.",
      details: nil)
  }
  
  func pigeonApiURLRequest(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLRequest {
    return PigeonApiURLRequest(pigeonRegistrar: registrar, delegate: URLRequestProxyAPIDelegate())
  }
  
  func pigeonApiHTTPURLResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiHTTPURLResponse {
    PigeonApiHTTPURLResponse(pigeonRegistrar: registrar, delegate: HTTPURLResponseProxyAPIDelegate())
  }
  
  func pigeonApiWKUserScript(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKUserScript {
    return PigeonApiWKUserScript(pigeonRegistrar: registrar, delegate: UserScriptProxyAPIDelegate())
  }
  
  func pigeonApiWKNavigationAction(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKNavigationAction {
    return PigeonApiWKNavigationAction(pigeonRegistrar: registrar, delegate: NavigationActionProxyAPIDelegate())
  }
  
  func pigeonApiWKNavigationResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKNavigationResponse {
    PigeonApiWKNavigationResponse(pigeonRegistrar: registrar, delegate: NavigationResponseProxyAPIDelegate())
  }
  
  func pigeonApiWKFrameInfo(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKFrameInfo {
    PigeonApiWKFrameInfo(pigeonRegistrar: registrar, delegate: FrameInfoProxyAPIDelegate())
  }
  
  func pigeonApiNSError(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiNSError {
    PigeonApiNSError(pigeonRegistrar: registrar, delegate: ErrorProxyAPIDelegate())
  }
  
  func pigeonApiWKScriptMessage(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKScriptMessage {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKSecurityOrigin(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKSecurityOrigin {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiHTTPCookie(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiHTTPCookie {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiAuthenticationChallengeResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiAuthenticationChallengeResponse {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKWebsiteDataStore(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebsiteDataStore {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiUIView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIView {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiUIScrollView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIScrollView {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKWebViewConfiguration(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebViewConfiguration {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKUserContentController(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKUserContentController {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKPreferences(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKPreferences {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKScriptMessageHandler(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKScriptMessageHandler {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKNavigationDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKNavigationDelegate {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiNSObject(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiNSObject {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKWebViewUIExtensions(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebViewUIExtensions {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKWebView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebView {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKUIDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKUIDelegate {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiWKHTTPCookieStore(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKHTTPCookieStore {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiUIScrollViewDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIScrollViewDelegate {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiURLCredential(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLCredential {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiURLProtectionSpace(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLProtectionSpace {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiURLAuthenticationChallenge(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLAuthenticationChallenge {
    throw PigeonError(code: "", message: "", details: "")
  }
  
  func pigeonApiURL(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURL {
    throw PigeonError(code: "", message: "", details: "")
  }
}
