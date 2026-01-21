// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

class CrossFileDarwinApiImpl: CrossFileDarwinApi {
  func tryCreateBookmarkedUrl(url: String) throws -> String? {
    let nativeUrl = URL(string: url)
    if let url = nativeUrl {
      if url.startAccessingSecurityScopedResource() {
        let data = try url.bookmarkData(
          options: [],
          includingResourceValuesForKeys: nil,
          relativeTo: nil
        )

        var isStale: Bool = true
        let url: URL = try URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)

        if (!isStale) {
          return url.absoluteString
        }
      }
    }

    return nil
  }

  func isReadableFile(url: String) throws -> Bool {
    return FileManager.default.isReadableFile(atPath: url)
  }

  func fileExists(url: String) throws -> Bool {
    return FileManager.default.fileExists(atPath: url)
  }

  func fileIsDirectory(url: String) throws -> Bool {
    var isDirectory: ObjCBool = true
    return FileManager.default.fileExists(atPath: url, isDirectory: &isDirectory)
      && isDirectory.boolValue
  }

  func fileModificationDate(url: String) throws -> Int64? {
    let attributes: NSDictionary =
      try FileManager.default.attributesOfItem(atPath: url) as NSDictionary
    if let date = attributes.fileModificationDate() {
      return Int64(date.timeIntervalSince1970 * 1000)
    }

    return nil
  }

  func fileSize(url: String) throws -> Int64? {
    let attributes: NSDictionary =
      try FileManager.default.attributesOfItem(atPath: url) as NSDictionary
    return Int64(attributes.fileSize())
  }

  func list(url: String) throws -> [String] {
    return try FileManager.default.contentsOfDirectory(atPath: url)
  }
}
