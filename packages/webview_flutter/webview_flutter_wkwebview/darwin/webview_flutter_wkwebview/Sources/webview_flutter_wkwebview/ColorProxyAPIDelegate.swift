// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import UIKit
#endif

/// ProxyApi implementation for `UIColor`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ColorProxyAPIDelegate: PigeonApiDelegateUIColor {
  #if os(iOS)
    func pigeonDefaultConstructor(
      pigeonApi: PigeonApiUIColor, red: Double, green: Double, blue: Double, alpha: Double
    ) throws -> UIColor {
      return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
  #endif
}
