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

    let plugin = registry.registrar.plugin as! WebViewFlutterPlugin?

    let webView = WKWebView(frame: .zero)
    let webViewIdentifier = 0
    plugin?.proxyApiRegistrar?.instanceManager.addDartCreatedInstance(
      webView, withIdentifier: Int64(webViewIdentifier))

    let result = FWFWebViewFlutterWKWebViewExternalAPI.webView(
      forIdentifier: Int64(webViewIdentifier), withPluginRegistry: registry)
    XCTAssertEqual(result, webView)
  }
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
    if pluginKey == "WebViewFlutterPlugin" {
      return registrar.plugin
    }
    return nil
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

// TODO(stuartmorgan): This is temporarily disabled on iOS in favor of Stubs.h/m,
// because FlutterSceneLifeCycleDelegate isn't available on stable, and Swift doesn't
// allow using looser types (like Any) for protocol conformance. Once that
// protocol reaches stable, this #if should be removed, as should Stubs.*.
#if os(macOS)
  class TestFlutterPluginRegistrar: NSObject, FlutterPluginRegistrar {
    var plugin: WebViewFlutterPlugin? = nil

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
      plugin = (value as! WebViewFlutterPlugin)
    }

    func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {

    }

    func lookupKey(forAsset asset: String) -> String {
      return ""
    }

    func lookupKey(forAsset asset: String, fromPackage package: String) -> String {
      return ""
    }
  }
#endif
