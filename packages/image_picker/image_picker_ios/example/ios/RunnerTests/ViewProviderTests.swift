// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import Flutter
import UIKit

@testable import image_picker_ios

class ViewProviderTests: XCTestCase {

  func testDefaultViewProvider_ReturnsViewControllerFromRegistrar() {
    let mockRegistrar = MockPluginRegistrar()
    let expectedVC = UIViewController()
    mockRegistrar.mockViewController = expectedVC

    let provider = DefaultViewProvider(registrar: mockRegistrar)
    XCTAssertEqual(provider.viewController, expectedVC)
  }

  class MockPluginRegistrar: NSObject, FlutterPluginRegistrar, @unchecked Sendable {
    var mockViewController: UIViewController?

    var viewController: UIViewController? {
      return mockViewController
    }

    func messenger() -> FlutterBinaryMessenger { fatalError() }
    func textures() -> FlutterTextureRegistry { fatalError() }
    func register(_ factory: FlutterPlatformViewFactory, withId id: String) {}
    func register(_ factory: FlutterPlatformViewFactory, withId id: String, gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy) {}
    func publish(_ value: NSObject) {}
    func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}
    func addApplicationDelegate(_ delegate: FlutterPlugin) {}
    func lookupKey(forAsset asset: String) -> String { return "" }
    func lookupKey(forAsset asset: String, fromPackage package: String) -> String { return "" }
    func addSceneDelegate(_ delegate: FlutterSceneLifeCycleDelegate) {}
  }
}
