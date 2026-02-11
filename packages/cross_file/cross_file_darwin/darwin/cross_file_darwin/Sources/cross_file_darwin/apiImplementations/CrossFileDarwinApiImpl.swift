// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif

import Foundation

/// Implementation of `CrossFileDarwinApi`.
class CrossFileDarwinApiImpl: CrossFileDarwinApi {
  let fileManager: FileManager

  init(fileManager: FileManager = FileManager.default) {
    self.fileManager = fileManager
  }

  func tryCreateBookmarkedUrl(url: String) throws -> String? {
    let nativeUrl = URL(fileURLWithPath: url)
    if nativeUrl.startAccessingSecurityScopedResource() {
      defer { nativeUrl.stopAccessingSecurityScopedResource() }

      let data = try nativeUrl.bookmarkData(
        options: [],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )

      var isStale: Bool = true
      let bookmarkedUrl: URL = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)

      if !isStale {
        return bookmarkedUrl.path
      }
    }

    return nil
  }

  func startAccessingSecurityScopedResource(url: String) throws -> Bool {
      return URL(fileURLWithPath: url).startAccessingSecurityScopedResource()
  }

  func stopAccessingSecurityScopedResource(url: String) throws {
      URL(fileURLWithPath: url).stopAccessingSecurityScopedResource()
  }
}
