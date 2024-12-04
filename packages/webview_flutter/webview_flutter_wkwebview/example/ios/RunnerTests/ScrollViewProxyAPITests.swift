// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import Flutter
import XCTest

@testable import webview_flutter_wkwebview

class ScrollViewProxyAPITests: XCTestCase {
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
    let delegate = ScrollViewDelegateImpl(api: registrar.apiDelegate.pigeonApiUIScrollViewDelegate(registrar))
    try? api.pigeonDelegate.setDelegate(pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    XCTAssertEqual(instance.setDelegateArgs, [delegate])
  }
}

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
  
  override var delegate: (any UIScrollViewDelegate)? {
    get {
      return nil
    }
    set {
      setDelegateArgs = ([newValue] as! [AnyHashable?])
    }
  }
}
