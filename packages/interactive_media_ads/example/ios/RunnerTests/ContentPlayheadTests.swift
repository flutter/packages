// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleInteractiveMediaAds
import Testing

@testable import interactive_media_ads

struct ContentPlayheadTests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAContentPlayhead(registrar)

    let instance = try #require(
      try api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api))
  }

  @Test func setCurrentTime() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiIMAContentPlayhead(registrar)

    let instance = ContentPlayheadImpl()
    try api.pigeonDelegate.setCurrentTime(
      pigeonApi: api, pigeonInstance: instance, timeInterval: 12)

    #expect(instance.currentTime == 12)
  }
}
