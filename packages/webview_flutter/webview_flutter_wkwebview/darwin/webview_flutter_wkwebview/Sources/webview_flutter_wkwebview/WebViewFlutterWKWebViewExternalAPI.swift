// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

@objc(WebViewFlutterWKWebViewExternalAPI)
public class WebViewFlutterWKWebViewExternalAPI: NSObject {
  @objc
  public static func webView(forIdentifier identifier: NSNumber, withPluginRegistry registry: FlutterPluginRegistry) -> WKWebView? {
    let plugin = registry.valuePublished(byPlugin: "WebViewFlutterPlugin") as! WebViewFlutterPlugin
    
    let webView: WKWebView? = plugin.proxyApiRegistrar?.instanceManager .instance(forIdentifier: identifier.int64Value)
    return webView
  }
}
