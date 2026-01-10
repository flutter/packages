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
  @Test func getTemporaryDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .temp)
    #expect(
      path == NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.cachesDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }

  @Test func getApplicationDocumentsDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .applicationDocuments)
    #expect(
      path == NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }

  @Test func getApplicationSupportDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .applicationSupport)
    #if os(iOS)
      // On iOS, the application support directory path should be just the system application
      // support path.
      #expect(
        path == NSSearchPathForDirectoriesInDomains(
          FileManager.SearchPathDirectory.applicationSupportDirectory,
          FileManager.SearchPathDomainMask.userDomainMask,
          true
        ).first)
    #else
      // On macOS, the application support directory path should be the system application
      // support path with an added subdirectory based on the app name.
      #expect(
        path!.hasPrefix(
          NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.applicationSupportDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
          ).first!))
      #expect(path!.hasSuffix("Example"))
    #endif
  }

  @Test func getLibraryDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .library)
    #expect(
      path == NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.libraryDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }

  @Test func getDownloadsDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .downloads)
    #expect(
      path == NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.downloadsDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }
}
