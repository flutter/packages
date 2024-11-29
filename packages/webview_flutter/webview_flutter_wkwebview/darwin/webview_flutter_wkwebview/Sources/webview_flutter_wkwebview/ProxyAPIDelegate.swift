// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Implementation of `WebKitLibraryPigeonProxyApiDelegate` that provides each ProxyApi delegate implementation
/// and any additional resources needed by an implementation.
open class ProxyAPIDelegate: WebKitLibraryPigeonProxyApiDelegate {
  let assetManager: FlutterAssetManager = FlutterAssetManager()
  let bundle: Bundle = Bundle.main

  func createUnknownEnumError(withEnum enumValue: Any) -> PigeonError {
    return PigeonError(
      code: "UnknownEnumError", message: "\(enumValue) doesn't represent a native value.",
      details: nil)
  }
  
  func createUnsupportedVersionError(method: String, versionRequirements: String) -> PigeonError {
    return PigeonError(code: "FWFUnsupportedVersionError", message: createUnsupportedVersionMessage(method, versionRequirements: versionRequirements), details: nil)
  }
  
  func createUnsupportedVersionMessage(_ method: String, versionRequirements: String) -> String {
    return "`\(method)` requires \(versionRequirements)."
  }
  
  func createNullURLError(url: String) -> PigeonError {
    return PigeonError(code: "FWFURLParsingError", message: "Failed parsing file path.", details: "Initializing URL with the supplied '\(url)' path resulted in a nil value.")
  }
  
  func pigeonApiURLRequest(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLRequest {
    return PigeonApiURLRequest(pigeonRegistrar: registrar, delegate: URLRequestProxyAPIDelegate())
  }
  
  func pigeonApiHTTPURLResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiHTTPURLResponse {
    return PigeonApiHTTPURLResponse(pigeonRegistrar: registrar, delegate: HTTPURLResponseProxyAPIDelegate())
  }
  
  func pigeonApiWKUserScript(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKUserScript {
    return PigeonApiWKUserScript(pigeonRegistrar: registrar, delegate: UserScriptProxyAPIDelegate())
  }
  
  func pigeonApiWKNavigationAction(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKNavigationAction {
    return PigeonApiWKNavigationAction(pigeonRegistrar: registrar, delegate: NavigationActionProxyAPIDelegate())
  }
  
  func pigeonApiWKNavigationResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKNavigationResponse {
    return PigeonApiWKNavigationResponse(pigeonRegistrar: registrar, delegate: NavigationResponseProxyAPIDelegate())
  }
  
  func pigeonApiWKFrameInfo(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKFrameInfo {
    return PigeonApiWKFrameInfo(pigeonRegistrar: registrar, delegate: FrameInfoProxyAPIDelegate())
  }
  
  func pigeonApiNSError(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiNSError {
    return PigeonApiNSError(pigeonRegistrar: registrar, delegate: ErrorProxyAPIDelegate())
  }
  
  func pigeonApiWKScriptMessage(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKScriptMessage {
    return PigeonApiWKScriptMessage(pigeonRegistrar: registrar, delegate: ScriptMessageProxyAPIDelegate())
  }
  
  func pigeonApiWKSecurityOrigin(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKSecurityOrigin {
    return PigeonApiWKSecurityOrigin(pigeonRegistrar: registrar, delegate: SecurityOriginProxyAPIDelegate())
  }
  
  func pigeonApiHTTPCookie(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiHTTPCookie {
    return PigeonApiHTTPCookie(pigeonRegistrar: registrar, delegate: HTTPCookieProxyAPIDelegate())
  }
  
  func pigeonApiAuthenticationChallengeResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiAuthenticationChallengeResponse {
    return PigeonApiAuthenticationChallengeResponse(pigeonRegistrar: registrar, delegate: AuthenticationChallengeResponseProxyAPIDelegate())
  }
  
  func pigeonApiWKWebsiteDataStore(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebsiteDataStore {
    return PigeonApiWKWebsiteDataStore(pigeonRegistrar: registrar, delegate: WebsiteDataStoreProxyAPIDelegate())
  }
  
  func pigeonApiUIView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIView {
    return PigeonApiUIView(pigeonRegistrar: registrar, delegate: UIViewProxyAPIDelegate())
  }
  
  func pigeonApiUIScrollView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIScrollView {
    return PigeonApiUIScrollView(pigeonRegistrar: registrar, delegate: ScrollViewProxyAPIDelegate())
  }
  
  func pigeonApiWKWebViewConfiguration(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebViewConfiguration {
    return PigeonApiWKWebViewConfiguration(pigeonRegistrar: registrar, delegate: WebViewConfigurationProxyAPIDelegate())
  }
  
  func pigeonApiWKUserContentController(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKUserContentController {
    return PigeonApiWKUserContentController(pigeonRegistrar: registrar, delegate: UserContentControllerProxyAPIDelegate())
  }
  
  func pigeonApiWKPreferences(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKPreferences {
    return PigeonApiWKPreferences(pigeonRegistrar: registrar, delegate: PreferencesProxyAPIDelegate())
  }
  
  func pigeonApiWKScriptMessageHandler(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKScriptMessageHandler {
    return PigeonApiWKScriptMessageHandler(pigeonRegistrar: registrar, delegate: ScriptMessageHandlerProxyAPIDelegate())
  }
  
  func pigeonApiWKNavigationDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKNavigationDelegate {
    return PigeonApiWKNavigationDelegate(pigeonRegistrar: registrar, delegate: NavigationDelegateProxyAPIDelegate())
  }
  
  func pigeonApiNSObject(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiNSObject {
    return PigeonApiNSObject(pigeonRegistrar: registrar, delegate: NSObjectProxyAPIDelegate())
  }
  
  func pigeonApiUIViewWKWebView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIViewWKWebView {
    return PigeonApiUIViewWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())
  }
  
  func pigeonApiNSViewWKWebView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiNSViewWKWebView {
    return PigeonApiNSViewWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())
  }
  
  func pigeonApiWKWebView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebView {
    return PigeonApiWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())
  }
  
  func pigeonApiWKUIDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKUIDelegate {
    return PigeonApiWKUIDelegate(pigeonRegistrar: registrar, delegate: UIDelegateProxyAPIDelegate())
  }
  
  func pigeonApiWKHTTPCookieStore(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKHTTPCookieStore {
    return PigeonApiWKHTTPCookieStore(pigeonRegistrar: registrar, delegate: HTTPCookieStoreProxyAPIDelegate())
  }
  
  func pigeonApiUIScrollViewDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIScrollViewDelegate {
    return PigeonApiUIScrollViewDelegate(pigeonRegistrar: registrar, delegate: ScrollViewDelegateProxyAPIDelegate())
  }
  
  func pigeonApiURLCredential(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLCredential {
    return PigeonApiURLCredential(pigeonRegistrar: registrar, delegate: URLCredentialProxyAPIDelegate())
  }
  
  func pigeonApiURLProtectionSpace(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLProtectionSpace {
    return PigeonApiURLProtectionSpace(pigeonRegistrar: registrar, delegate: URLProtectionSpaceProxyAPIDelegate())
  }
  
  func pigeonApiURLAuthenticationChallenge(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLAuthenticationChallenge {
    return PigeonApiURLAuthenticationChallenge(pigeonRegistrar: registrar, delegate: URLAuthenticationChallengeProxyAPIDelegate())
  }
  
  func pigeonApiURL(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURL {
    return PigeonApiURL(pigeonRegistrar: registrar, delegate: URLProxyAPIDelegate())
  }
}
