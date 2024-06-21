//
//  AdLoadingErrorDataProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation
import GoogleInteractiveMediaAds

class AdLoadingErrorDataProxyAPIDelegate: PigeonDelegateIMAAdLoadingErrorData {
  func adError(pigeonApi: PigeonApiIMAAdLoadingErrorData, pigeonInstance: IMAAdLoadingErrorData)
    throws -> IMAAdError
  {
    return pigeonInstance.adError
  }
}
