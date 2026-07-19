// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

@Suite struct UIViewProxyAPITests {
  #if os(iOS)
    @MainActor @Test func setBackgroundColor() throws {
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

      #expect(instance.backgroundColor == UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }

    @MainActor @Test func setOpaque() throws {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIView(registrar)

      let instance = UIView(frame: .zero)
      let opaque = true
      try? api.pigeonDelegate.setOpaque(pigeonApi: api, pigeonInstance: instance, opaque: opaque)

      #expect(instance.isOpaque == opaque)
    }
  #endif
}
