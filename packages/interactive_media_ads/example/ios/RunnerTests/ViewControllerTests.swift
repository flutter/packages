// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import interactive_media_ads

@MainActor
struct ViewControllerTests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewController(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api)

    #expect(instance != nil)
  }

  @Test func view() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIViewController(registrar)

    let instance = UIViewController()
    let view = try? api.pigeonDelegate.view(pigeonApi: api, pigeonInstance: instance)

    #expect(view != nil)
  }

  @Test func viewDidAppear() {
    let api = TestUIViewControllerApi()
    let instance = ViewControllerImpl(api: api)

    instance.viewDidAppear(true)

    #expect(api.viewDidAppearArgs as! [AnyHashable] == [instance, true])
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
