// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import interactive_media_ads

@MainActor
struct ViewControllerTests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewController(registrar)

    let instance = try api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
  }

  @Test func view() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewController(registrar)

    let instance = UIViewController()
    let view = try api.pigeonDelegate.view(pigeonApi: api, pigeonInstance: instance)
  }

  @Test func viewDidAppear() throws {
    let api = TestUIViewControllerApi()
    let instance = ViewControllerImpl(api: api)

    instance.viewDidAppear(true)

    let args = try #require(api.viewDidAppearArgs)
    #expect(args == [instance, true])
  }
}

class TestUIViewControllerApi: PigeonApiProtocolUIViewController {
  var viewDidAppearArgs: [AnyHashable]? = nil

  func viewDidAppear(
    pigeonInstance pigeonInstanceArg: UIViewController, animated animatedArg: Bool,
    completion: @escaping (Result<Void, interactive_media_ads.PigeonError>) -> Void
  ) {
    viewDidAppearArgs = [pigeonInstanceArg, animatedArg]
  }
}
