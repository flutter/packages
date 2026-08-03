// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

@Suite struct ScrollViewDelegateProxyAPITests {
  #if os(iOS)
    @Test func pigeonDefaultConstructor() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollViewDelegate(registrar)

      let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
      #expect(instance != nil)
    }

    @MainActor @Test func scrollViewDidScroll() throws {
      let api = TestScrollViewDelegateApi()
      let registrar = TestProxyApiRegistrar()
      let instance = ScrollViewDelegateImpl(api: api, registrar: registrar)
      let scrollView = UIScrollView(frame: .zero)
      let x = 1.0
      let y = 1.0
      scrollView.contentOffset = CGPoint(x: x, y: y)
      instance.scrollViewDidScroll(scrollView)

      #expect(api.scrollViewDidScrollArgs == [scrollView, x, y])
    }
  #endif
}

#if os(iOS)
  class TestScrollViewDelegateApi: PigeonApiProtocolUIScrollViewDelegate {
    var scrollViewDidScrollArgs: [AnyHashable?]? = nil

    func scrollViewDidScroll(
      pigeonInstance pigeonInstanceArg: UIScrollViewDelegate,
      scrollView scrollViewArg: UIScrollView, x xArg: Double, y yArg: Double,
      completion: @escaping (Result<Void, PigeonError>) -> Void
    ) {
      scrollViewDidScrollArgs = [scrollViewArg, xArg, yArg]
    }
  }
#endif
