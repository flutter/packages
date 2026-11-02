// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import Cocoa
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Protocol for obtaining the view containing the Flutter content.
protocol ViewProvider {
  #if os(macOS)
    /// The view containing the Flutter content.
    var view: NSView? { get }
  #else
    /// The view controller containing the Flutter content.
    var viewController: UIViewController? { get }
  #endif
}

/// A default implementation of the ViewProvider protocol.
class DefaultViewProvider: ViewProvider {
  /// The backing registrar.
  private let registrar: FlutterPluginRegistrar

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  #if os(macOS)
    var view: NSView? { registrar.view }
  #else
    var viewController: UIViewController? { registrar.viewController }
  #endif
}
