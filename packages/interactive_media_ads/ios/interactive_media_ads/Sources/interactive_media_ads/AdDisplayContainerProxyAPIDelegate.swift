// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

class AdDisplayContainerProxyAPIDelegate: PigeonDelegateIMAAdDisplayContainer {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiIMAAdDisplayContainer, adContainer: UIView,
    adContainerViewController: UIViewController?
  ) throws -> IMAAdDisplayContainer {
    return IMAAdDisplayContainer(
      adContainer: adContainer, viewController: adContainerViewController)
  }
}
