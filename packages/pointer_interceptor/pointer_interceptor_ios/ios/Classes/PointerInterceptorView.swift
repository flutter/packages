// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Flutter
import UIKit

public class PointerInterceptorView: NSObject, FlutterPlatformView {

  let interceptorView: UIView

  init(frame: CGRect, debug: Bool) {
    interceptorView = UIView(frame: frame)
    interceptorView.backgroundColor =
      debug ? UIColor(red: 1, green: 0, blue: 0, alpha: 0.5) : UIColor.clear
  }

  public func view() -> UIView {
    return interceptorView
  }
}
