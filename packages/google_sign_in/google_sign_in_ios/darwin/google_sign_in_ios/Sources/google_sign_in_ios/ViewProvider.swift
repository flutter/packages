// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(macOS)
  import AppKit
  import FlutterMacOS
#else
  import Flutter
  import UIKit
#endif

/// Protocol for obtaining the view containing the Flutter content.
protocol ViewProvider: AnyObject {
  #if os(macOS)
    /// The view containing the Flutter content.
    var view: NSView? { get }
  #else
    /// The view controller containing the Flutter content.
    var viewController: UIViewController? { get }
  #endif
}

/// Implementation of `ViewProvider` that passes through to the registrar.
final class DefaultViewProvider: ViewProvider {
  /// The registrar backing the provider.
  let registrar: FlutterPluginRegistrar

  /// Returns a provider backed by the given registrar.
  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  #if os(macOS)
    var view: NSView? {
      registrar.view
    }
  #else
    var viewController: UIViewController? {
      registrar.viewController
    }
  #endif
}
