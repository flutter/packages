// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import UIKit
import XCTest

@testable import interactive_media_ads

class CompanionAdSlotProxyApiTests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let view = UIView()
    let instance = try! api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api, view: view)
    XCTAssertEqual(instance.view, view)
  }

  func testSize() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let view = UIView()
    let width = 0
    let height = 1
    let instance = try! api.pigeonDelegate.size(
      pigeonApi: api, view: view, width: Int64(width), height: Int64(height))
    XCTAssertEqual(instance.view, view)
    XCTAssertEqual(instance.width, width)
    XCTAssertEqual(instance.height, height)
  }

  func testView() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let instance = IMACompanionAdSlot(view: UIView())
    let value = try? api.pigeonDelegate.view(pigeonApi: api, pigeonInstance: instance)

    XCTAssertEqual(value, instance.view)
  }

  func testSetDelegate() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMACompanionAdSlot(registrar)

    let instance = IMACompanionAdSlot(view: UIView())
    let delegate = CompanionDelegateImpl(
      api: registrar.apiDelegate.pigeonApiIMACompanionDelegate(registrar))
    try? api.pigeonDelegate.setDelegate(
      pigeonApi: api, pigeonInstance: instance, delegate: delegate)

    XCTAssertIdentical(instance.delegate, delegate)
  }
}
