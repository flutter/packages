// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

class ColorProxyAPITests: XCTestCase {
  #if os(iOS)
    func testPigeonDefaultConstructor() {
      let registrar = TestProxyApiRegistrar()
      let api = registrar.apiDelegate.pigeonApiUIColor(registrar)

      let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api, red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      XCTAssertNotNil(instance)
    }
  #endif
}
