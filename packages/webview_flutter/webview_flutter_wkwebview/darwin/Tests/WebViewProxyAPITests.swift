// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing
import WebKit

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

@Suite struct WebViewProxyAPITests {
  #if os(iOS)
    func webViewProxyAPI(forRegistrar registrar: ProxyAPIRegistrar) -> PigeonApiUIViewWKWebView {
      return registrar.apiDelegate.pigeonApiUIViewWKWebView(registrar)
    }
  #elseif os(macOS)
    func webViewProxyAPI(forRegistrar registrar: ProxyAPIRegistrar) -> PigeonApiNSViewWKWebView {
      return registrar.apiDelegate.pigeonApiNSViewWKWebView(registrar)
    }
  #endif

  @MainActor @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, initialConfiguration: WKWebViewConfiguration())
    #expect(instance != nil)
  }

  @MainActor @Test func configuration() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.configuration(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.configuration)
  }

  #if os(iOS)
    @MainActor @Test func scrollView() throws {
      let registrar = TestProxyApiRegistrar()
      let api = webViewProxyAPI(forRegistrar: registrar)

      let instance = TestViewWKWebView()
      let value = try? api.pigeonDelegate.scrollView(pigeonApi: api, pigeonInstance: instance)

      #expect(value == instance.scrollView)
    }
  #endif

  @MainActor @Test func setUIDelegate() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let delegate = UIDelegateImpl(
      api: registrar.apiDelegate.pigeonApiWKUIDelegate(registrar), registrar: registrar)
    try? api.pigeonDelegate.setUIDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    #expect(instance.uiDelegate as! UIDelegateImpl == delegate)
  }

  @MainActor @Test func setNavigationDelegate() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let delegate = NavigationDelegateImpl(
      api: registrar.apiDelegate.pigeonApiWKNavigationDelegate(registrar), registrar: registrar)
    try? api.pigeonDelegate.setNavigationDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    #expect(instance.navigationDelegate as! NavigationDelegateImpl == delegate)
  }

  @MainActor @Test func getUrl() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.getUrl(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.url?.absoluteString)
  }

  @MainActor @Test func getEstimatedProgress() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.getEstimatedProgress(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.estimatedProgress)
  }

  @MainActor @Test func load() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let request = URLRequestWrapper(URLRequest(url: URL(string: "http://google.com")!))
    try? api.pigeonDelegate.load(pigeonApi: api, pigeonInstance: instance, request: request)

    #expect(instance.loadArgs == [request.value])
  }

  @MainActor @Test func loadHtmlString() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let string = "myString"
    let baseUrl = "http://google.com"
    try? api.pigeonDelegate.loadHtmlString(
      pigeonApi: api, pigeonInstance: instance, string: string, baseUrl: baseUrl)

    #expect(instance.loadHtmlStringArgs == [string, URL(string: baseUrl)])
  }

  @MainActor @Test func loadFileUrl() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let url = "myDirectory/myFile.txt"
    let readAccessUrl = "myDirectory/"
    try? api.pigeonDelegate.loadFileUrl(
      pigeonApi: api, pigeonInstance: instance, url: url, readAccessUrl: readAccessUrl)

    #expect(
      instance.loadFileUrlArgs == [
        URL(fileURLWithPath: url, isDirectory: false),
        URL(fileURLWithPath: readAccessUrl, isDirectory: true),
      ])
  }

  @MainActor @Test func loadFlutterAsset() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let key = "assets/www/index.html"
    try? api.pigeonDelegate.loadFlutterAsset(pigeonApi: api, pigeonInstance: instance, key: key)

    #expect(instance.loadFileUrlArgs?.count == 2)
    let url = try #require(instance.loadFileUrlArgs![0])
    let readAccessURL = try #require(instance.loadFileUrlArgs![1])

    #expect(url.absoluteString.contains("index.html"))
    #expect(readAccessURL.absoluteString.contains("assets/www/"))
  }

  @MainActor @Test func canGoBack() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.canGoBack(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.canGoBack)
  }

  @MainActor @Test func canGoForward() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.canGoForward(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.canGoForward)
  }

  @MainActor @Test func goBack() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    try? api.pigeonDelegate.goBack(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.goBackCalled)
  }

  @MainActor @Test func goForward() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    try? api.pigeonDelegate.goForward(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.goForwardCalled)
  }

  @MainActor @Test func reload() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    try? api.pigeonDelegate.reload(pigeonApi: api, pigeonInstance: instance)

    #expect(instance.reloadCalled)
  }

  @MainActor @Test func getTitle() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.getTitle(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.title)
  }

  @MainActor @Test func setAllowsBackForwardNavigationGestures() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let allow = true
    try? api.pigeonDelegate.setAllowsBackForwardNavigationGestures(
      pigeonApi: api, pigeonInstance: instance, allow: allow)

    #expect(instance.setAllowsBackForwardNavigationGesturesArgs == [allow])
  }

  @MainActor @Test func setCustomUserAgent() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let userAgent = "myString"
    try? api.pigeonDelegate.setCustomUserAgent(
      pigeonApi: api, pigeonInstance: instance, userAgent: userAgent)

    #expect(instance.setCustomUserAgentArgs == [userAgent])
  }

  @MainActor @Test func evaluateJavaScript() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let javaScriptString = "myString"

    var resultValue: Any?
    api.pigeonDelegate.evaluateJavaScript(
      pigeonApi: api, pigeonInstance: instance, javaScriptString: javaScriptString,
      completion: { result in
        switch result {
        case .success(let value):
          resultValue = value
        case .failure(_):
          break
        }
      })

    #expect(instance.evaluateJavaScriptArgs == [javaScriptString])
    #expect(resultValue as! String == "returnValue")
  }

  @MainActor @Test func setInspectable() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let inspectable = true
    try? api.pigeonDelegate.setInspectable(
      pigeonApi: api, pigeonInstance: instance, inspectable: inspectable)

    #expect(instance.setInspectableArgs == [inspectable])
    #expect(!(instance.isInspectable))
  }

  @MainActor @Test func setAllowsLinkPreview() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let allow: Bool = true
    try? api.pigeonDelegate.setAllowsLinkPreview(
      pigeonApi: api, pigeonInstance: instance, allow: allow)

    #expect(instance.allowsLinkPreview == allow)
  }

  @MainActor @Test func getCustomUserAgent() throws {
    let registrar = TestProxyApiRegistrar()
    let api = webViewProxyAPI(forRegistrar: registrar)

    let instance = TestViewWKWebView()
    let value = try? api.pigeonDelegate.getCustomUserAgent(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.customUserAgent)
  }

  #if os(iOS)
    @MainActor @Test func webViewContentInsetBehaviorShouldBeNever() throws {
      let registrar = TestProxyApiRegistrar()
      let api = PigeonApiWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())

      let webView = WebViewImpl(
        api: api, registrar: registrar, frame: .zero, configuration: WKWebViewConfiguration())

      #expect(webView.scrollView.contentInsetAdjustmentBehavior == .never)
    }

    @MainActor
    @Test func scrollViewsAutomaticallyAdjustsScrollIndicatorInsetsShouldbeFalse() throws {
      let registrar = TestProxyApiRegistrar()
      let api = PigeonApiWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())

      let webView = WebViewImpl(
        api: api, registrar: registrar, frame: .zero, configuration: WKWebViewConfiguration())

      #expect(!(webView.scrollView.automaticallyAdjustsScrollIndicatorInsets))
    }

    @MainActor @Test func contentInsetsSumAlwaysZeroAfterSetFrame() throws {
      let registrar = TestProxyApiRegistrar()
      let api = PigeonApiWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())

      let webView = WebViewImpl(
        api: api, registrar: registrar, frame: .zero, configuration: WKWebViewConfiguration())

      webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 300)

      webView.frame = .zero
      #expect(webView.scrollView.contentInset == .zero)
    }

    @MainActor @Test func contentInsetsIsOppositeOfScrollViewAdjustedInset() throws {
      let registrar = TestProxyApiRegistrar()
      let api = PigeonApiWKWebView(pigeonRegistrar: registrar, delegate: WebViewProxyAPIDelegate())

      let webView = WebViewImpl(
        api: api, registrar: registrar, frame: .zero, configuration: WKWebViewConfiguration())

      webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 300)

      webView.frame = .zero
      let contentInset: UIEdgeInsets = webView.scrollView.contentInset
      #expect(contentInset.left == -webView.scrollView.adjustedContentInset.left)
      #expect(contentInset.top == -webView.scrollView.adjustedContentInset.top)
      #expect(contentInset.right == -webView.scrollView.adjustedContentInset.right)
      #expect(contentInset.bottom == -webView.scrollView.adjustedContentInset.bottom)
    }
  #endif
}

@MainActor
class TestViewWKWebView: WKWebView {
  private var configurationTestValue = WKWebViewConfiguration()
  #if os(iOS)
    private var scrollViewTestValue = TestAdjustedScrollView(frame: .zero)
  #endif
  var getUrlCalled = false
  var getEstimatedProgressCalled = false
  var loadArgs: [AnyHashable?]? = nil
  var loadHtmlStringArgs: [AnyHashable?]? = nil
  var loadFileUrlArgs: [URL]? = nil
  var goBackCalled = false
  var goForwardCalled = false
  var reloadCalled = false
  var setAllowsBackForwardNavigationGesturesArgs: [AnyHashable?]? = nil
  var setCustomUserAgentArgs: [AnyHashable?]? = nil
  var evaluateJavaScriptArgs: [AnyHashable?]? = nil
  var setInspectableArgs: [AnyHashable?]? = nil

  override var configuration: WKWebViewConfiguration {
    return configurationTestValue
  }

  #if os(iOS)
    override var scrollView: UIScrollView {
      return scrollViewTestValue
    }
  #endif

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

  override func loadFileURL(_ url: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
    loadFileUrlArgs = [url, readAccessURL]
    return nil
  }

  override var canGoBack: Bool {
    return false
  }

  override var canGoForward: Bool {
    return true
  }

  override func goBack() -> WKNavigation? {
    goBackCalled = true
    return nil
  }

  override func goForward() -> WKNavigation? {
    goForwardCalled = true
    return nil
  }

  override func reload() -> WKNavigation? {
    reloadCalled = true
    return nil
  }

  override var title: String? {
    return "title"
  }

  override var allowsBackForwardNavigationGestures: Bool {
    set {
      setAllowsBackForwardNavigationGesturesArgs = [newValue]
    }
    get {
      return true
    }
  }

  override var customUserAgent: String? {
    set {
      setCustomUserAgentArgs = [newValue]
    }
    get {
      return "myUserAgent"
    }
  }

  #if compiler(>=6.0)
    public override func evaluateJavaScript(
      _ javaScriptString: String,
      completionHandler: (@MainActor @Sendable (Any?, (Error)?) -> Void)? = nil
    ) {
      evaluateJavaScriptArgs = [javaScriptString]
      completionHandler?("returnValue", nil)
    }
  #else
    public override func evaluateJavaScript(
      _ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)? = nil
    ) {
      evaluateJavaScriptArgs = [javaScriptString]
      completionHandler?("returnValue", nil)
    }
  #endif

  override var isInspectable: Bool {
    set {
      setInspectableArgs = [newValue]
    }
    get {
      return false
    }
  }
}

#if os(iOS)
  @MainActor
  class TestAdjustedScrollView: UIScrollView {
    override var adjustedContentInset: UIEdgeInsets {
      return UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
    }
  }
#endif
