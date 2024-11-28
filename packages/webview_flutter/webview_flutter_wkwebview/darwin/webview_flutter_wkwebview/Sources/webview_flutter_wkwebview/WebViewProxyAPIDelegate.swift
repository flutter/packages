// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit

class WebViewImpl: WKWebView {
  let api: PigeonApiProtocolWKWebView
  
  init(api: PigeonApiProtocolWKWebView, frame: CGRect, configuration: WKWebViewConfiguration) {
    self.api = api
    super.init(frame: frame, configuration: configuration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    NSObjectImpl.handleObserveValue(withApi: (api as! PigeonApiWKWebView).pigeonApiNSObject, instance: self as NSObject, forKeyPath: keyPath, of: object, change: change, context: context)
  }
}

/// ProxyApi implementation for `WKWebView`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class WebViewProxyAPIDelegate : PigeonApiDelegateWKWebView {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKWebView, initialConfiguration: WKWebViewConfiguration) throws -> WKWebView {
    return WebViewImpl(api: pigeonApi, frame: CGRect(), configuration: initialConfiguration)
  }

  func configuration(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) -> WKWebViewConfiguration {
    return pigeonInstance.configuration
  }

  func asWKWebViewUI(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) -> WKWebView {
    return pigeonInstance
  }

  func NSWebViewExtensions(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) -> WKWebView {
    return pigeonInstance
  }

  func setUIDelegate(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, delegate: WKUIDelegate) throws {
    pigeonInstance.uiDelegate = delegate
  }

  func setNavigationDelegate(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, delegate: WKNavigationDelegate) throws {
    pigeonInstance.navigationDelegate = delegate
  }

  func getUrl(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws -> String? {
    return pigeonInstance.url?.absoluteString
  }

  func getEstimatedProgress(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws -> Double {
    return pigeonInstance.estimatedProgress
  }

  func load(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, request: URLRequestWrapper) throws {
    pigeonInstance.load(request.value)
  }

  func loadHtmlString(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, string: String, baseUrl: String?) throws {
    pigeonInstance.loadHTMLString(string, baseURL: baseUrl != nil ? URL(string: baseUrl!)! : nil)
  }

  func loadFileUrl(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, url: String, readAccessUrl: String) throws {
    pigeonInstance.loadFileURL(URL(string: url)!, allowingReadAccessTo: URL(string: readAccessUrl)!)
  }

  func loadFlutterAsset(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, key: String) throws {
    let apiDelegate = pigeonApi.pigeonRegistrar.apiDelegate as! ProxyAPIDelegate
    let assetFilePath = apiDelegate.assetManager.lookupKeyForAsset(key)
    
    let url = apiDelegate.bundle.url(forResource: (assetFilePath as NSString).deletingPathExtension, withExtension: (assetFilePath as NSString).pathExtension)
    
    if let url {
      pigeonInstance.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    } else {
      throw apiDelegate.createNullURLError(url: assetFilePath)
    }
  }

  func canGoBack(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws -> Bool {
    return pigeonInstance.canGoBack
  }

  func canGoForward(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws -> Bool {
    return pigeonInstance.canGoForward
  }

  func goBack(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws {
    pigeonInstance.goBack()
  }

  func goForward(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws {
    pigeonInstance.goForward()
  }

  func reload(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws {
    pigeonInstance.reload()
  }

  func getTitle(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws -> String? {
    return pigeonInstance.title
  }

  func setAllowsBackForwardNavigationGestures(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, allow: Bool) throws {
    pigeonInstance.allowsBackForwardNavigationGestures = allow
  }

  func setCustomUserAgent(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, userAgent: String?) throws {
    pigeonInstance.customUserAgent = userAgent
  }

  func evaluateJavaScript(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, javaScriptString: String, completion: @escaping (Result<Any?, Error>) -> Void) {
    pigeonInstance.evaluateJavaScript(javaScriptString) { result, error in
      if error == nil {
        if result == nil, result is String {
          completion(.success(result))
        } else {
          let className = String(describing: result)
          debugPrint("Return type of evaluateJavaScript is not directly supported: \(className). Returned description of value.")
          completion(.success(result.debugDescription))
        }
      } else {
        let error = PigeonError(code: "FWFEvaluateJavaScriptError", message: "Failed evaluating JavaScript.", details: error! as NSError)
        completion(.failure(error))
      }
    }
  }

  func setInspectable(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView, inspectable: Bool) throws {
    if #available(iOS 16.4, macOS 13.3, *) {
      pigeonInstance.isInspectable = inspectable
    } else {
      throw (pigeonApi.pigeonRegistrar.apiDelegate as! ProxyAPIDelegate).createUnsupportedVersionError(method: "HTTPCookiePropertyKey.sameSitePolicy", versionRequirements: "iOS 16.4, macOS 13.3")
    }
  }

  func getCustomUserAgent(pigeonApi: PigeonApiWKWebView, pigeonInstance: WKWebView) throws -> String? {
    return pigeonInstance.customUserAgent
  }
}
