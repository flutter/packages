// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

/// Protocol for obtaining the view controller containing the Flutter content.
protocol ViewProvider: AnyObject {
  /// The view controller containing the Flutter content.
  var viewController: UIViewController? { get }
}

/// A default implementation of the ViewProvider protocol.
final class DefaultViewProvider: ViewProvider {
  private let registrar: FlutterPluginRegistrar

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  var viewController: UIViewController? {
    registrar.viewController
  }
}
