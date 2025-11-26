// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `FileManager`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FileManagerProxyAPIDelegate: PigeonApiDelegateFileManager {
  func defaultManager(pigeonApi: PigeonApiFileManager) -> FileManager {
    return FileManager.default
  }

  func fileExists(pigeonApi: PigeonApiFileManager, pigeonInstance: FileManager, atPath: String)
    throws -> Bool
  {
    return pigeonInstance.fileExists(atPath: atPath)
  }

  func isReadableFile(pigeonApi: PigeonApiFileManager, pigeonInstance: FileManager, atPath: String)
    throws -> Bool
  {
    return pigeonInstance.isReadableFile(atPath: atPath)
  }

  func fileModificationDate(
    pigeonApi: PigeonApiFileManager, pigeonInstance: FileManager, atPath: String
  ) throws -> Int64? {
    let attributes: NSDictionary =
      try pigeonInstance.attributesOfItem(atPath: atPath) as NSDictionary
    if let date = attributes.fileModificationDate() {
      return Int64(date.timeIntervalSince1970 * 1000)
    }

    return nil
  }

  func fileSize(pigeonApi: PigeonApiFileManager, pigeonInstance: FileManager, atPath: String) throws
    -> Int64?
  {
    let attributes: NSDictionary =
      try pigeonInstance.attributesOfItem(atPath: atPath) as NSDictionary
    return Int64(attributes.fileSize())
  }

}
