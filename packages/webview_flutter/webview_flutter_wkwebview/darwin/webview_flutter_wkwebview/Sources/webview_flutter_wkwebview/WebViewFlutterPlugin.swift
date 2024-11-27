// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

public class WebViewFlutterPlugin: NSObject, FlutterPlugin {
  var proxyApiRegistrar: WebKitLibraryPigeonProxyApiRegistrar?

  init(binaryMessenger: FlutterBinaryMessenger) {
    proxyApiRegistrar = WebKitLibraryPigeonProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyAPIDelegate())
    proxyApiRegistrar?.setUp()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = WebViewFlutterPlugin(binaryMessenger: registrar.messenger())
    let viewFactory = FlutterViewFactory(instanceManager: plugin.proxyApiRegistrar!.instanceManager)
    registrar.register(viewFactory, withId: "plugins.flutter.io/webview")
    registrar.publish(plugin)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    proxyApiRegistrar!.ignoreCallsToDart = true
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil
  }
}
