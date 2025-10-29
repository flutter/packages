// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

/// A  simple factory that creates a dummy platform view for testing.
public class DummyPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  public func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return DummyPlatformView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger)
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}

/// A native view that will remove its tag if clicked.
public class CustomView: UIView {

  override public func hitTest(
    _ point: CGPoint,
    with event: UIEvent?
  ) -> UIView? {
    viewWithTag(1)?.removeFromSuperview()
    return super.hitTest(point, with: event)
  }
}

/// A flutter platform view that displays a simple native view.
class DummyPlatformView: NSObject, FlutterPlatformView {
  private var _view: CustomView

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    _view = CustomView()
    super.init()
    createNativeView(view: _view)
  }

  func view() -> UIView {
    return _view
  }

  func createNativeView(view _view: CustomView) {
    let nativeLabel = UILabel()
    _view.isUserInteractionEnabled = true
    nativeLabel.tag = 1
    nativeLabel.text = "Not Clicked"
    nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
    _view.addSubview(nativeLabel)
  }
}
