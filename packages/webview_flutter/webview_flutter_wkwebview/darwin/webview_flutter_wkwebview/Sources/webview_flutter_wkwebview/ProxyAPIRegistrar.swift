// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
  import Foundation
#else
  #error("Unsupported platform.")
#endif

/// Implementation of `WebKitLibraryPigeonProxyApiRegistrar` that provides any additional resources needed by API implementations.
open class ProxyAPIRegistrar: WebKitLibraryPigeonProxyApiRegistrar {
  let assetManager = FlutterAssetManager()
  let bundle: Bundle

  init(binaryMessenger: FlutterBinaryMessenger, bundle: Bundle = Bundle.main) {
    self.bundle = bundle
    super.init(binaryMessenger: binaryMessenger, apiDelegate: ProxyAPIDelegate())
  }

  /// Creates an error when the `unknown` enum value is passed to a host method.
  func createUnknownEnumError(withEnum enumValue: Any) -> PigeonError {
    return PigeonError(
      code: "UnknownEnumError", message: "\(enumValue) doesn't represent a native value.",
      details: nil)
  }

  /// Creates an error when a method is called on an unsupported version.
  func createUnsupportedVersionError(method: String, versionRequirements: String) -> PigeonError {
    return PigeonError(
      code: "FWFUnsupportedVersionError",
      message: createUnsupportedVersionMessage(method, versionRequirements: versionRequirements),
      details: nil)
  }

  /// Creates the error message when a method is called on an unsupported version.
  func createUnsupportedVersionMessage(_ method: String, versionRequirements: String) -> String {
    return "`\(method)` requires \(versionRequirements)."
  }

  // Creates an error when the constructor of a URL returns null.
  //
  // New methods should use `createConstructorNullError`, but this stays
  // to keep error code consistent with previous plugin versions.
  fileprivate func createNullURLError(url: String) -> PigeonError {
    return PigeonError(
      code: "FWFURLParsingError", message: "Failed parsing file path.",
      details: "Initializing URL with the supplied '\(url)' path resulted in a nil value.")
  }

  /// Creates an error when the constructor of a class returns null.
  func createConstructorNullError(type: Any.Type, parameters: [String: Any?]) -> PigeonError {
    if type == URL.self && parameters["string"] != nil {
      return createNullURLError(url: parameters["string"] as! String)
    }

    return PigeonError(
      code: "ConstructorReturnedNullError",
      message: "Failed to instantiate `\(String(describing: type))` with parameters: \(parameters)",
      details: nil)
  }

  // Creates an assertion failure when a Flutter method receives an error from Dart.
  fileprivate func assertFlutterMethodFailure(_ error: PigeonError, methodName: String) {
    assertionFailure(
      "\(String(describing: error)): Error returned from calling \(methodName): \(String(describing: error.message))"
    )
  }

  /// Handles calling a Flutter method on the main thread.
  func dispatchOnMainThread(
    execute work: @escaping (
      _ onFailure: @escaping (_ methodName: String, _ error: PigeonError) -> Void
    ) -> Void
  ) {
    DispatchQueue.main.async {
      work { methodName, error in
        self.assertFlutterMethodFailure(error, methodName: methodName)
      }
    }
  }
}

/// Implementation of `WebKitLibraryPigeonProxyApiDelegate` that provides each ProxyApi delegate implementation.
class ProxyAPIDelegate: WebKitLibraryPigeonProxyApiDelegate {
  func pigeonApiURLRequest(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURLRequest
  {
    return PigeonApiURLRequest(pigeonRegistrar: registrar, delegate: URLRequestProxyAPIDelegate())
  }

  func pigeonApiHTTPURLResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiHTTPURLResponse
  {
    return PigeonApiHTTPURLResponse(
      pigeonRegistrar: registrar, delegate: HTTPURLResponseProxyAPIDelegate())
  }

  func pigeonApiWKUserScript(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKUserScript
  {
    return PigeonApiWKUserScript(pigeonRegistrar: registrar, delegate: UserScriptProxyAPIDelegate())
  }

  func pigeonApiWKNavigationAction(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKNavigationAction
  {
    return PigeonApiWKNavigationAction(
      pigeonRegistrar: registrar, delegate: NavigationActionProxyAPIDelegate())
  }

  func pigeonApiWKNavigationResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKNavigationResponse
  {
    return PigeonApiWKNavigationResponse(
      pigeonRegistrar: registrar, delegate: NavigationResponseProxyAPIDelegate())
  }

  func pigeonApiWKFrameInfo(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKFrameInfo
  {
    return PigeonApiWKFrameInfo(pigeonRegistrar: registrar, delegate: FrameInfoProxyAPIDelegate())
  }

  func pigeonApiNSError(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiNSError {
    return PigeonApiNSError(pigeonRegistrar: registrar, delegate: ErrorProxyAPIDelegate())
  }

  func pigeonApiWKScriptMessage(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKScriptMessage
  {
    return PigeonApiWKScriptMessage(
      pigeonRegistrar: registrar, delegate: ScriptMessageProxyAPIDelegate())
  }

  func pigeonApiWKSecurityOrigin(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKSecurityOrigin
  {
    return PigeonApiWKSecurityOrigin(
      pigeonRegistrar: registrar, delegate: SecurityOriginProxyAPIDelegate())
  }

  func pigeonApiHTTPCookie(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiHTTPCookie
  {
    return PigeonApiHTTPCookie(pigeonRegistrar: registrar, delegate: HTTPCookieProxyAPIDelegate())
  }

  func pigeonApiAuthenticationChallengeResponse(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiAuthenticationChallengeResponse
  {
    return PigeonApiAuthenticationChallengeResponse(
      pigeonRegistrar: registrar, delegate: AuthenticationChallengeResponseProxyAPIDelegate())
  }

  func pigeonApiWKWebsiteDataStore(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKWebsiteDataStore
  {
    return PigeonApiWKWebsiteDataStore(
      pigeonRegistrar: registrar, delegate: WebsiteDataStoreProxyAPIDelegate())
  }

  func pigeonApiUIView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiUIView {
    return PigeonApiUIView(pigeonRegistrar: registrar, delegate: UIViewProxyAPIDelegate())
  }

  func pigeonApiUIScrollView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiUIScrollView
  {
    return PigeonApiUIScrollView(pigeonRegistrar: registrar, delegate: ScrollViewProxyAPIDelegate())
  }

  func pigeonApiWKWebViewConfiguration(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKWebViewConfiguration
  {
    return PigeonApiWKWebViewConfiguration(
      pigeonRegistrar: registrar, delegate: WebViewConfigurationProxyAPIDelegate())
  }

  func pigeonApiWKUserContentController(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKUserContentController
  {
    return PigeonApiWKUserContentController(
      pigeonRegistrar: registrar, delegate: UserContentControllerProxyAPIDelegate())
  }

  func pigeonApiWKPreferences(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKPreferences
  {
    return PigeonApiWKPreferences(
      pigeonRegistrar: registrar, delegate: PreferencesProxyAPIDelegate())
  }

  func pigeonApiWKScriptMessageHandler(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKScriptMessageHandler
  {
    return PigeonApiWKScriptMessageHandler(
      pigeonRegistrar: registrar, delegate: ScriptMessageHandlerProxyAPIDelegate())
  }

  func pigeonApiWKNavigationDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKNavigationDelegate
  {
    return PigeonApiWKNavigationDelegate(
      pigeonRegistrar: registrar, delegate: NavigationDelegateProxyAPIDelegate())
  }

  func pigeonApiNSObject(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiNSObject {
    return PigeonApiNSObject(pigeonRegistrar: registrar, delegate: NSObjectProxyAPIDelegate())
  }

  func pigeonApiUIViewWKWebView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiUIViewWKWebView
  {
    return PigeonApiUIViewWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())
  }

  func pigeonApiNSViewWKWebView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiNSViewWKWebView
  {
    return PigeonApiNSViewWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())
  }

  func pigeonApiWKWebView(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiWKWebView {
    return PigeonApiWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())
  }

  func pigeonApiWKUIDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKUIDelegate
  {
    return PigeonApiWKUIDelegate(pigeonRegistrar: registrar, delegate: UIDelegateProxyAPIDelegate())
  }

  func pigeonApiWKHTTPCookieStore(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiWKHTTPCookieStore
  {
    return PigeonApiWKHTTPCookieStore(
      pigeonRegistrar: registrar, delegate: HTTPCookieStoreProxyAPIDelegate())
  }

  func pigeonApiUIScrollViewDelegate(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiUIScrollViewDelegate
  {
    return PigeonApiUIScrollViewDelegate(
      pigeonRegistrar: registrar, delegate: ScrollViewDelegateProxyAPIDelegate())
  }

  func pigeonApiURLCredential(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiURLCredential
  {
    return PigeonApiURLCredential(
      pigeonRegistrar: registrar, delegate: URLCredentialProxyAPIDelegate())
  }

  func pigeonApiURLProtectionSpace(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiURLProtectionSpace
  {
    return PigeonApiURLProtectionSpace(
      pigeonRegistrar: registrar, delegate: URLProtectionSpaceProxyAPIDelegate())
  }

  func pigeonApiURLAuthenticationChallenge(_ registrar: WebKitLibraryPigeonProxyApiRegistrar)
    -> PigeonApiURLAuthenticationChallenge
  {
    return PigeonApiURLAuthenticationChallenge(
      pigeonRegistrar: registrar, delegate: URLAuthenticationChallengeProxyAPIDelegate())
  }

  func pigeonApiURL(_ registrar: WebKitLibraryPigeonProxyApiRegistrar) -> PigeonApiURL {
    return PigeonApiURL(pigeonRegistrar: registrar, delegate: URLProxyAPIDelegate())
  }
}
