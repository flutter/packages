// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdDisplayContainer`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdDisplayContainerProxyAPIDelegate: PigeonApiDelegateIMAAdDisplayContainer {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiIMAAdDisplayContainer, adContainer: UIView,
    companionSlots: [IMACompanionAdSlot]?, adContainerViewController: UIViewController?
  ) throws -> IMAAdDisplayContainer {
    return IMAAdDisplayContainer(
      adContainer: adContainer, viewController: adContainerViewController,
      companionSlots: companionSlots)
  }

  func adContainer(pigeonApi: PigeonApiIMAAdDisplayContainer, pigeonInstance: IMAAdDisplayContainer)
    throws -> UIView
  {
    return pigeonInstance.adContainer
  }

  func companionSlots(
    pigeonApi: PigeonApiIMAAdDisplayContainer, pigeonInstance: IMAAdDisplayContainer
  ) throws -> [IMACompanionAdSlot]? {
    return pigeonInstance.companionSlots
  }

  func setAdContainerViewController(
    pigeonApi: PigeonApiIMAAdDisplayContainer, pigeonInstance: IMAAdDisplayContainer,
    controller: UIViewController?
  ) throws {
    pigeonInstance.adContainerViewController = controller
  }

  func getAdContainerViewController(
    pigeonApi: PigeonApiIMAAdDisplayContainer, pigeonInstance: IMAAdDisplayContainer
  ) throws -> UIViewController? {
    return pigeonInstance.adContainerViewController
  }

  func registerFriendlyObstruction(
    pigeonApi: PigeonApiIMAAdDisplayContainer, pigeonInstance: IMAAdDisplayContainer,
    friendlyObstruction: IMAFriendlyObstruction
  ) throws {
    pigeonInstance.register(friendlyObstruction)
  }

  func unregisterAllFriendlyObstructions(
    pigeonApi: PigeonApiIMAAdDisplayContainer, pigeonInstance: IMAAdDisplayContainer
  ) throws {
    pigeonInstance.unregisterAllFriendlyObstructions()
  }
}
