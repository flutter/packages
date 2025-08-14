// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import GoogleInteractiveMediaAds

/// ProxyApi implementation for `IMAAd`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class AdProxyAPIDelegate: PigeonApiDelegateIMAAd {
  func adId(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.adId
  }

  func adTitle(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.adTitle
  }

  func adDescription(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.adDescription
  }

  func adSystem(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.adSystem
  }

  func companionAds(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> [IMACompanionAd] {
    return pigeonInstance.companionAds
  }

  func contentType(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.contentType
  }

  func duration(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Double {
    return pigeonInstance.duration
  }

  func uiElements(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> [UIElementType] {
    var uiElements: [UIElementType] = []
    let uiElementsArray = pigeonInstance.uiElements as NSArray
    for uiElement in uiElementsArray {
      switch uiElement {
      case let uiElement as String where uiElement == "adAttribution":
        uiElements.append(UIElementType.adAttribution)
      case let uiElement as NSNumber
      where uiElement.intValue == IMAUiElementType.elements_AD_ATTRIBUTION.rawValue:
        uiElements.append(UIElementType.adAttribution)
      case let uiElement as String where uiElement == "countdown":
        uiElements.append(UIElementType.countdown)
      case let uiElement as NSNumber
      where uiElement.intValue == IMAUiElementType.elements_COUNTDOWN.rawValue:
        uiElements.append(UIElementType.countdown)
      default:
        uiElements.append(UIElementType.unknown)
      }
    }
    return uiElements
  }

  func width(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Int64 {
    return Int64(pigeonInstance.width)
  }

  func height(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Int64 {
    return Int64(pigeonInstance.height)
  }

  func vastMediaWidth(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Int64 {
    return Int64(pigeonInstance.vastMediaWidth)
  }

  func vastMediaHeight(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Int64 {
    return Int64(pigeonInstance.vastMediaHeight)
  }

  func vastMediaBitrate(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Int64 {
    return Int64(pigeonInstance.vastMediaBitrate)
  }

  func isLinear(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Bool {
    return pigeonInstance.isLinear
  }

  func isSkippable(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Bool {
    return pigeonInstance.isSkippable
  }

  func skipTimeOffset(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> Double {
    return pigeonInstance.skipTimeOffset
  }

  func adPodInfo(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> IMAAdPodInfo {
    return pigeonInstance.adPodInfo
  }

  func traffickingParameters(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.traffickingParameters
  }

  func creativeID(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.creativeID
  }

  func creativeAdID(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.creativeAdID
  }

  func universalAdIDs(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> [IMAUniversalAdID]
  {
    return pigeonInstance.universalAdIDs
  }

  func advertiserName(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.advertiserName
  }

  func surveyURL(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String? {
    return pigeonInstance.surveyURL
  }

  func dealID(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> String {
    return pigeonInstance.dealID
  }

  func wrapperAdIDs(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> [String] {
    return pigeonInstance.wrapperAdIDs
  }

  func wrapperCreativeIDs(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> [String] {
    return pigeonInstance.wrapperCreativeIDs
  }

  func wrapperSystems(pigeonApi: PigeonApiIMAAd, pigeonInstance: IMAAd) throws -> [String] {
    return pigeonInstance.wrapperSystems
  }

}
