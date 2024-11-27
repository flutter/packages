// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit

/// Implementation of `UIScrollViewDelegate` that calls to Dart in callback methods.
class ScrollViewDelegateImpl: NSObject, UIScrollViewDelegate {
  let api: PigeonApiProtocolUIScrollViewDelegate

  init(api: PigeonApiProtocolUIScrollViewDelegate) {
    self.api = api
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    api.scrollViewDidScroll(pigeonInstance: self, scrollView: scrollView, x: scrollView.contentOffset.x, y: scrollView.contentOffset.y) {  _ in }
  }
}

/// ProxyApi implementation for `UIScrollViewDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ScrollViewDelegateProxyAPIDelegate : PigeonApiDelegateUIScrollViewDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiUIScrollViewDelegate) throws -> UIScrollViewDelegate {
    return ScrollViewDelegateImpl(api: pigeonApi)
  }
}
