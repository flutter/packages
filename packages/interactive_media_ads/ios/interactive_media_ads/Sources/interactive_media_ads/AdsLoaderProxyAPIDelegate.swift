//
//  AdsLoaderProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdsLoaderProxyAPIDelegate: PigeonDelegateIMAAdsLoader {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsLoader, settings: IMASettings?) throws
    -> IMAAdsLoader
  {
    return IMAAdsLoader(settings: settings)
  }

  func contentComplete(pigeonApi: PigeonApiIMAAdsLoader, pigeonInstance: IMAAdsLoader) throws {
    pigeonInstance.contentComplete()
  }

  func requestAds(
    pigeonApi: PigeonApiIMAAdsLoader, pigeonInstance: IMAAdsLoader, request: IMAAdsRequest
  ) throws {
    pigeonInstance.requestAds(with: request)
  }

  func setDelegate(
    pigeonApi: PigeonApiIMAAdsLoader, pigeonInstance: IMAAdsLoader, delegate: IMAAdsLoaderDelegate?
  ) throws {
    pigeonInstance.delegate = delegate
  }
}
