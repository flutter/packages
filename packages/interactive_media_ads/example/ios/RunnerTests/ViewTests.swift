// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads

final class ViewTests: XCTestCase {
  func testGetWindow() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIView(registrar)

    let instance = TestView()
    let window = try? api.pigeonDelegate.getWindow(pigeonApi: api, pigeonInstance: instance)

    XCTAssertNotNil(window)
  }
}

class TestView: UIView {
  override var window: UIWindow? {
    return UIWindow()
  }
}
