//
//  AdsRenderingSettingsProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdsRenderingSettingsProxyAPIDelegate: PigeonDelegateIMAAdsRenderingSettings {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsRenderingSettings) throws
    -> IMAAdsRenderingSettings
  {
    return IMAAdsRenderingSettings()
  }
}
