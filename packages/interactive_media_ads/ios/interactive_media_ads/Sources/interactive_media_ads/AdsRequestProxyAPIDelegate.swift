//
//  AdsRequestProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdsRequestProxyAPIDelegate: PigeonDelegateIMAAdsRequest {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiIMAAdsRequest, adTagUrl: String, adDisplayContainer: IMAAdDisplayContainer,
    contentPlayhead: IMAContentPlayhead?
  ) throws -> IMAAdsRequest {
    return IMAAdsRequest(
      adTagUrl: adTagUrl, adDisplayContainer: adDisplayContainer,
      contentPlayhead: contentPlayhead as? ContentPlayheadImpl, userContext: nil)
  }
}
