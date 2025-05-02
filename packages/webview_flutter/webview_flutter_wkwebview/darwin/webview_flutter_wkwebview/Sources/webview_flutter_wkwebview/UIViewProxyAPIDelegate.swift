// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import UIKit
#endif

/// ProxyApi implementation for `UIView`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class UIViewProxyAPIDelegate: PigeonApiDelegateUIView {
  #if os(iOS)
    func setBackgroundColor(pigeonApi: PigeonApiUIView, pigeonInstance: UIView, value: Int64?)
      throws
    {
      if value == nil {
        pigeonInstance.backgroundColor = nil
      } else {
        let red = CGFloat(Double((value! >> 16 & 0xff)) / 255.0)
        let green = CGFloat(Double(value! >> 8 & 0xff) / 255.0)
        let blue = CGFloat(Double(value! & 0xff) / 255.0)
        let alpha = CGFloat(Double(value! >> 24 & 0xff) / 255.0)

        pigeonInstance.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
      }
    }

    func setOpaque(pigeonApi: PigeonApiUIView, pigeonInstance: UIView, opaque: Bool) throws {
      pigeonInstance.isOpaque = opaque
    }
  #endif
}
