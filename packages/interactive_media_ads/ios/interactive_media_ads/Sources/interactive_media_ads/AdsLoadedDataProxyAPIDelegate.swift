//
//  AdsLoadedData.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdsLoadedDataProxyAPIDelegate: PigeonDelegateIMAAdsLoadedData {
  func adsManager(pigeonApi: PigeonApiIMAAdsLoadedData, pigeonInstance: IMAAdsLoadedData) throws
    -> IMAAdsManager?
  {
    return pigeonInstance.adsManager
  }
}
