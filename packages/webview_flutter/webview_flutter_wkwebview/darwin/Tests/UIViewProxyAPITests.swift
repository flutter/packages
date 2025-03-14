// Copyright 2013 The Flutter Authors. All rights reserved.
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
      let value = 0xFFF4_4336
      try? api.pigeonDelegate.setBackgroundColor(
        pigeonApi: api, pigeonInstance: instance, value: Int64(value))

      let red = CGFloat(Double((value >> 16 & 0xff)) / 255.0)
      let green = CGFloat(Double(value >> 8 & 0xff) / 255.0)
      let blue = CGFloat(Double(value & 0xff) / 255.0)
      let alpha = CGFloat(Double(value >> 24 & 0xff) / 255.0)

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
