// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Implementation of `CrossFileDarwinApi`.
class CrossFileDarwinApiImpl: CrossFileDarwinApi {
  func tryCreateBookmarkedUrl(url: String) throws -> String? {
    let nativeUrl = URL(string: url)!
    let data = try nativeUrl.bookmarkData(
      options: [],
      includingResourceValuesForKeys: nil,
      relativeTo: nil
    )

    var isStale: Bool = true
    let bookmarkedUrl: URL = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)

    if !isStale {
      return bookmarkedUrl.absoluteString
    }

    return nil
  }

  func startAccessingSecurityScopedResource(url: String) throws -> Bool {
    return URL(string: url)!.startAccessingSecurityScopedResource()
  }

  func stopAccessingSecurityScopedResource(url: String) throws {
    URL(string: url)!.stopAccessingSecurityScopedResource()
  }
}
