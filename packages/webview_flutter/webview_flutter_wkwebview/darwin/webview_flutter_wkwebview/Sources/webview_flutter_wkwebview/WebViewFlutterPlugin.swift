// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

public class WebViewFlutterPlugin: NSObject, FlutterPlugin {
  var proxyApiRegistrar: ProxyAPIRegistrar?

  init(binaryMessenger: FlutterBinaryMessenger) {
    proxyApiRegistrar = ProxyAPIRegistrar(
      binaryMessenger: binaryMessenger)
    proxyApiRegistrar?.setUp()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let binaryMessenger = registrar.messenger()
    #else
      let binaryMessenger = registrar.messenger
    #endif
    let plugin = WebViewFlutterPlugin(binaryMessenger: binaryMessenger)

    let viewFactory = FlutterViewFactory(instanceManager: plugin.proxyApiRegistrar!.instanceManager)

    #if os(iOS)
      registrar.addApplicationDelegate(plugin)
      registrar.addSceneDelegate(plugin)
    #endif

    #if os(iOS)
      // The default `eager` policy blocks the platform view's gesture
      // recognizers through Flutter's gesture arena, which is stateful. When
      // that state is stranded the web view stops receiving touches for the
      // rest of its lifetime. `doNotBlockGesture` derives the same decision
      // from hit testing instead, so there is no state left to strand.
      // See https://github.com/flutter/flutter/issues/175099.
      registrar.register(
        viewFactory, withId: "plugins.flutter.io/webview",
        gestureRecognizersBlockingPolicy:
          FlutterPlatformViewGestureRecognizersBlockingPolicyDoNotBlockGesture)
    #else
      registrar.register(viewFactory, withId: "plugins.flutter.io/webview")
    #endif
    registrar.publish(plugin)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    tearDownProxyAPIRegistrar()
  }

  private func tearDownProxyAPIRegistrar() {
    proxyApiRegistrar?.ignoreCallsToDart = true
    proxyApiRegistrar?.tearDown()
    try? proxyApiRegistrar?.instanceManager.removeAllObjects()
    proxyApiRegistrar = nil
  }
}

#if os(iOS)
  extension WebViewFlutterPlugin: FlutterApplicationLifeCycleDelegate, FlutterSceneLifeCycleDelegate
  {
    public func applicationWillTerminate(_ application: UIApplication) {
      tearDownProxyAPIRegistrar()
    }

    public func sceneDidDisconnect(_ scene: UIScene) {
      tearDownProxyAPIRegistrar()
    }
  }
#endif
