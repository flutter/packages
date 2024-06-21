//
//  AdsLoaderDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdsLoaderDelegateImpl: IMAAdsLoaderDelegate {
  let api: PigeonApiIMAAdsLoaderDelegate
  
  init(api: PigeonApiIMAAdsLoaderDelegate) {
    self.api = api
  }
  
  func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
    api.adLoaderLoadedWith(pigeonInstance: self, loader: loader, adsLoadedData: adsLoadedData) { _ in }
  }
  
  func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
    api.adsLoaderFailedWithErrorData(pigeonInstance: self, loader: loader, adErrorData: adErrorData) { _ in }
  }
}

class AdsLoaderDelegateProxyAPIDelegate: PigeonDelegateIMAAdsLoaderDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsLoaderDelegate) throws -> IMAAdsLoaderDelegate {
    return AdsLoaderDelegateImpl(api: pigeonApi)
  }
}
