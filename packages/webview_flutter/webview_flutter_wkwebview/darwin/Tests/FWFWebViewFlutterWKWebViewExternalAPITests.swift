// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit
import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

class FWFWebViewFlutterWKWebViewExternalAPITests: XCTestCase {
  @MainActor func testWebViewForIdentifier() {
    let registry = TestRegistry()

    #if os(iOS)
      let registrar = registry.registrar(forPlugin: "")!
    #elseif os(macOS)
      let registrar = registry.registrar(forPlugin: "")
    #endif

    WebViewFlutterPlugin.register(with: registrar)

    let plugin = registry.registrar.publishedValue as! WebViewFlutterPlugin

    let webView = WKWebView(frame: .zero)
    let webViewIdentifier = 0
    plugin.proxyApiRegistrar?.instanceManager.addDartCreatedInstance(
      webView, withIdentifier: Int64(webViewIdentifier))

    let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
      forIdentifier: Int64(webViewIdentifier), withPluginRegistry: registry)
    XCTAssertEqual(result, webView)
  }

  @MainActor func testWebViewForIdentifierHandlesIncorrectRegistry() {
    let registry = TestRegistry()
    // Ensure that passing an empty registry, such as the FlutterAppDelegate
    // in an app that has adopted UIScene, gracefully returns nil.
    let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
      forIdentifier: 0, withPluginRegistry: registry)
    XCTAssertEqual(result, nil)
  }

  // FlutterPluginRegistrar.valuePublished(byPlugin:) is not available on macOS. This
  // can be removed once this method becomes available.
  // See https://github.com/flutter/flutter/issues/186911.
  #if os(iOS)
    @MainActor func testWebViewForIdentifierFromRegistrar() {
      let registry = TestRegistry()

      #if os(iOS)
        let registrar = registry.registrar(forPlugin: "")!
      #elseif os(macOS)
        let registrar = registry.registrar(forPlugin: "")
      #endif

      WebViewFlutterPlugin.register(with: registrar)

      let plugin = registry.registrar.publishedValue as! WebViewFlutterPlugin

      let webView = WKWebView(frame: .zero)
      let webViewIdentifier = 0
      plugin.proxyApiRegistrar?.instanceManager.addDartCreatedInstance(
        webView, withIdentifier: Int64(webViewIdentifier))

      let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
        forIdentifier: Int64(webViewIdentifier), withPluginRegistrar: registrar)
      XCTAssertEqual(result, webView)
    }

    @MainActor func testWebViewForIdentifierHandlesIncorrectRegistrar() {
      let registrar = TestFlutterPluginRegistrar()
      // Ensure that passing an empty registry, such as the FlutterAppDelegate
      // in an app that has adopted UIScene, gracefully returns nil.
      let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
        forIdentifier: 0, withPluginRegistrar: registrar)
      XCTAssertEqual(result, nil)
    }
  #endif
}

class TestRegistry: NSObject, FlutterPluginRegistry {
  let registrar = TestFlutterPluginRegistrar()

  #if os(iOS)
    func registrar(forPlugin pluginKey: String) -> FlutterPluginRegistrar? {
      return registrar
    }
  #elseif os(macOS)
    func registrar(forPlugin pluginKey: String) -> FlutterPluginRegistrar {
      return registrar
    }
  #endif

  func hasPlugin(_ pluginKey: String) -> Bool {
    return true
  }

  func valuePublished(byPlugin pluginKey: String) -> NSObject? {
    return registrar.publishedValue
  }
}

class TestFlutterTextureRegistry: NSObject, FlutterTextureRegistry {
  func register(_ texture: FlutterTexture) -> Int64 {
    return 0
  }

  func textureFrameAvailable(_ textureId: Int64) {

  }

  func unregisterTexture(_ textureId: Int64) {

  }
}

class TestFlutterPluginRegistrar: NSObject, FlutterPluginRegistrar {
  var publishedValue: NSObject? = nil

  #if os(iOS)
    var viewController: UIViewController?

    func messenger() -> FlutterBinaryMessenger {
      return TestBinaryMessenger()
    }

    func textures() -> FlutterTextureRegistry {
      return TestFlutterTextureRegistry()
    }

    func addApplicationDelegate(_ delegate: FlutterPlugin) {

    }

    func register(
      _ factory: FlutterPlatformViewFactory, withId factoryId: String,
      gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy
    ) {
    }

    func addSceneDelegate(_ delegate: any FlutterSceneLifeCycleDelegate) {
    }
  #elseif os(macOS)
    var view: NSView?
    var viewController: NSViewController?

    var messenger: FlutterBinaryMessenger {
      return TestBinaryMessenger()
    }

    var textures: FlutterTextureRegistry {
      return TestFlutterTextureRegistry()
    }

    func addApplicationDelegate(_ delegate: FlutterAppLifecycleDelegate) {

    }
  #endif

  func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String) {
  }

  func publish(_ value: NSObject) {
    publishedValue = value
  }

  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {

  }

  func lookupKey(forAsset asset: String) -> String {
    return ""
  }

  func lookupKey(forAsset asset: String, fromPackage package: String) -> String {
    return ""
  }

  func valuePublished(byPlugin pluginKey: String) -> NSObject? {
    if pluginKey == "WebViewFlutterPlugin" {
      return publishedValue
    }
    return nil
  }
}
