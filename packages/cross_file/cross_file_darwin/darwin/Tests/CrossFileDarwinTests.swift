// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import cross_file_darwin

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

// Placeholder for adding tests.
struct CrossFileDarwinTests {
  @Test func placeHoldertTest() throws {
    #expect(true == true)
  }
}
