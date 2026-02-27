// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

class UIViewProxyAPITests: XCTestCase {
  #if os(iOS)
    @MainActor func testSetBackgroundColor() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIView(registrar)

      let instance = UIView(frame: .zero)
      let red = 0.1
      let green = 0.2
      let blue = 0.3
      let alpha = 0.4
      try? api.pigeonDelegate.setBackgroundColor(
        pigeonApi: api, pigeonInstance: instance,
        value: UIColor(red: red, green: green, blue: blue, alpha: alpha))

      XCTAssertEqual(
        instance.backgroundColor, UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }

    @MainActor func testSetOpaque() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIView(registrar)

      let instance = UIView(frame: .zero)
      let opaque = true
      try? api.pigeonDelegate.setOpaque(pigeonApi: api, pigeonInstance: instance, opaque: opaque)

      XCTAssertEqual(instance.isOpaque, opaque)
    }
  #endif
}
