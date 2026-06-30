// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
@testable import image_picker_ios
import UIKit
import XCTest

class ViewProviderTests: XCTestCase {
    @MainActor func testDefaultViewProvider_ReturnsViewControllerFromRegistrar() {
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

        func messenger() -> FlutterBinaryMessenger {
            fatalError()
        }

        func textures() -> FlutterTextureRegistry {
            fatalError()
        }

        func register(_: FlutterPlatformViewFactory, withId _: String) {}
        func register(_: FlutterPlatformViewFactory, withId _: String, gestureRecognizersBlockingPolicy _: FlutterPlatformViewGestureRecognizersBlockingPolicy) {}
        func publish(_: NSObject) {}
        func addMethodCallDelegate(_: FlutterPlugin, channel _: FlutterMethodChannel) {}
        func addApplicationDelegate(_: FlutterPlugin) {}
        func lookupKey(forAsset _: String) -> String {
            return ""
        }

        func lookupKey(forAsset _: String, fromPackage _: String) -> String {
            return ""
        }

        func addSceneDelegate(_: FlutterSceneLifeCycleDelegate) {}
    }
}
