// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

open class ProxyApiDelegate: PigeonProxyApiDelegate {
  func pigeonApiIMAAdDisplayContainer(_ registrar: PigeonProxyApiRegistrar)
    -> PigeonApiIMAAdDisplayContainer
  {
    return PigeonApiIMAAdDisplayContainer(
      pigeonRegistrar: registrar, delegate: AdDisplayContainerProxyAPIDelegate())
  }

  func pigeonApiUIViewController(_ registrar: PigeonProxyApiRegistrar) -> PigeonApiUIViewController
  {
    return PigeonApiUIViewController(
      pigeonRegistrar: registrar, delegate: ViewControllerProxyAPIDelegate())
  }

  func pigeonApiIMAContentPlayhead(_ registrar: PigeonProxyApiRegistrar)
    -> PigeonApiIMAContentPlayhead
  {
    return PigeonApiIMAContentPlayhead(
      pigeonRegistrar: registrar, delegate: ContentPlayheadProxyAPIDelegate())
  }

  func pigeonApiIMAAdsLoader(_ registrar: PigeonProxyApiRegistrar) -> PigeonApiIMAAdsLoader {
    return PigeonApiIMAAdsLoader(pigeonRegistrar: registrar, delegate: AdsLoaderProxyAPIDelegate())
  }

  func pigeonApiIMAAdsRequest(_ registrar: PigeonProxyApiRegistrar) -> PigeonApiIMAAdsRequest {
    return PigeonApiIMAAdsRequest(
      pigeonRegistrar: registrar, delegate: AdsRequestProxyAPIDelegate())
  }

  func pigeonApiIMAAdsLoaderDelegate(_ registrar: PigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsLoaderDelegate
  {
    return PigeonApiIMAAdsLoaderDelegate(
      pigeonRegistrar: registrar, delegate: AdsLoaderDelegateProxyAPIDelegate())
  }

  func pigeonApiIMAAdsLoadedData(_ registrar: PigeonProxyApiRegistrar) -> PigeonApiIMAAdsLoadedData
  {
    return PigeonApiIMAAdsLoadedData(
      pigeonRegistrar: registrar, delegate: AdsLoadedDataProxyAPIDelegate())
  }

  func pigeonApiIMAAdLoadingErrorData(_ registrar: PigeonProxyApiRegistrar)
    -> PigeonApiIMAAdLoadingErrorData
  {
    return PigeonApiIMAAdLoadingErrorData(
      pigeonRegistrar: registrar, delegate: AdLoadingErrorDataProxyAPIDelegate())
  }

  func pigeonApiIMAAdError(_ registrar: PigeonProxyApiRegistrar) -> PigeonApiIMAAdError {
    return PigeonApiIMAAdError(pigeonRegistrar: registrar, delegate: AdErrorProxyAPIDelegate())
  }

  func pigeonApiIMAAdsManager(_ registrar: PigeonProxyApiRegistrar) -> PigeonApiIMAAdsManager {
    return PigeonApiIMAAdsManager(
      pigeonRegistrar: registrar, delegate: AdsManagerProxyAPIDelegate())
  }

  func pigeonApiIMAAdsManagerDelegate(_ registrar: PigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsManagerDelegate
  {
    return PigeonApiIMAAdsManagerDelegate(
      pigeonRegistrar: registrar, delegate: AdsManagerDelegateProxyAPIDelegate())
  }

  func pigeonApiIMAAdEvent(_ registrar: PigeonProxyApiRegistrar) -> PigeonApiIMAAdEvent {
    return PigeonApiIMAAdEvent(pigeonRegistrar: registrar, delegate: AdEventProxyAPIDelegate())
  }

  func pigeonApiIMAAdsRenderingSettings(_ registrar: PigeonProxyApiRegistrar)
    -> PigeonApiIMAAdsRenderingSettings
  {
    PigeonApiIMAAdsRenderingSettings(
      pigeonRegistrar: registrar, delegate: AdsRenderingSettingsProxyAPIDelegate())
  }
}
