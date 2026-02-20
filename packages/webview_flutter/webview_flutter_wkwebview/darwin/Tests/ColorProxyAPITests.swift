// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import XCTest

@testable import webview_flutter_wkwebview

class ColorProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIColor(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    XCTAssertNotNil(instance)
  }
}
