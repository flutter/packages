// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import UIKit
#endif

#if os(iOS)
  /// Implementation of `UIScrollViewDelegate` that calls to Dart in callback methods.
  class ScrollViewDelegateImpl: NSObject, UIScrollViewDelegate {
    let api: PigeonApiProtocolUIScrollViewDelegate
    unowned let registrar: ProxyAPIRegistrar

    init(api: PigeonApiProtocolUIScrollViewDelegate, registrar: ProxyAPIRegistrar) {
      self.api = api
      self.registrar = registrar
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      registrar.dispatchOnMainThread { onFailure in
        self.api.scrollViewDidScroll(
          pigeonInstance: self, scrollView: scrollView, x: scrollView.contentOffset.x,
          y: scrollView.contentOffset.y
        ) { result in
          if case .failure(let error) = result {
            onFailure("UIScrollViewDelegate.scrollViewDidScroll", error)
          }
        }
      }
    }
  }
#endif

/// ProxyApi implementation for `UIScrollViewDelegate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ScrollViewDelegateProxyAPIDelegate: PigeonApiDelegateUIScrollViewDelegate {
  #if os(iOS)
    func pigeonDefaultConstructor(pigeonApi: PigeonApiUIScrollViewDelegate) throws
      -> UIScrollViewDelegate
    {
      return ScrollViewDelegateImpl(
        api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
    }
  #endif
}
