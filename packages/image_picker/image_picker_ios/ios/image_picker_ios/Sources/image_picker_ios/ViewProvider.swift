// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

protocol ViewProvider: AnyObject {
    var viewController: UIViewController? { get }
}

final class DefaultViewProvider: NSObject, ViewProvider {
    private let registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    var viewController: UIViewController? {
        return registrar.viewController
    }
}
