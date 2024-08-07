// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit

class ViewControllerImpl: UIViewController {
  let api: PigeonApiProtocolUIViewController

  init(api: PigeonApiProtocolUIViewController) {
    self.api = api
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    api.viewDidAppear(pigeonInstance: self, animated: animated) { _ in }
  }
}

/// ProxyApi delegate implementation for `UIViewController`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class ViewControllerProxyAPIDelegate: PigeonApiDelegateUIViewController {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiUIViewController) throws -> UIViewController {
    return ViewControllerImpl(api: pigeonApi)
  }

  func view(pigeonApi: PigeonApiUIViewController, pigeonInstance: UIViewController) throws -> UIView
  {
    return pigeonInstance.view
  }
}
