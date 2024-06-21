//
//  FlutterViewFactory.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import Flutter

class FlutterViewFactory: NSObject, FlutterPlatformViewFactory {
  unowned let instanceManager: PigeonInstanceManager

  class PlatformViewImpl: NSObject, FlutterPlatformView {
    unowned let uiView: UIView
    
    init(uiView: UIView) {
      self.uiView = uiView
    }
    
    func view() -> UIView {
      return uiView
    }
  }

  init(instanceManager: PigeonInstanceManager) {
    self.instanceManager = instanceManager
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    let identifier: Int64 = args is Int64 ? args as! Int64 : Int64(args as! Int32)
    let instance: AnyObject? = instanceManager.instance(forIdentifier: identifier)
    
    if let instance = instance as? FlutterPlatformView {
      return instance
    } else {
      return PlatformViewImpl(uiView: instance as! UIView)
    }
  }
}
