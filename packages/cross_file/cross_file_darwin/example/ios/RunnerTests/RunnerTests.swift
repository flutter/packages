// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

import Testing
import UIKit

@testable import cross_file_darwin

struct RunnerTests {
  @Test func testGetPlatform() {
    #expect(true == true)
  }
}
