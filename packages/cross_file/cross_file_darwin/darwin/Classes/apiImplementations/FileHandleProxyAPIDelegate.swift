// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

/// ProxyApi implementation for `FileHandle`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FileHandleProxyAPIDelegate: PigeonApiDelegateFileHandle {
  func forReadingFromUrl(pigeonApi: PigeonApiFileHandle, url: String) throws -> FileHandle? {
    return FileHandle(forReadingAtPath: url)
  }

  func readUpToCount(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle, count: Int64)
    throws -> FlutterStandardTypedData?
  {
    var data: Data?
    if #available(iOS 13.4, *) {
      data = try pigeonInstance.read(upToCount: Int(count))
    } else {
      data = pigeonInstance.readData(ofLength: Int(count))
    }

    if let data = data {
      return FlutterStandardTypedData(bytes: data)
    }

    return nil
  }

  func readToEnd(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle) throws
    -> FlutterStandardTypedData?
  {
    var bytes: Data?
    if #available(iOS 13.4, *) {
      bytes = try pigeonInstance.readToEnd()
    } else {
      bytes = pigeonInstance.readDataToEndOfFile()
    }

    if let bytes = bytes {
      return FlutterStandardTypedData(bytes: bytes)
    }

    return nil
  }

  func seek(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle, offset: Int64) throws {
    let convertedOffset = UInt64(exactly: offset)!
    try pigeonInstance.seek(toOffset: convertedOffset)
  }

  func close(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle) throws {
    try pigeonInstance.close()
  }
}
