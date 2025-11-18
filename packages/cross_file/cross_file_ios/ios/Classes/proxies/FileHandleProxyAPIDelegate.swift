// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

/// ProxyApi implementation for `FileHandle`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FileHandleProxyAPIDelegate : PigeonApiDelegateFileHandle {
  func forReadingFromUrl(pigeonApi: PigeonApiFileHandle, url: URL) throws -> FileHandle {
    return try FileHandle(forReadingFrom: url)
  }

  func readToEnd(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle) throws -> FlutterStandardTypedData? {
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

  func close(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle) throws {
    try pigeonInstance.close()
  }
  
  func readUpToCount(pigeonApi: PigeonApiFileHandle, pigeonInstance: FileHandle, count: Int64) throws -> FlutterStandardTypedData? {
    if #available(iOS 13.4, *) {
      let data = try pigeonInstance.read(upToCount: Int(count))
      if let data = data {
        return FlutterStandardTypedData(bytes: data)
      }
    }
    
    return nil
  }
}
