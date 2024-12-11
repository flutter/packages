// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import WebKit
import Flutter
import XCTest

@testable import webview_flutter_wkwebview

class WebViewProxyAPITests: XCTestCase {
  @MainActor func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api, initialConfiguration: WKWebViewConfiguration())
    XCTAssertNotNil(instance)
  }

  @MainActor func testConfiguration() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.configuration(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.configuration)
  }

  @MainActor func testScrollView() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.scrollView(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.scrollView)
  }

  @MainActor func testSetUIDelegate() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let delegate = UIDelegateImpl(api: registrar.apiDelegate.pigeonApiWKUIDelegate(registrar))
    try? api.pigeonDelegate.setUIDelegate(pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    XCTAssertEqual(instance.uiDelegate as! UIDelegateImpl, delegate)
  }

  @MainActor func testSetNavigationDelegate() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let delegate = NavigationDelegateImpl(api: registrar.apiDelegate.pigeonApiWKNavigationDelegate(registrar))
    try? api.pigeonDelegate.setNavigationDelegate(pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    XCTAssertEqual(instance.navigationDelegate as! NavigationDelegateImpl, delegate)
  }

  @MainActor func testGetUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.getUrl(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.url?.absoluteString)
  }

  @MainActor func testGetEstimatedProgress() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.getEstimatedProgress(pigeonApi: api, pigeonInstance: instance )

    XCTAssertEqual(value, instance.estimatedProgress)
  }

  @MainActor func testLoad() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let request = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    try? api.pigeonDelegate.load(pigeonApi: api, pigeonInstance: instance, request: request)

    XCTAssertEqual(instance.loadArgs, [request.value])
  }

  @MainActor func testLoadHtmlString() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let string = "myString"
    let baseUrl = "http://google.com"
    try? api.pigeonDelegate.loadHtmlString(pigeonApi: api, pigeonInstance: instance, string: string, baseUrl: baseUrl)

    XCTAssertEqual(instance.loadHtmlStringArgs, [string, URL(string: baseUrl)])
  }

  @MainActor func testLoadFileUrl() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let url = "myDirectory/myFile.txt"
    let readAccessUrl = "myDirectory/"
    try? api.pigeonDelegate.loadFileUrl(pigeonApi: api, pigeonInstance: instance, url: url, readAccessUrl: readAccessUrl)

    XCTAssertEqual(instance.loadFileUrlArgs, [URL(fileURLWithPath: url, isDirectory: false), URL(fileURLWithPath: readAccessUrl, isDirectory: true)])
  }

  @MainActor func testLoadFlutterAsset() {
//    let apiDelegate = pigeonApi.pigeonRegistrar.apiDelegate as! ProxyAPIDelegate
//    let assetFilePath = apiDelegate.assetManager.lookupKeyForAsset(key)
//
//    let url = apiDelegate.bundle.url(
//      forResource: (assetFilePath as NSString).deletingPathExtension,
//      withExtension: (assetFilePath as NSString).pathExtension)
//
//    if let url {
//      pigeonInstance.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
//    } else {
//      throw apiDelegate.createNullURLError(url: assetFilePath)
//    }
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)

    let instance = TestViewWKWebView()
    let key = "assets/www/index.html"
    try? api.pigeonDelegate.loadFlutterAsset(pigeonApi: api, pigeonInstance: instance, key: key)

    XCTAssertEqual(instance.loadFileUrlArgs?.count, 2)
    let URL = try! XCTUnwrap(instance.loadFileUrlArgs![0])
    let readAccessURL = try! XCTUnwrap(instance.loadFileUrlArgs![1])
    
    XCTAssertTrue(URL.absoluteString.contains("index.html"))
    XCTAssertTrue(readAccessURL.absoluteString.contains("assets/www/"))
  }
//
//  @MainActor func testCanGoBack() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let value = try? api.pigeonDelegate.canGoBack(pigeonApi: api, pigeonInstance: instance )
//
//    XCTAssertTrue(instance.canGoBackCalled)
//    XCTAssertEqual(value, instance.canGoBack())
//  }
//
//  @MainActor func testCanGoForward() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let value = try? api.pigeonDelegate.canGoForward(pigeonApi: api, pigeonInstance: instance )
//
//    XCTAssertTrue(instance.canGoForwardCalled)
//    XCTAssertEqual(value, instance.canGoForward())
//  }
//
//  @MainActor func testGoBack() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    try? api.pigeonDelegate.goBack(pigeonApi: api, pigeonInstance: instance )
//
//    XCTAssertTrue(instance.goBackCalled)
//  }
//
//  @MainActor func testGoForward() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    try? api.pigeonDelegate.goForward(pigeonApi: api, pigeonInstance: instance )
//
//    XCTAssertTrue(instance.goForwardCalled)
//  }
//
//  @MainActor func testReload() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    try? api.pigeonDelegate.reload(pigeonApi: api, pigeonInstance: instance )
//
//    XCTAssertTrue(instance.reloadCalled)
//  }
//
//  @MainActor func testGetTitle() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let value = try? api.pigeonDelegate.getTitle(pigeonApi: api, pigeonInstance: instance )
//
//    XCTAssertTrue(instance.getTitleCalled)
//    XCTAssertEqual(value, instance.getTitle())
//  }
//
//  @MainActor func testSetAllowsBackForwardNavigationGestures() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let allow = true
//    try? api.pigeonDelegate.setAllowsBackForwardNavigationGestures(pigeonApi: api, pigeonInstance: instance, allow: allow)
//
//    XCTAssertEqual(instance.setAllowsBackForwardNavigationGesturesArgs, [allow])
//  }
//
//  @MainActor func testSetCustomUserAgent() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let userAgent = "myString"
//    try? api.pigeonDelegate.setCustomUserAgent(pigeonApi: api, pigeonInstance: instance, userAgent: userAgent)
//
//    XCTAssertEqual(instance.setCustomUserAgentArgs, [userAgent])
//  }
//
//  @MainActor func testEvaluateJavaScript() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let javaScriptString = "myString"
//    let value = try? api.pigeonDelegate.evaluateJavaScript(pigeonApi: api, pigeonInstance: instance, javaScriptString: javaScriptString)
//
//    XCTAssertEqual(instance.evaluateJavaScriptArgs, [javaScriptString])
//    XCTAssertEqual(value, instance.evaluateJavaScript(javaScriptString: javaScriptString))
//  }
//
//  @MainActor func testSetInspectable() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let inspectable = true
//    try? api.pigeonDelegate.setInspectable(pigeonApi: api, pigeonInstance: instance, inspectable: inspectable)
//
//    XCTAssertEqual(instance.setInspectableArgs, [inspectable])
//  }
//
//  @MainActor func testGetCustomUserAgent() {
//    let registrar = TestProxyApiRegistrar()
//    let api = registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
//
//    let instance = TestViewWKWebView()
//    let value = try? api.pigeonDelegate.getCustomUserAgent(pigeonApi: api, pigeonInstance: instance )
//
//    XCTAssertTrue(instance.getCustomUserAgentCalled)
//    XCTAssertEqual(value, instance.getCustomUserAgent())
//  }
}

@MainActor
class TestViewWKWebView: WKWebView {
  private var configurationTestValue = WKWebViewConfiguration()
  private var scrollViewTestValue = UIScrollView(frame: .zero)
  var getUrlCalled = false
  var getEstimatedProgressCalled = false
  var loadArgs: [AnyHashable?]? = nil
  var loadHtmlStringArgs: [AnyHashable?]? = nil
  var loadFileUrlArgs: [URL]? = nil
  var canGoBackCalled = false
  var canGoForwardCalled = false
  var goBackCalled = false
  var goForwardCalled = false
  var reloadCalled = false
  var getTitleCalled = false
  var setAllowsBackForwardNavigationGesturesArgs: [AnyHashable?]? = nil
  var setCustomUserAgentArgs: [AnyHashable?]? = nil
  var evaluateJavaScriptArgs: [AnyHashable?]? = nil
  var setInspectableArgs: [AnyHashable?]? = nil
  var getCustomUserAgentCalled = false

  override var configuration: WKWebViewConfiguration {
    return configurationTestValue
  }
  
  override var scrollView: UIScrollView {
    return scrollViewTestValue
  }
  
  override var url: URL? {
    return URL(string: "http://google.com")
  }
  
  override var estimatedProgress: Double {
    return 2.0
  }
  
  override func load(_ request: URLRequest) -> WKNavigation? {
    loadArgs = [request]
    return nil
  }
  
  override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
    loadHtmlStringArgs = [string, baseURL]
    return nil
  }
  
  override func loadFileURL(_ URL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
    loadFileUrlArgs = [URL, readAccessURL]
    return nil
  }
//  override func canGoBack() {
//    canGoBackCalled = true
//  }
//  override func canGoForward() {
//    canGoForwardCalled = true
//  }
//  override func goBack() {
//    goBackCalled = true
//  }
//  override func goForward() {
//    goForwardCalled = true
//  }
//  override func reload() {
//    reloadCalled = true
//  }
//  override func getTitle() {
//    getTitleCalled = true
//  }
//  override func setAllowsBackForwardNavigationGestures() {
//    setAllowsBackForwardNavigationGesturesArgs = [allow]
//  }
//  override func setCustomUserAgent() {
//    setCustomUserAgentArgs = [userAgent]
//  }
//  override func evaluateJavaScript() {
//    evaluateJavaScriptArgs = [javaScriptString]
//    return -1
//  }
//  override func setInspectable() {
//    setInspectableArgs = [inspectable]
//  }
//  override func getCustomUserAgent() {
//    getCustomUserAgentCalled = true
//  }
}
