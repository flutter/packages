// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import UIKit

class ViewControllerProxyAPIDelegate: PigeonDelegateUIViewController {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiUIViewController) throws -> UIViewController {
    return UIViewController()
  }

  func view(pigeonApi: PigeonApiUIViewController, pigeonInstance: UIViewController) throws -> UIView
  {
    return pigeonInstance.view
  }
}
