// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

struct AdProxyAPITests {
  @Test
  func adId() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.adId(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.adId)
  }

  @Test
  func adTitle() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.adTitle(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.adTitle)
  }

  @Test
  func adDescription() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.adDescription(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.adDescription)
  }

  @Test
  func adSystem() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.adSystem(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.adSystem)
  }

  @MainActor
  @Test
  func companionAds() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.companionAds(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.companionAds)
  }

  @Test
  func contentType() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.contentType(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.contentType)
  }

  @Test
  func duration() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.duration(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.duration)
  }

  @Test
  func uiElements() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let elementArray = NSMutableArray()
    elementArray.add(NSNumber(value: IMAUiElementType.elements_AD_ATTRIBUTION.rawValue))
    let instance = TestAd.customInit()
    instance.testElements = elementArray
    let value = try api.pigeonDelegate.uiElements(pigeonApi: api, pigeonInstance: instance)

    #expect(value == [UIElementType.adAttribution])
  }

  @Test
  func uiElementsWithStrings() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let elementArray = NSMutableArray()
    elementArray.add("adAttribution")
    let instance = TestAd.customInit()
    instance.testElements = elementArray
    let value = try api.pigeonDelegate.uiElements(pigeonApi: api, pigeonInstance: instance)

    #expect(value == [UIElementType.adAttribution])
  }

  @Test
  func width() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.width(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.width))
  }

  @Test
  func height() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.height(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.height))
  }

  @Test
  func vastMediaWidth() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.vastMediaWidth(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.vastMediaWidth))
  }

  @Test
  func vastMediaHeight() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.vastMediaHeight(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.vastMediaHeight))
  }

  @Test
  func vastMediaBitrate() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.vastMediaBitrate(pigeonApi: api, pigeonInstance: instance)

    #expect(value == Int64(instance.vastMediaBitrate))
  }

  @Test
  func isLinear() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.isLinear(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.isLinear)
  }

  @Test
  func isSkippable() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.isSkippable(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.isSkippable)
  }

  @Test
  func skipTimeOffset() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.skipTimeOffset(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.skipTimeOffset)
  }

  @MainActor
  @Test
  func adPodInfo() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.adPodInfo(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.adPodInfo)
  }

  @Test
  func traffickingParameters() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.traffickingParameters(
      pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.traffickingParameters)
  }

  @Test
  func creativeID() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.creativeID(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.creativeID)
  }

  @Test
  func creativeAdID() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.creativeAdID(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.creativeAdID)
  }

  @MainActor
  @Test
  func universalAdIDs() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.universalAdIDs(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.universalAdIDs)
  }

  @Test
  func advertiserName() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.advertiserName(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.advertiserName)
  }

  @Test
  func surveyURL() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.surveyURL(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.surveyURL)
  }

  @Test
  func dealID() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.dealID(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.dealID)
  }

  @Test
  func wrapperAdIDs() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.wrapperAdIDs(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.wrapperAdIDs)
  }

  @Test
  func wrapperCreativeIDs() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.wrapperCreativeIDs(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.wrapperCreativeIDs)
  }

  @Test
  func wrapperSystems() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAAd(registrar)

    let instance = TestAd.customInit()
    let value = try api.pigeonDelegate.wrapperSystems(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.wrapperSystems)
  }
}

class TestAd: IMAAd {
  // Workaround to subclass an Objective-C class that has an `init` constructor with NS_UNAVAILABLE
  static func customInit() -> TestAd {
    let instance =
      try! #require(
        TestAd.perform(NSSelectorFromString("new")).takeRetainedValue() as? TestAd)
    instance._companionAd = TestCompanionAd.customInit()
    instance._universalAdID = TestUniversalAdID.customInit()
    instance._adPodInfo = TestAdPodInfo.customInit()
    return instance
  }

  var _companionAd: TestCompanionAd?
  var _adPodInfo: TestAdPodInfo?
  var _universalAdID: TestUniversalAdID?

  var testElements: NSArray = NSArray()

  override var adId: String {
    return "string1"
  }

  override var adTitle: String {
    return "string2"
  }

  override var adDescription: String {
    return "string3"
  }

  override var adSystem: String {
    return "string4"
  }

  override var companionAds: [IMACompanionAd] {
    return [_companionAd!]
  }

  override var contentType: String {
    return "string5"
  }

  override var duration: TimeInterval {
    return 9.0
  }

  override var uiElements: [NSNumber] {
    return testElements as! [NSNumber]
  }

  override var width: Int {
    return 0
  }

  override var height: Int {
    return 1
  }

  override var vastMediaWidth: Int {
    return 2
  }

  override var vastMediaHeight: Int {
    return 3
  }

  override var vastMediaBitrate: Int {
    return 4
  }

  override var isLinear: Bool {
    return true
  }

  override var isSkippable: Bool {
    return false
  }

  override var skipTimeOffset: TimeInterval {
    return 3.0
  }

  override var adPodInfo: IMAAdPodInfo {
    return _adPodInfo!
  }

  override var traffickingParameters: String {
    return "string123"
  }

  override var creativeID: String {
    return "string6"
  }

  override var creativeAdID: String {
    return "string7"
  }

  override var universalAdIDs: [IMAUniversalAdID] {
    return [_universalAdID!]
  }

  override var advertiserName: String {
    return "string8"
  }

  override var surveyURL: String? {
    return "string10"
  }

  override var dealID: String {
    return "string9"
  }

  override var wrapperAdIDs: [String] {
    return ["string1"]
  }

  override var wrapperCreativeIDs: [String] {
    return ["string2"]
  }

  override var wrapperSystems: [String] {
    return ["string3"]
  }
}
