// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi delegate implementation for `IMAAdsRenderingSettings`.
///
/// This class may handle instantiating native object instances that are attached to a Dart
/// instance or handle method calls on the associated native class or an instance of that class.
class AdsRenderingSettingsProxyAPIDelegate: PigeonApiDelegateIMAAdsRenderingSettings {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiIMAAdsRenderingSettings) throws
    -> IMAAdsRenderingSettings
  {
    return IMAAdsRenderingSettings()
  }

  func setMimeTypes(
    pigeonApi: PigeonApiIMAAdsRenderingSettings, pigeonInstance: IMAAdsRenderingSettings,
    types: [String]?
  ) throws {
    pigeonInstance.mimeTypes = types
  }

  func setBitrate(
    pigeonApi: PigeonApiIMAAdsRenderingSettings, pigeonInstance: IMAAdsRenderingSettings,
    bitrate: Int64
  ) throws {
    pigeonInstance.bitrate = Int(bitrate)
  }

  func setLoadVideoTimeout(
    pigeonApi: PigeonApiIMAAdsRenderingSettings, pigeonInstance: IMAAdsRenderingSettings,
    seconds: Double
  ) throws {
    pigeonInstance.loadVideoTimeout = seconds
  }

  func setPlayAdsAfterTime(
    pigeonApi: PigeonApiIMAAdsRenderingSettings, pigeonInstance: IMAAdsRenderingSettings,
    seconds: Double
  ) throws {
    pigeonInstance.playAdsAfterTime = seconds
  }

  func setUIElements(
    pigeonApi: PigeonApiIMAAdsRenderingSettings, pigeonInstance: IMAAdsRenderingSettings,
    types: [UIElementType]?
  ) throws {
    let nativeUiElementTypes: [NSNumber]? = try types?.map { type in
      switch type {
      case .adAttribution:
        return IMAUiElementType.elements_AD_ATTRIBUTION.rawValue as NSNumber
      case .countdown:
        return IMAUiElementType.elements_COUNTDOWN.rawValue as NSNumber
      case .unknown:
        throw (pigeonApi.pigeonRegistrar.apiDelegate as! ProxyApiDelegate).createUnknownEnumError(
          withEnum: type)
      }
    }

    pigeonInstance.uiElements = nativeUiElementTypes
  }

  func setEnablePreloading(
    pigeonApi: PigeonApiIMAAdsRenderingSettings, pigeonInstance: IMAAdsRenderingSettings,
    enable: Bool
  ) throws {
    pigeonInstance.enablePreloading = enable
  }

  func setLinkOpenerPresentingController(
    pigeonApi: PigeonApiIMAAdsRenderingSettings, pigeonInstance: IMAAdsRenderingSettings,
    controller: UIViewController
  ) throws {
    pigeonInstance.linkOpenerPresentingController = controller
  }
}
