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

// This plugin doesn't include native unit tests because getting access to files that are part of
// iOS App Sandbox requires user interactions outside of the app.
//
// This also serves as a placeholder for a native test because the CI of flutter/packages requires
// native tests for all iOS plugins.
struct CrossFileDarwinTests {
  @Test func placeHolderTest() throws {
    #expect(true == true)
  }
}
