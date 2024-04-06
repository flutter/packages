// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit
import XCTest

@testable import pointer_interceptor_ios

class RunnerTests: XCTestCase {
  func testNonDebugMode() {
    let view = PointerInterceptorView(
      frame: CGRect(x: 0, y: 0, width: 180, height: 48.0), debug: false)

    let debugView = view.view()
    XCTAssertTrue(debugView.backgroundColor == UIColor.clear)
  }

  func testDebugMode() {
    let view = PointerInterceptorView(
      frame: CGRect(x: 0, y: 0, width: 180, height: 48.0), debug: true)

    let debugView = view.view()
    XCTAssertTrue(debugView.backgroundColor == UIColor(red: 1, green: 0, blue: 0, alpha: 0.5))
  }
}
