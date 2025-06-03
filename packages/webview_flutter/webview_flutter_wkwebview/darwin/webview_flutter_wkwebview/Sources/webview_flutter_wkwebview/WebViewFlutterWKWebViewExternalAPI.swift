// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// App and package facing native API provided by the `webview_flutter_wkwebview` plugin.
///
/// This class follows the convention of breaking changes of the Dart API, which means that any
/// changes to the class that are not backwards compatible will only be made with a major version
/// change of the plugin. Native code other than this external API does not follow breaking change
/// conventions, so app or plugin clients should not use any other native APIs.
@objc(FWFWebViewFlutterWKWebViewExternalAPI)
public class FWFWebViewFlutterWKWebViewExternalAPI: NSObject {
  /// Retrieves the `WKWebView` that is associated with `identifier`.
  ///
  /// See the Dart method `WebKitWebViewController.webViewIdentifier` to get the identifier of an
  /// underlying `WKWebView`.
  @objc(webViewForIdentifier:withPluginRegistry:)
  public static func webView(
    forIdentifier identifier: Int64, withPluginRegistry registry: FlutterPluginRegistry
  ) -> WKWebView? {
    let plugin = registry.valuePublished(byPlugin: "WebViewFlutterPlugin") as! WebViewFlutterPlugin

    let webView: WKWebView? = plugin.proxyApiRegistrar?.instanceManager.instance(
      forIdentifier: identifier)
    return webView
  }
}
