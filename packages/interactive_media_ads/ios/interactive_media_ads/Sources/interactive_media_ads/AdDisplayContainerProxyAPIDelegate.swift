//
//  AdDisplayContainerProxyApi.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

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
