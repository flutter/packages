// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing
import UIKit

@testable import interactive_media_ads

@MainActor
struct CompanionAdSlotProxyApiTests {
  @Test
  func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let view = UIView()
    let instance = try api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api, view: view)
    #expect(instance.view == view)
  }

  @Test
  func size() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let view = UIView()
    let width = 0
    let height = 1
    let instance = try api.pigeonDelegate.size(
      pigeonApi: api, view: view, width: Int64(width), height: Int64(height))
    #expect(instance.view == view)
    #expect(instance.width == width)
    #expect(instance.height == height)
  }

  @Test
  func view() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let instance = IMACompanionAdSlot(view: UIView())
    let value = try? api.pigeonDelegate.view(pigeonApi: api, pigeonInstance: instance)

    #expect(value == instance.view)
  }

  @Test
  func setDelegate() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let instance = IMACompanionAdSlot(view: UIView())
    let delegate = CompanionDelegateImpl(
      api: registrar.apiDelegate.pigeonApiIMACompanionDelegate(registrar))
    try? api.pigeonDelegate.setDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    #expect(instance.delegate === delegate)
  }
}
