// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

class ScrollViewProxyAPITests: XCTestCase {
  #if os(iOS)
    @MainActor func testGetContentOffset() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      let value = try? api.pigeonDelegate.getContentOffset(pigeonApi: api, pigeonInstance: instance)

      XCTAssertEqual(value, [instance.contentOffset.x, instance.contentOffset.y])
    }

    @MainActor func testScrollBy() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      instance.contentOffset = CGPoint(x: 1.0, y: 1.0)
      try? api.pigeonDelegate.scrollBy(pigeonApi: api, pigeonInstance: instance, x: 1.0, y: 1.0)

      XCTAssertEqual(instance.setContentOffsetArgs as? [Double], [2.0, 2.0])
    }

    @MainActor func testSetContentOffset() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      let x = 1.0
      let y = 1.0
      try? api.pigeonDelegate.setContentOffset(pigeonApi: api, pigeonInstance: instance, x: x, y: y)

      XCTAssertEqual(instance.setContentOffsetArgs as? [Double], [x, y])
    }

    @MainActor func testSetDelegate() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      let delegate = ScrollViewDelegateImpl(
        api: registrar.apiDelegate.pigeonApiUIScrollViewDelegate(registrar), registrar: registrar)
      try? api.pigeonDelegate.setDelegate(
        pigeonApi: api, pigeonInstance: instance, delegate: delegate)

      XCTAssertEqual(instance.setDelegateArgs, [delegate])
    }

    @MainActor
    func testSetBounces() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setBounces(pigeonApi: api, pigeonInstance: instance, value: value)

      XCTAssertEqual(instance.bounces, value)
    }

    #if compiler(>=6.0)
      @available(iOS 17.4, *)
      @MainActor
      func testSetBouncesHorizontally() {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

        let instance = TestScrollView()
        let value = true
        try? api.pigeonDelegate.setBouncesHorizontally(
          pigeonApi: api, pigeonInstance: instance, value: value)

        XCTAssertEqual(instance.bouncesHorizontally, value)
      }

      @available(iOS 17.4, *)
      @MainActor
      func testSetBouncesVertically() {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

        let instance = TestScrollView()
        let value = true
        try? api.pigeonDelegate.setBouncesVertically(
          pigeonApi: api, pigeonInstance: instance, value: value)

        XCTAssertEqual(instance.bouncesVertically, value)
      }
    #endif

    @MainActor
    func testSetAlwaysBounceVertical() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setAlwaysBounceVertical(
        pigeonApi: api, pigeonInstance: instance, value: value)

      XCTAssertEqual(instance.alwaysBounceVertical, value)
    }

    @MainActor
    func testSetAlwaysBounceHorizontal() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setAlwaysBounceHorizontal(
        pigeonApi: api, pigeonInstance: instance, value: value)

      XCTAssertEqual(instance.alwaysBounceHorizontal, value)
    }

    @MainActor func testSetShowsVerticalScrollIndicator() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setShowsVerticalScrollIndicator(
        pigeonApi: api, pigeonInstance: instance, value: value)

      XCTAssertEqual(instance.showsVerticalScrollIndicator, value)
    }

    @MainActor func testSetShowsHorizontalScrollIndicator() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setShowsHorizontalScrollIndicator(
        pigeonApi: api, pigeonInstance: instance, value: value)

      XCTAssertEqual(instance.showsHorizontalScrollIndicator, value)
    }
  #endif
}

#if os(iOS)
  class TestScrollView: UIScrollView {
    var setContentOffsetArgs: [AnyHashable?]? = nil
    var setDelegateArgs: [AnyHashable?]? = nil

    override var contentOffset: CGPoint {
      get {
        return CGPoint(x: 1.0, y: 1.0)
      }
      set {
        setContentOffsetArgs = [newValue.x, newValue.y]
      }
    }

    override var delegate: UIScrollViewDelegate? {
      get {
        return nil
      }
      set {
        setDelegateArgs = ([newValue] as! [AnyHashable?])
      }
    }
  }
#endif
