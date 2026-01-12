// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import path_provider_foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

struct RunnerTests {
  @Test(arguments: [
    (DirectoryType.temp, FileManager.SearchPathDirectory.cachesDirectory),
    (.applicationDocuments, .documentDirectory),
    (.library, .libraryDirectory),
    (.downloads, .downloadsDirectory),
  ])
  func directoryPath(
    directoryType: DirectoryType,
    searchPathDirectory: FileManager.SearchPathDirectory
  ) throws {
    let plugin = PathProviderPlugin()
    let path = try #require(plugin.getDirectoryPath(type: directoryType))
    let expected = try #require(
      NSSearchPathForDirectoriesInDomains(
        searchPathDirectory,
        .userDomainMask,
        true
      ).first
    )
    #expect(path == expected)
  }

  @Test func getApplicationSupportDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = try #require(plugin.getDirectoryPath(type: .applicationSupport))
    let base = try #require(
      NSSearchPathForDirectoriesInDomains(
        .applicationSupportDirectory,
        .userDomainMask,
        true
      ).first
    )

    #if os(iOS)
      // On iOS, the application support directory path should be just the system application
      // support path.
      #expect(path == base)
    #else
      // On macOS, the application support directory path should be the system application
      // support path with an added subdirectory based on the app name.
      #expect(path.hasPrefix(base))
      #expect(path.hasSuffix("Example"))
    #endif
  }
}
