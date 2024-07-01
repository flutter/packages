// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads

final class ViewControllerTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewController(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api)

    XCTAssertNotNil(instance)
  }

  func testView() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewController(registrar)

    let instance = UIViewController()
    let view = try? api.pigeonDelegate.view(pigeonApi: api, pigeonInstance: instance)

    XCTAssertNotNil(view)
  }
}
