// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import interactive_media_ads

@MainActor
struct ViewTests {
  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiUIView(registrar)

    let instance = try #require(
      try api.pigeonDelegate.pigeonDefaultConstructor(
        pigeonApi: api))
  }
}
