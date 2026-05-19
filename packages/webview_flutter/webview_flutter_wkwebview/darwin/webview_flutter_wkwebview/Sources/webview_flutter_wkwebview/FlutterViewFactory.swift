// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

#if os(iOS)
  class PlatformViewImpl: NSObject, FlutterPlatformView {
    // TODO(bparrishMines): Change to strong reference once this issue is fixed in the engine and
    // makes it to stable. See https://github.com/flutter/flutter/issues/168535.
    // The InstanceManager used by pigeon adds an associated object to added instances that makes a message call when
    // they are deallocated. This sets a weak reference to the underlying UIView to prevent a crash where the UIView is
    // no longer referenced by the plugin, but the FlutterViewController still maintains a transitive reference to it
    // when the BinaryMessenger becomes invalid.
    weak var uiView: UIView?

    init(uiView: UIView) {
      self.uiView = uiView
    }

    func view() -> UIView {
      if let uiView = uiView {
        return uiView
      }

      NSLog(
        "WebViewFlutterPluginError: UIView has been deallocated, but is still being requested as a PlatformView."
      )
      return UIView()
    }
  }
#endif

/// Implementation of `FlutterPlatformViewFactory` that retrieves the view from the `WebKitLibraryPigeonInstanceManager`.
class FlutterViewFactory: NSObject, FlutterPlatformViewFactory {
  unowned let instanceManager: WebKitLibraryPigeonInstanceManager

  init(instanceManager: WebKitLibraryPigeonInstanceManager) {
    self.instanceManager = instanceManager
  }

  #if os(iOS)
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
      -> FlutterPlatformView
    {
      let identifier: Int64 = args is Int64 ? args as! Int64 : Int64(args as! Int32)
      let instance: AnyObject? = instanceManager.instance(forIdentifier: identifier)

      let view = instance as! UIView
      view.frame = frame
      return PlatformViewImpl(uiView: view)
    }
  #elseif os(macOS)
    func create(
      withViewIdentifier viewId: Int64,
      arguments args: Any?
    ) -> NSView {
      let identifier: Int64 = args is Int64 ? args as! Int64 : Int64(args as! Int32)
      let instance: AnyObject? = instanceManager.instance(forIdentifier: identifier)
      return instance as! NSView
    }
  #endif

  #if os(iOS)
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
      return FlutterStandardMessageCodec.sharedInstance()
    }
  #elseif os(macOS)
    func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
      return FlutterStandardMessageCodec.sharedInstance()
    }
  #endif
}
