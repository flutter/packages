// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import webview_flutter_wkwebview

class TestProxyApiRegistrar: WebKitLibraryPigeonProxyApiRegistrar {
  init() {
    super.init(binaryMessenger: TestBinaryMessenger(), apiDelegate: ProxyAPIDelegate())
  }
}
