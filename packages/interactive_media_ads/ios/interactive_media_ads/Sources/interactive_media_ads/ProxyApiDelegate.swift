// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// Implementation of `PigeonProxyApiDelegate` that provides each ProxyApi delegate implementation
/// and any additional resources needed by an implementation.
open class ProxyApiDelegate: InteractiveMediaAdsLibraryPigeonProxyApiDelegate {
  func createUnknownEnumError(withEnum enumValue: Any) -> PigeonError {
    return PigeonError(
      code: "UnknownEnumError", message: "\(enumValue) doesn't represent a native value.",
      details: nil)
  }

  func pigeonApiUIView(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiUIView
  {
    return PigeonApiUIView(pigeonRegistrar: registrar, delegate: ViewProxyAPIDelegate())
  }

  func pigeonApiIMAAdDisplayContainer(
    _ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar
  )
    -> PigeonApiIMAAdDisplayContainer
  {
    return PigeonApiIMAAdDisplayContainer(
      pigeonRegistrar: registrar, delegate: AdDisplayContainerProxyAPIDelegate())
  }

  func pigeonApiUIViewController(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiUIViewController
  {
    return PigeonApiUIViewController(
      pigeonRegistrar: registrar, delegate: ViewControllerProxyAPIDelegate())
  }

  func pigeonApiIMAContentPlayhead(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAContentPlayhead
  {
    return PigeonApiIMAContentPlayhead(
      pigeonRegistrar: registrar, delegate: ContentPlayheadProxyAPIDelegate())
  }

  func pigeonApiIMAAdsLoader(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsLoader
  {
    return PigeonApiIMAAdsLoader(pigeonRegistrar: registrar, delegate: AdsLoaderProxyAPIDelegate())
  }

  func pigeonApiIMAAdsRequest(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsRequest
  {
    return PigeonApiIMAAdsRequest(
      pigeonRegistrar: registrar, delegate: AdsRequestProxyAPIDelegate())
  }

  func pigeonApiIMAAdsLoaderDelegate(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsLoaderDelegate
  {
    return PigeonApiIMAAdsLoaderDelegate(
      pigeonRegistrar: registrar, delegate: AdsLoaderDelegateProxyAPIDelegate())
  }

  func pigeonApiIMAAdsLoadedData(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsLoadedData
  {
    return PigeonApiIMAAdsLoadedData(
      pigeonRegistrar: registrar, delegate: AdsLoadedDataProxyAPIDelegate())
  }

  func pigeonApiIMAAdLoadingErrorData(
    _ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar
  )
    -> PigeonApiIMAAdLoadingErrorData
  {
    return PigeonApiIMAAdLoadingErrorData(
      pigeonRegistrar: registrar, delegate: AdLoadingErrorDataProxyAPIDelegate())
  }

  func pigeonApiIMAAdError(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdError
  {
    return PigeonApiIMAAdError(pigeonRegistrar: registrar, delegate: AdErrorProxyAPIDelegate())
  }

  func pigeonApiIMAAdsManager(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsManager
  {
    return PigeonApiIMAAdsManager(
      pigeonRegistrar: registrar, delegate: AdsManagerProxyAPIDelegate())
  }

  func pigeonApiIMAAdsManagerDelegate(
    _ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar
  )
    -> PigeonApiIMAAdsManagerDelegate
  {
    return PigeonApiIMAAdsManagerDelegate(
      pigeonRegistrar: registrar, delegate: AdsManagerDelegateProxyAPIDelegate())
  }

  func pigeonApiIMAAdEvent(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdEvent
  {
    return PigeonApiIMAAdEvent(pigeonRegistrar: registrar, delegate: AdEventProxyAPIDelegate())
  }

  func pigeonApiIMAAdsRenderingSettings(
    _ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar
  )
    -> PigeonApiIMAAdsRenderingSettings
  {
    return PigeonApiIMAAdsRenderingSettings(
      pigeonRegistrar: registrar, delegate: AdsRenderingSettingsProxyAPIDelegate())
  }

  func pigeonApiIMAFriendlyObstruction(
    _ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar
  )
    -> PigeonApiIMAFriendlyObstruction
  {
    return PigeonApiIMAFriendlyObstruction(
      pigeonRegistrar: registrar, delegate: FriendlyObstructionProxyAPIDelegate())
  }

  func pigeonApiIMACompanionAd(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMACompanionAd
  {
    return PigeonApiIMACompanionAd(
      pigeonRegistrar: registrar, delegate: CompanionAdProxyAPIDelegate())
  }

  func pigeonApiIMACompanionAdSlot(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMACompanionAdSlot
  {
    return PigeonApiIMACompanionAdSlot(
      pigeonRegistrar: registrar, delegate: CompanionAdSlotProxyAPIDelegate())
  }

  func pigeonApiIMACompanionDelegate(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMACompanionDelegate
  {
    return PigeonApiIMACompanionDelegate(
      pigeonRegistrar: registrar, delegate: CompanionDelegateProxyAPIDelegate())
  }

  func pigeonApiIMAAdPodInfo(_ registrar: InteractiveMediaAdsLibraryPigeonProxyApiRegistrar)
    -> PigeonApiIMAAdPodInfo
  {
    return PigeonApiIMAAdPodInfo(pigeonRegistrar: registrar, delegate: AdPodInfoProxyAPIDelegate())
  }
}
