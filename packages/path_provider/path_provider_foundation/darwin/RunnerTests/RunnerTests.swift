// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import path_provider_foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

class RunnerTests: XCTestCase {
  func testGetTemporaryDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .temp)
    XCTAssertEqual(
      path,
      NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.cachesDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }

  func testGetApplicationDocumentsDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .applicationDocuments)
    XCTAssertEqual(
      path,
      NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }

  func testGetApplicationSupportDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .applicationSupport)
    #if os(iOS)
      // On iOS, the application support directory path should be just the system application
      // support path.
      XCTAssertEqual(
        path,
        NSSearchPathForDirectoriesInDomains(
          FileManager.SearchPathDirectory.applicationSupportDirectory,
          FileManager.SearchPathDomainMask.userDomainMask,
          true
        ).first)
    #else
      // On macOS, the application support directory path should be the system application
      // support path with an added subdirectory based on the app name.
      XCTAssert(
        path!.hasPrefix(
          NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.applicationSupportDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
          ).first!))
      XCTAssert(path!.hasSuffix("Example"))
    #endif
  }

  func testGetLibraryDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .library)
    XCTAssertEqual(
      path,
      NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.libraryDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }

  func testGetDownloadsDirectory() throws {
    let plugin = PathProviderPlugin()
    let path = plugin.getDirectoryPath(type: .downloads)
    XCTAssertEqual(
      path,
      NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.downloadsDirectory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true
      ).first)
  }
}
