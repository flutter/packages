// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

class ScrollViewDelegateProxyAPITests: XCTestCase {
  #if os(iOS)
    func testPigeonDefaultConstructor() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollViewDelegate(registrar)

      let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
      XCTAssertNotNil(instance)
    }

    @MainActor func testScrollViewDidScroll() {
      let api = TestScrollViewDelegateApi()
      let registrar = TestProxyApiRegistrar()
      let instance = ScrollViewDelegateImpl(api: api, registrar: registrar)
      let scrollView = UIScrollView(frame: .zero)
      let x = 1.0
      let y = 1.0
      scrollView.contentOffset = CGPoint(x: x, y: y)
      instance.scrollViewDidScroll(scrollView)

      XCTAssertEqual(api.scrollViewDidScrollArgs, [scrollView, x, y])
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
