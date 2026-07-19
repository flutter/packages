// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

@Suite struct ScrollViewProxyAPITests {
  #if os(iOS)
    @MainActor @Test func getContentOffset() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      let value = try api.pigeonDelegate.getContentOffset(pigeonApi: api, pigeonInstance: instance)

      #expect(value == [instance.contentOffset.x, instance.contentOffset.y] as [Double])
    }

    @MainActor @Test func scrollBy() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      instance.contentOffset = CGPoint(x: 1.0, y: 1.0)
      try? api.pigeonDelegate.scrollBy(pigeonApi: api, pigeonInstance: instance, x: 1.0, y: 1.0)

      #expect(instance.setContentOffsetArgs as? [Double] == [2.0, 2.0])
    }

    @MainActor @Test func setContentOffset() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      let x = 1.0
      let y = 1.0
      try? api.pigeonDelegate.setContentOffset(pigeonApi: api, pigeonInstance: instance, x: x, y: y)

      #expect(instance.setContentOffsetArgs as? [Double] == [x, y])
    }

    @MainActor @Test func setDelegate() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView(frame: .zero)
      let delegate = ScrollViewDelegateImpl(
        api: registrar.apiDelegate.pigeonApiUIScrollViewDelegate(registrar), registrar: registrar)
      try? api.pigeonDelegate.setDelegate(
        pigeonApi: api, pigeonInstance: instance, delegate: delegate)

      #expect(instance.setDelegateArgs == [delegate])
    }

    @MainActor
    @Test func setBounces() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setBounces(pigeonApi: api, pigeonInstance: instance, value: value)

      #expect(instance.bounces == value)
    }

    #if compiler(>=6.0)
      @available(iOS 17.4, *)
      @MainActor
      @Test func setBouncesHorizontally() throws {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

        let instance = TestScrollView()
        let value = true
        try? api.pigeonDelegate.setBouncesHorizontally(
          pigeonApi: api, pigeonInstance: instance, value: value)

        #expect(instance.bouncesHorizontally == value)
      }

      @available(iOS 17.4, *)
      @MainActor
      @Test func setBouncesVertically() throws {
        let registrar = TestProxyApiRegistrar()
        let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

        let instance = TestScrollView()
        let value = true
        try? api.pigeonDelegate.setBouncesVertically(
          pigeonApi: api, pigeonInstance: instance, value: value)

        #expect(instance.bouncesVertically == value)
      }
    #endif

    @MainActor
    @Test func setAlwaysBounceVertical() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setAlwaysBounceVertical(
        pigeonApi: api, pigeonInstance: instance, value: value)

      #expect(instance.alwaysBounceVertical == value)
    }

    @MainActor
    @Test func setAlwaysBounceHorizontal() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setAlwaysBounceHorizontal(
        pigeonApi: api, pigeonInstance: instance, value: value)

      #expect(instance.alwaysBounceHorizontal == value)
    }

    @MainActor @Test func setShowsVerticalScrollIndicator() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setShowsVerticalScrollIndicator(
        pigeonApi: api, pigeonInstance: instance, value: value)

      #expect(instance.showsVerticalScrollIndicator == value)
    }

    @MainActor @Test func setShowsHorizontalScrollIndicator() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIScrollView(registrar)

      let instance = TestScrollView()
      let value = true
      try? api.pigeonDelegate.setShowsHorizontalScrollIndicator(
        pigeonApi: api, pigeonInstance: instance, value: value)

      #expect(instance.showsHorizontalScrollIndicator == value)
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
