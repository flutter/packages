// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit

/// ProxyApi implementation for `UIScrollView`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ScrollViewProxyAPIDelegate: PigeonApiDelegateUIScrollView {
  func getContentOffset(pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView) throws
    -> [Double]
  {
    let offset = pigeonInstance.contentOffset
    return [offset.x, offset.y]
  }

  func scrollBy(
    pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, x: Double, y: Double
  ) throws {
    let offset = pigeonInstance.contentOffset
    pigeonInstance.contentOffset = CGPoint(x: offset.x + x, y: offset.y + y)
  }

  func setContentOffset(
    pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, x: Double, y: Double
  ) throws {
    pigeonInstance.contentOffset = CGPoint(x: x, y: y)
  }

  func setDelegate(
    pigeonApi: PigeonApiUIScrollView, pigeonInstance: UIScrollView, delegate: UIScrollViewDelegate?
  ) throws {
    pigeonInstance.delegate = delegate
  }
}
