// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import Cocoa
  import FlutterMacOS
#endif

public class CrossFileDarwinPlugin: NSObject, FlutterPlugin {
  var proxyApiRegistrar: CrossFileDarwinApisPigeonProxyApiRegistrar?

  init(binaryMessenger: FlutterBinaryMessenger) {
    proxyApiRegistrar = CrossFileDarwinApisPigeonProxyApiRegistrar(
      binaryMessenger: binaryMessenger, apiDelegate: ProxyApiDelegate())
    proxyApiRegistrar?.setUp()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #elseif os(macOS)
      let messenger = registrar.messenger
    #endif

    CrossFileDarwinApiSetup.setUp(binaryMessenger: messenger, api: CrossFileDarwinApiImpl())
    let plugin = CrossFileDarwinPlugin(binaryMessenger: messenger)
    registrar.publish(plugin)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
    #elseif os(macOS)
      let messenger = registrar.messenger
    #endif

    CrossFileDarwinApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
    proxyApiRegistrar!.ignoreCallsToDart = true
    proxyApiRegistrar!.tearDown()
    proxyApiRegistrar = nil
  }
}
