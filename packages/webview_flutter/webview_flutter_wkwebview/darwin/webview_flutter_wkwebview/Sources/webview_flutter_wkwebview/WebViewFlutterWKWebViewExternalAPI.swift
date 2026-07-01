// Copyright 2013 The Flutter Authors
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
  #if os(iOS)
    // Only deprecate this method on iOS until FlutterPluginRegistrar.valuePublished(byPlugin:) is
    // available on macOS. See https://github.com/flutter/flutter/issues/186911.
    @available(*, deprecated, message: "Use webView(forIdentifier:withPluginRegistrar:) instead.")
  #endif
  @objc(webViewForIdentifier:withPluginRegistry:)
  public static func webView(
    forIdentifier identifier: Int64, withPluginRegistry registry: FlutterPluginRegistry
  ) -> WKWebView? {
    let plugin = registry.valuePublished(byPlugin: "WebViewFlutterPlugin")
    guard let webviewPlugin = plugin as? WebViewFlutterPlugin else {
      return nil
    }

    return webview(forIdentifier: identifier, withPlugin: webviewPlugin)
  }

  // This method is only available on iOS until FlutterPluginRegistrar.valuePublished(byPlugin:) is
  // available on macOS. See https://github.com/flutter/flutter/issues/186911.
  #if os(iOS)
    /// Retrieves the `WKWebView` that is associated with `identifier` using a FlutterPluginRegistrar
    ///
    /// See the Dart method `WebKitWebViewController.webViewIdentifier` to get the identifier of an
    /// underlying `WKWebView`.
    @objc(webViewForIdentifier:withPluginRegistrar:)
    public static func webView(
      forIdentifier identifier: Int64, withPluginRegistrar registrar: FlutterPluginRegistrar
    ) -> WKWebView? {
      let plugin = registrar.valuePublished(byPlugin: "WebViewFlutterPlugin")
      guard let webviewPlugin = plugin as? WebViewFlutterPlugin else {
        return nil
      }

      return webview(forIdentifier: identifier, withPlugin: webviewPlugin)
    }
  #endif

  private static func webview(forIdentifier identifier: Int64, withPlugin: WebViewFlutterPlugin)
    -> WKWebView?
  {
    let webView: WKWebView? = withPlugin.proxyApiRegistrar?.instanceManager.instance(
      forIdentifier: identifier)
    return webView
  }
}
