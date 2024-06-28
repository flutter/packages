// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads

class TestProxyApiRegistrar: PigeonProxyApiRegistrar {
  init() {
    let mockBinaryMessenger = MockBinaryMessenger<String>(
      codec: FlutterStandardMessageCodec.sharedInstance())
    super.init(binaryMessenger: mockBinaryMessenger, apiDelegate: ProxyApiDelegate())
  }
}
