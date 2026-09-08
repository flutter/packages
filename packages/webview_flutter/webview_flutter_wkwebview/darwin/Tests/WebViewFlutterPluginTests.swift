// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
  import UIKit
#endif

@Suite struct WebViewFlutterPluginTests {
  #if os(iOS)
    @MainActor @Test func instanceManagerIsDeallocatedInApplicationWillTerminate() async throws {
      let plugin = WebViewFlutterPlugin(binaryMessenger: TestBinaryMessenger())
      plugin.proxyApiRegistrar!.setUp()

      let view = UIView()
      _ = plugin.proxyApiRegistrar!.instanceManager.addHostCreatedInstance(view)

      // Attaches an associated object to the InstanceManager to listen for when it is deallocated.
      var finalizer: TestFinalizer? = TestFinalizer()

      let key = malloc(1)!
      defer {
        free(key)
      }
      objc_setAssociatedObject(
        plugin.proxyApiRegistrar!.instanceManager, key, finalizer, .OBJC_ASSOCIATION_RETAIN)

      await confirmation("Wait for InstanceManager to be deallocated.") { confirm in
        TestFinalizer.onDeinit = {
          confirm()
        }

        // Ensure method is from `FlutterApplicationLifeCycleDelegate`.
        (plugin as FlutterApplicationLifeCycleDelegate).applicationWillTerminate!(
          UIApplication.shared)
        #expect(plugin.proxyApiRegistrar == nil)

        finalizer = nil
      }
    }

    @MainActor @Test func instanceManagerIsDeallocatedInSceneDidDisconnect() async throws {
      let plugin = WebViewFlutterPlugin(binaryMessenger: TestBinaryMessenger())
      plugin.proxyApiRegistrar!.setUp()

      let view = UIView()
      _ = plugin.proxyApiRegistrar!.instanceManager.addHostCreatedInstance(view)

      // Attaches an associated object to the InstanceManager to listen for when it is deallocated.
      var finalizer: TestFinalizer? = TestFinalizer()

      let key = malloc(1)!
      defer {
        free(key)
      }
      objc_setAssociatedObject(
        plugin.proxyApiRegistrar!.instanceManager, key, finalizer, .OBJC_ASSOCIATION_RETAIN)

      await confirmation("Wait for InstanceManager to be deallocated.") { confirm in
        TestFinalizer.onDeinit = {
          confirm()
        }

        let scene = UIApplication.shared.connectedScenes.first!

        // Ensure method is from `FlutterSceneLifeCycleDelegate`.
        (plugin as FlutterSceneLifeCycleDelegate).sceneDidDisconnect?(scene)
        #expect(plugin.proxyApiRegistrar == nil)

        finalizer = nil
      }
    }
  #endif
}

class TestFinalizer {
  static var onDeinit: (() -> Void)?

  deinit {
    Self.onDeinit?()
  }
}
