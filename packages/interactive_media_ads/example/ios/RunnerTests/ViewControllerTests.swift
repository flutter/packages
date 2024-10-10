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

  func testViewDidAppear() {
    let api = TestUIViewControllerApi()
    let instance = ViewControllerImpl(api: api)

    instance.viewDidAppear(true)

    XCTAssertEqual(api.viewDidAppearArgs, [instance, true])
  }
}

class TestUIViewControllerApi: PigeonApiProtocolUIViewController {
  var viewDidAppearArgs: [AnyHashable?]? = nil

  func viewDidAppear(
    pigeonInstance pigeonInstanceArg: UIViewController, animated animatedArg: Bool,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    viewDidAppearArgs = [pigeonInstanceArg, animatedArg]
  }
}
