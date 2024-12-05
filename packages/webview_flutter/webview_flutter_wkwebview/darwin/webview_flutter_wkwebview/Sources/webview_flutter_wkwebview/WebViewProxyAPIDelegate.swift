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
#if os(iOS)
      scrollView.contentInsetAdjustmentBehavior = .never
      if #available(iOS 13.0, *) {
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
      }
#endif
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    NSObjectImpl.handleObserveValue(
      withApi: (api as! PigeonApiWKWebView).pigeonApiNSObject, instance: self as NSObject,
      forKeyPath: keyPath, of: object, change: change, context: context)
  }
  
  override var frame: CGRect {
    get {
      return super.frame
    }
    set {
      super.frame = newValue
#if os(iOS)
      // Prevents the contentInsets from being adjusted by iOS and gives control to Flutter.
      scrollView.contentInset = .zero
      
      // Adjust contentInset to compensate the adjustedContentInset so the sum will
      //  always be 0.
      if scrollView.adjustedContentInset != .zero {
        let insetToAdjust = scrollView.adjustedContentInset
        scrollView.contentInset = UIEdgeInsets(top: -insetToAdjust.top, left: -insetToAdjust.left, bottom: -insetToAdjust.bottom, right: -insetToAdjust.right)
      }
#endif
    }
  }
}

/// ProxyApi implementation for `WKWebView`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class WebViewProxyAPIDelegate: PigeonApiDelegateWKWebView, PigeonApiDelegateUIViewWKWebView,
  PigeonApiDelegateNSViewWKWebView
{
  func scrollView(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws
    -> UIScrollView
  {
    return pigeonInstance.scrollView
  }

  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiUIViewWKWebView, initialConfiguration: WKWebViewConfiguration
  ) throws -> WKWebView {
    return WebViewImpl(
      api: pigeonApi.pigeonApiWKWebView, frame: CGRect(), configuration: initialConfiguration)
  }

  func configuration(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView)
    -> WKWebViewConfiguration
  {
    return pigeonInstance.configuration
  }

  func setUIDelegate(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, delegate: WKUIDelegate
  ) throws {
    pigeonInstance.uiDelegate = delegate
  }

  func setNavigationDelegate(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, delegate: WKNavigationDelegate
  ) throws {
    pigeonInstance.navigationDelegate = delegate
  }

  func getUrl(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws -> String? {
    return pigeonInstance.url?.absoluteString
  }

  func getEstimatedProgress(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws
    -> Double
  {
    return pigeonInstance.estimatedProgress
  }

  func load(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, request: URLRequestWrapper
  ) throws {
    pigeonInstance.load(request.value)
  }

  func loadHtmlString(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, string: String, baseUrl: String?
  ) throws {
    pigeonInstance.loadHTMLString(string, baseURL: baseUrl != nil ? URL(string: baseUrl!)! : nil)
  }

  func loadFileUrl(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, url: String,
    readAccessUrl: String
  ) throws {
    let fileURL = URL(fileURLWithPath: url, isDirectory: false)
    let readAccessURL = URL(fileURLWithPath: readAccessUrl, isDirectory: true)

    pigeonInstance.loadFileURL(fileURL, allowingReadAccessTo: readAccessURL)
  }

  func loadFlutterAsset(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, key: String)
    throws
  {
    let apiDelegate = pigeonApi.pigeonRegistrar.apiDelegate as! ProxyAPIDelegate
    let assetFilePath = apiDelegate.assetManager.lookupKeyForAsset(key)

    let url = apiDelegate.bundle.url(
      forResource: (assetFilePath as NSString).deletingPathExtension,
      withExtension: (assetFilePath as NSString).pathExtension)

    if let url {
      pigeonInstance.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    } else {
      throw apiDelegate.createNullURLError(url: assetFilePath)
    }
  }

  func canGoBack(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws -> Bool {
    return pigeonInstance.canGoBack
  }

  func canGoForward(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws -> Bool {
    return pigeonInstance.canGoForward
  }

  func goBack(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws {
    pigeonInstance.goBack()
  }

  func goForward(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws {
    pigeonInstance.goForward()
  }

  func reload(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws {
    pigeonInstance.reload()
  }

  func getTitle(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws -> String? {
    return pigeonInstance.title
  }

  func setAllowsBackForwardNavigationGestures(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, allow: Bool
  ) throws {
    pigeonInstance.allowsBackForwardNavigationGestures = allow
  }

  func setCustomUserAgent(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, userAgent: String?
  ) throws {
    pigeonInstance.customUserAgent = userAgent
  }

  func evaluateJavaScript(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, javaScriptString: String,
    completion: @escaping (Result<Any?, Error>) -> Void
  ) {
    pigeonInstance.evaluateJavaScript(javaScriptString) { result, error in
      if error == nil {
        if let optionalResult = result as Any?? {
          switch optionalResult {
          case .none:
            completion(.success(nil))
          case .some(let value):
            if value is String || value is NSNumber {
              completion(.success(value))
            } else {
              let className = String(describing: value)
              debugPrint(
                "Return type of evaluateJavaScript is not directly supported: \(className). Returned description of value."
              )
              completion(.success((value as AnyObject).description))
            }
          }
        }
      } else {
        let error = PigeonError(
          code: "FWFEvaluateJavaScriptError", message: "Failed evaluating JavaScript.",
          details: error! as NSError)
        completion(.failure(error))
      }
    }
  }

  func setInspectable(
    pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView, inspectable: Bool
  ) throws {
    if #available(iOS 16.4, macOS 13.3, *) {
      pigeonInstance.isInspectable = inspectable
    } else {
      throw (pigeonApi.pigeonRegistrar.apiDelegate as! ProxyAPIDelegate)
        .createUnsupportedVersionError(
          method: "HTTPCookiePropertyKey.sameSitePolicy",
          versionRequirements: "iOS 16.4, macOS 13.3")
    }
  }

  func getCustomUserAgent(pigeonApi: PigeonApiUIViewWKWebView, pigeonInstance: WKWebView) throws
    -> String?
  {
    return pigeonInstance.customUserAgent
  }
}
