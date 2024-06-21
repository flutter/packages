//
//  AdsManagerProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdsManagerProxyAPIDelegate: PigeonDelegateIMAAdsManager {
  func setDelegate(
    pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager,
    delegate: IMAAdsManagerDelegate?
  ) throws {
    pigeonInstance.delegate = delegate as? AdsManagerDelegateImpl
  }

  func initialize(
    pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager,
    adsRenderingSettings: IMAAdsRenderingSettings?
  ) throws {
    pigeonInstance.initialize(with: adsRenderingSettings)
  }

  func start(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.start()
  }

  func destroy(pigeonApi: PigeonApiIMAAdsManager, pigeonInstance: IMAAdsManager) throws {
    pigeonInstance.destroy()
  }
}
