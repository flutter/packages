//
//  AdsManagerDelegateProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdsManagerDelegateImpl: NSObject, IMAAdsManagerDelegate {
  let api: PigeonApiIMAAdsManagerDelegate
  
  init(api: PigeonApiIMAAdsManagerDelegate) {
    self.api = api
  }
  
  func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
    api.didReceiveAdEvent(pigeonInstance: self, adsManager: adsManager, event: event) { _ in }
  }
  
  func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
    api.didReceiveAdError(pigeonInstance: self, adsManager: adsManager, error: error) { _ in }
  }
  
  func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
    api.didRequestContentPause(pigeonInstance: self, adsManager: adsManager) { _ in }
  }
  
  func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
    api.didRequestContentResume(pigeonInstance: self, adsManager: adsManager) { _ in }
  }
}

class AdsManagerDelegateProxyAPIDelegate: PigeonDelegateIMAAdsManagerDelegate {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsManagerDelegate) throws -> IMAAdsManagerDelegate {
    return AdsManagerDelegateImpl(api: pigeonApi)
  }
}
