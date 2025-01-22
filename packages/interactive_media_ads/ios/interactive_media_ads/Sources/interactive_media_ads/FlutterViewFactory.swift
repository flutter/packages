// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

/// Implementation of `FlutterPlatformViewFactory` that converts any `UIView` in a
/// `PigeonInstanceManager` to a `FlutterPlatformView`.
class FlutterViewFactory: NSObject, FlutterPlatformViewFactory {
  unowned let instanceManager: InteractiveMediaAdsLibraryPigeonInstanceManager

  class PlatformViewImpl: NSObject, FlutterPlatformView {
    let uiView: UIView

    init(uiView: UIView) {
      self.uiView = uiView
    }

    func view() -> UIView {
      return uiView
    }
  }

  init(instanceManager: InteractiveMediaAdsLibraryPigeonInstanceManager) {
    self.instanceManager = instanceManager
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    let identifier: Int64 = args is Int64 ? args as! Int64 : Int64(args as! Int32)
    let instance: AnyObject? = instanceManager.instance(forIdentifier: identifier)

    if let instance = instance as? FlutterPlatformView {
      return instance
    } else {
      return PlatformViewImpl(uiView: instance as! UIView)
    }
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}
