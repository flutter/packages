// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing
import UIKit

@testable import pointer_interceptor_ios

@MainActor
struct RunnerTests {
  @Test(arguments: [
    (false, UIColor.clear),
    (true, UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)),
  ])
  func debugMode(debug: Bool, expectedColor: UIColor) {
    let view = PointerInterceptorView(
      frame: CGRect(x: 0, y: 0, width: 180, height: 48.0), debug: debug)

    let debugView = view.view()
    #expect(debugView.backgroundColor == expectedColor)
  }
}
