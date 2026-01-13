// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing
import UIKit

@testable import interactive_media_ads

@MainActor
struct FriendlyObstructionProxyApiTests {
  @Test func pigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(
      pigeonApi: api, view: UIView(), purpose: .mediaControls, detailedReason: "myString")
    #expect(instance != nil)
  }

  @Test func pigeonDefaultConstructorWithUnknownPurpose() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    #expect(throws: PigeonError.self) {
      try api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api, view: UIView(), purpose: .unknown, detailedReason: "myString")
    }
  }

  @Test func view() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    let value = try? api.pigeonDelegate.view(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.view)
  }

  @Test func purpose() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    let value = try? api.pigeonDelegate.purpose(pigeonApi: api, pigeonInstance: instance)

    #expect(value == FriendlyObstructionPurpose.closeAd)
  }

  @Test func detailedReason() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAFriendlyObstruction(registrar)

    let instance = IMAFriendlyObstruction(
      view: UIView(), purpose: IMAFriendlyObstructionPurpose.closeAd, detailedReason: "reason")
    let value = try? api.pigeonDelegate.detailedReason(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.detailedReason)
  }
}
