// Copyright 2013 The Flutter Authors
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
    func setBackgroundColor(pigeonApi: PigeonApiUIView, pigeonInstance: UIView, value: UIColor?)
      throws
    {
      pigeonInstance.backgroundColor = value
    }

    func setOpaque(pigeonApi: PigeonApiUIView, pigeonInstance: UIView, opaque: Bool) throws {
      pigeonInstance.isOpaque = opaque
    }
  #endif
}
